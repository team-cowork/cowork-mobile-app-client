#!/bin/zsh

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
project_root="$(cd -- "$script_dir/.." && pwd)"
cd "$project_root"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/rename_project.sh <dart_package_name> <android_package> <app_display_name> [ios_bundle_id]

Example:
  ./scripts/rename_project.sh my_app com.mycompany.myapp "My App"
  ./scripts/rename_project.sh my_app com.mycompany.myapp "My App" com.mycompany.myapp.ios
EOF
}

if [[ $# -lt 3 || $# -gt 4 ]]; then
  usage
  exit 1
fi

dart_package_name="$1"
android_package="$2"
app_display_name="$3"
ios_bundle_id="${4:-$android_package}"

if [[ ! "$dart_package_name" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "dart_package_name must be snake_case and start with a lowercase letter."
  exit 1
fi

if [[ ! "$android_package" =~ ^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$ ]]; then
  echo "android_package must be a dot-separated package name such as com.example.myapp."
  exit 1
fi

if [[ ! "$ios_bundle_id" =~ ^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$ ]]; then
  echo "ios_bundle_id must be a reverse-domain bundle id such as com.example.myapp."
  exit 1
fi

current_dart_package_name="$(sed -n 's/^name:[[:space:]]*//p' pubspec.yaml | head -n 1)"
current_android_package="$(sed -n 's/^[[:space:]]*namespace = "\(.*\)"/\1/p' android/app/build.gradle.kts | head -n 1)"
current_ios_bundle_id="$(sed -n 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);/\1/p' ios/Runner.xcodeproj/project.pbxproj | grep -v 'RunnerTests' | head -n 1)"
current_android_label="$(sed -n 's/.*android:label=\"\(.*\)\".*/\1/p' android/app/src/main/AndroidManifest.xml | head -n 1)"
current_app_display_name="$(python3 - <<'PY'
from pathlib import Path
import re

content = Path("ios/Runner/Info.plist").read_text()
match = re.search(r"<key>CFBundleDisplayName</key>\s*<string>(.*?)</string>", content, re.S)
print(match.group(1) if match else "")
PY
)"
current_material_app_title="$(python3 - <<'PY'
from pathlib import Path
import re

content = Path("lib/main.dart").read_text()
match = re.search(r"title:\s*'([^']*)'", content)
print(match.group(1) if match else "")
PY
)"

replace_in_file() {
  local file="$1"
  local old="$2"
  local new="$3"

  OLD_VALUE="$old" NEW_VALUE="$new" python3 - "$file" <<'PY'
from pathlib import Path
import os
import sys

path = Path(sys.argv[1])
old = os.environ["OLD_VALUE"]
new = os.environ["NEW_VALUE"]
content = path.read_text()
path.write_text(content.replace(old, new))
PY
}

replace_in_file "pubspec.yaml" "$current_dart_package_name" "$dart_package_name"

dart_files=("${(@f)$(rg -l "package:${current_dart_package_name}/|${current_dart_package_name}" lib test 2>/dev/null || true)}")
for file in "${dart_files[@]}"; do
  [[ -n "$file" ]] || continue
  replace_in_file "$file" "package:${current_dart_package_name}/" "package:${dart_package_name}/"
done

replace_in_file "lib/main.dart" "title: '$current_material_app_title'" "title: '$app_display_name'"
replace_in_file "android/app/build.gradle.kts" "$current_android_package" "$android_package"
replace_in_file "android/app/src/main/AndroidManifest.xml" "android:label=\"$current_android_label\"" "android:label=\"$app_display_name\""
replace_in_file "ios/Runner/Info.plist" "$current_app_display_name" "$app_display_name"
replace_in_file "ios/Runner/Info.plist" "$current_dart_package_name" "$dart_package_name"
replace_in_file "ios/Runner.xcodeproj/project.pbxproj" "$current_ios_bundle_id" "$ios_bundle_id"
replace_in_file "ios/Runner.xcodeproj/project.pbxproj" "${current_ios_bundle_id}.RunnerTests" "${ios_bundle_id}.RunnerTests"

android_code_files=("${(@f)$(rg -l "$current_android_package" android/app/src/main 2>/dev/null || true)}")
for file in "${android_code_files[@]}"; do
  [[ -n "$file" ]] || continue
  replace_in_file "$file" "$current_android_package" "$android_package"
done

old_package_path="$(print -r -- "$current_android_package" | tr '.' '/')"
new_package_path="$(print -r -- "$android_package" | tr '.' '/')"
old_package_dir="android/app/src/main/kotlin/${old_package_path}"
new_package_dir="android/app/src/main/kotlin/${new_package_path}"

if [[ -d "$old_package_dir" && "$old_package_dir" != "$new_package_dir" ]]; then
  mkdir -p "$(dirname "$new_package_dir")"

  if [[ -d "$new_package_dir" ]]; then
    while IFS= read -r file; do
      relative_path="${file#$old_package_dir/}"
      target_dir="$(dirname "$new_package_dir/$relative_path")"
      mkdir -p "$target_dir"
      mv "$file" "$new_package_dir/$relative_path"
    done < <(find "$old_package_dir" -type f)
  else
    mv "$old_package_dir" "$new_package_dir"
  fi

  find "android/app/src/main/kotlin" -depth -type d -empty -exec rmdir {} + 2>/dev/null || true
fi

echo "Renamed template values:"
echo "  Dart package : $current_dart_package_name -> $dart_package_name"
echo "  Android      : $current_android_package -> $android_package"
echo "  iOS bundle   : $current_ios_bundle_id -> $ios_bundle_id"
echo "  App name     : $current_app_display_name -> $app_display_name"
echo
echo "Next steps:"
echo "  1. flutter pub get"
echo "  2. flutter clean"
echo "  3. flutter run"
