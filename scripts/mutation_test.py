#!/usr/bin/env python3
"""변경된 코드에만 뮤테이션 테스트를 돌린다.

lib/ 코드에 작은 변이(== -> !=, && -> || 등)를 하나씩 넣고 관련 테스트를 돌려,
테스트가 그 변이를 잡는지(killed) 놓치는지(survived) 본다.

비용을 줄이려고 두 가지로 범위를 좁힌다.
- 테스트가 실제로 실행하는 줄(flutter test --coverage)에만 변이를 만든다.
  실행되지 않는 줄은 변이해도 무조건 살아남으므로 '커버리지 없음'으로만 센다.
- 변이마다 그 파일에 import 로 닿는 테스트 파일만 돌린다.

사용법:
  python3 scripts/mutation_test.py --base origin/develop   # base 대비 바뀐 줄만
  python3 scripts/mutation_test.py --all                   # lib 전체 (오래 걸림)

리포트만 남기고 항상 0 으로 끝난다(테스트 실패로 CI 를 막지 않는다).
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import time
from pathlib import Path

REPORT_MARKER = "<!-- mutation-test-report -->"
GENERATED = (".g.dart", ".freezed.dart")

# (이름, 정규식, 바꿀 값). 주석과 문자열을 가린 코드에 적용한다.
OPERATORS = [
    ("== → !=", r"==", "!="),
    ("!= → ==", r"!=", "=="),
    ("<= → <", r"<=", "<"),
    (">= → >", r">=", ">"),
    ("< → <=", r"(?<=\s)<(?=\s)", "<="),  # 앞뒤 공백: 제네릭 <T> 는 건드리지 않는다
    ("> → >=", r"(?<=\s)>(?=\s)", ">="),
    ("&& → ||", r"&&", "||"),
    ("|| → &&", r"\|\|", "&&"),
    ("! 제거", r"(?<![\w)\]!=<>])!(?=[\w(])", ""),  # 앞에 붙는 ! 만 (x! 와 != 는 제외)
    ("true → false", r"\btrue\b", "false"),
    ("false → true", r"\bfalse\b", "true"),
    ("+ → -", r"(?<=\s)\+(?=\s)", "-"),
    ("- → +", r"(?<=\s)-(?=\s)", "+"),
    ("++ → --", r"\+\+", "--"),
    ("-- → ++", r"--", "++"),
    ("isEmpty → isNotEmpty", r"\.isEmpty\b", ".isNotEmpty"),
    ("isNotEmpty → isEmpty", r"\.isNotEmpty\b", ".isEmpty"),
]
# for 헤더의 i++ -> i-- 는 끝나지 않는 루프가 되어 메모리를 다 먹는다.
FOR_HEADER = re.compile(r"\s*(?:await\s+)?for\s*\(|.*\[\s*for\s*\(")
IMPORT_RE = re.compile(r"""^\s*(?:import|export|part)\s+['"]([^'"]+)['"]""", re.M)


# ---------------------------------------------------------------- 소스 분석

def mask(src: str) -> str:
    """주석과 문자열 리터럴 안을 같은 길이의 공백으로 바꾼다(줄바꿈은 유지)."""
    out = list(src)
    i, n = 0, len(src)

    def blank(a: int, b: int) -> None:
        for k in range(a, b):
            if src[k] != "\n":
                out[k] = " "

    while i < n:
        if src.startswith("//", i):
            j = src.find("\n", i)
            j = n if j == -1 else j
            blank(i, j)
            i = j
        elif src.startswith("/*", i):
            j = src.find("*/", i + 2)
            j = n if j == -1 else j + 2
            blank(i, j)
            i = j
        elif src[i] in "'\"":
            raw = i > 0 and src[i - 1] == "r"
            quote = src[i:i + 3] if src[i:i + 3] in ("'''", '"""') else src[i]
            j = i + len(quote)
            while j < n and not src.startswith(quote, j):
                if not raw and src[j] == "\\":
                    j += 2
                    continue
                if not raw and src.startswith("${", j):
                    depth = 0
                    while j < n:
                        if src[j] == "{":
                            depth += 1
                        elif src[j] == "}":
                            depth -= 1
                            if depth == 0:
                                break
                        j += 1
                j += 1
            j = min(n, j + len(quote))
            blank(i, j)
            i = j
        else:
            i += 1
    return "".join(out)


def read_source(path: Path) -> str:
    # read_text() 는 CRLF 를 LF 로 바꿔 오프셋이 어긋난다. 바이트 그대로 읽는다.
    return path.read_bytes().decode("utf-8")


def package_name(repo: Path) -> str:
    m = re.search(r"^name:\s*(\S+)", (repo / "pubspec.yaml").read_text(encoding="utf-8"), re.M)
    return m.group(1)


def import_graph(repo: Path, pkg: str) -> dict[str, set[str]]:
    graph: dict[str, set[str]] = {}
    for path in [*repo.glob("lib/**/*.dart"), *repo.glob("test/**/*.dart")]:
        rel = path.relative_to(repo).as_posix()
        deps = set()
        for target in IMPORT_RE.findall(path.read_text(encoding="utf-8", errors="replace")):
            if target.startswith(f"package:{pkg}/"):
                deps.add("lib/" + target[len(f"package:{pkg}/"):])
            elif not target.startswith(("dart:", "package:")):
                deps.add(os.path.normpath(os.path.join(os.path.dirname(rel), target)).replace("\\", "/"))
        graph[rel] = deps
    return graph


def reachable(graph: dict[str, set[str]], start: str) -> set[str]:
    seen, stack = set(), [start]
    while stack:
        for dep in graph.get(stack.pop(), ()):
            if dep not in seen:
                seen.add(dep)
                stack.append(dep)
    return seen


def covered_lines(repo: Path) -> dict[str, set[int]]:
    covered: dict[str, set[int]] = {}
    current = None
    for line in (repo / "coverage/lcov.info").read_text(encoding="utf-8").splitlines():
        if line.startswith("SF:"):
            path = line[3:].replace("\\", "/")
            current = path[path.index("lib/"):]
            covered[current] = set()
        elif line.startswith("DA:") and current:
            number, hits = line[3:].split(",")[:2]
            if int(hits) > 0:
                covered[current].add(int(number))
    return covered


def changed_lines(repo: Path, base: str) -> dict[str, set[int]]:
    """base 와의 merge-base 대비 추가/수정된 lib 줄."""
    diff = subprocess.run(
        ["git", "diff", "--unified=0", "--no-color", "--no-ext-diff", f"{base}...HEAD", "--", "lib"],
        cwd=repo, capture_output=True, text=True, encoding="utf-8", check=True,
    ).stdout
    changed: dict[str, set[int]] = {}
    current = None
    for line in diff.splitlines():
        if line.startswith("+++ "):
            path = line[4:]
            current = path[2:] if path.startswith("b/") else None
            if current and current.endswith(".dart") and not current.endswith(GENERATED):
                changed.setdefault(current, set())
            else:
                current = None
        elif line.startswith("@@") and current:
            m = re.search(r"\+(\d+)(?:,(\d+))?", line)
            start, count = int(m.group(1)), int(m.group(2) or 1)
            changed[current].update(range(start, start + count))
    return {f: lines for f, lines in changed.items() if lines}


def find_mutants(text: str, lines: set[int] | None) -> list[dict]:
    """[lines] 가 None 이면 모든 줄."""
    mutants = []
    offset = 0
    for number, (raw, masked) in enumerate(zip(text.split("\n"), mask(text).split("\n")), 1):
        code = raw.strip()
        if (lines is None or number in lines) and code and not code.startswith(
                ("import ", "export ", "part ", "@")):
            for name, regex, replacement in OPERATORS:
                if name in ("++ → --", "-- → ++") and FOR_HEADER.match(masked):
                    continue
                for m in re.finditer(regex, masked):
                    mutants.append({"line": number, "op": name, "start": offset + m.start(),
                                    "end": offset + m.end(), "replacement": replacement,
                                    "code": code[:160]})
        offset += len(raw) + 1
    return mutants


# ---------------------------------------------------------------- 실행

def flutter_cmd() -> str:
    """FLUTTER 환경 변수가 있으면 그 경로를 쓴다(예: fvm 으로 받은 SDK)."""
    found = os.environ.get("FLUTTER") or shutil.which("flutter")
    if not found:
        sys.exit("flutter 를 찾지 못했습니다. PATH 에 넣거나 FLUTTER 환경 변수로 경로를 주세요.")
    return found


def run_flutter(repo: Path, args: list[str], timeout: float | None):
    """(returncode | None(타임아웃), 출력). 타임아웃이면 자식 프로세스까지 모두 끈다."""
    kwargs = {"start_new_session": True} if os.name != "nt" else {}
    proc = subprocess.Popen([flutter_cmd(), *args], cwd=repo, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, **kwargs)
    try:
        out, _ = proc.communicate(timeout=timeout)
        return proc.returncode, out.decode("utf-8", "replace")
    except subprocess.TimeoutExpired:
        if os.name == "nt":
            subprocess.run(["taskkill", "/F", "/T", "/PID", str(proc.pid)], capture_output=True)
        else:
            os.killpg(proc.pid, signal.SIGKILL)
        out, _ = proc.communicate()
        return None, out.decode("utf-8", "replace")


COMPILE_ERROR = re.compile(r"Failed to load|Compilation failed|^\S*lib/\S+:\d+:\d+: Error:", re.M)
# flutter test 가 테스트를 돌렸으면 `00:01 +3 -1: ...` 같은 진행 줄을 남긴다.
TESTS_RAN = re.compile(r"^\d+:\d+ \+\d+", re.M)


def run_mutant(repo: Path, mutant: dict, tests: list[str], concurrency: int, timeout: float) -> str:
    path = repo / mutant["file"]
    original = path.read_bytes()
    text = original.decode("utf-8")
    mutated = text[:mutant["start"]] + mutant["replacement"] + text[mutant["end"]:]
    try:
        path.write_bytes(mutated.encode("utf-8"))
        code, output = run_flutter(repo, ["test", f"--concurrency={concurrency}", *tests], timeout)
    finally:
        path.write_bytes(original)
    if code is None:
        return "timeout"
    # 컴파일 실패도 진행 줄(`+0 -1: loading ... [E]`)을 남기므로 먼저 가른다.
    if COMPILE_ERROR.search(output):
        return "invalid"
    if not TESTS_RAN.search(output):
        # flutter 가 테스트를 돌리지 못했다(도구 오류, 종료 중인 세션 등).
        # 실패 코드라고 killed 로 세면 점수가 부풀려진다.
        raise RuntimeError(f"flutter test 가 테스트를 돌리지 못했습니다:\n{output[-2000:]}")
    return "survived" if code == 0 else "killed"


# ---------------------------------------------------------------- 리포트

def score_of(counts: dict[str, int]) -> float | None:
    detected = counts.get("killed", 0) + counts.get("timeout", 0)
    total = detected + counts.get("survived", 0)
    return None if total == 0 else 100 * detected / total


def write_report(path: Path, title: str, results: list[dict], uncovered: dict[str, int],
                 skipped: int, note: str | None) -> None:
    counts: dict[str, int] = {}
    for r in results:
        counts[r["status"]] = counts.get(r["status"], 0) + 1
    score = score_of(counts)
    lines = [REPORT_MARKER, f"## 🧬 뮤테이션 테스트 ({title})", ""]
    if note is None and not results and not uncovered:
        note = "바뀐 `lib/` 코드에 변이할 지점(비교·논리 연산자, true/false 등)이 없어 돌리지 않았습니다."
    if note:
        lines += [note, ""]
    if results:
        lines += [
            f"**점수 {score:.1f}%**" if score is not None else "**점수 없음**",
            "",
            "| 결과 | 개수 | 의미 |",
            "|---|---|---|",
            f"| killed | {counts.get('killed', 0)} | 테스트가 변이를 잡음 |",
            f"| timeout | {counts.get('timeout', 0)} | 시간 초과 (잡은 것으로 계산) |",
            f"| survived | {counts.get('survived', 0)} | 테스트가 그대로 통과함 |",
            f"| invalid | {counts.get('invalid', 0)} | 컴파일 실패 (점수에서 제외) |",
            "",
            "점수 = (killed + timeout) / (killed + timeout + survived)",
            "",
        ]
    if skipped:
        lines += [f"> 변이가 너무 많아 {skipped}개는 돌리지 않았습니다.", ""]
    survived = [r for r in results if r["status"] == "survived"]
    if survived:
        lines += ["### 살아남은 변이", "", "| 위치 | 변이 | 코드 |", "|---|---|---|"]
        for r in survived[:60]:
            code = r["code"].replace("|", "\\|").replace("`", "'")
            lines.append(f"| `{r['file']}:{r['line']}` | {r['op']} | `{code}` |")
        if len(survived) > 60:
            lines.append(f"| … | 외 {len(survived) - 60}개 | |")
        lines += ["", "동작이 같아 잡을 수 없는 변이(카운터 `++`/`--` 등)도 섞여 있을 수 있습니다.", ""]
    if uncovered:
        lines += ["### 테스트가 실행하지 않는 변경 코드", "",
                  "변이할 수 있는 지점이 있지만 테스트가 한 번도 실행하지 않는 줄입니다.", "",
                  "| 파일 | 지점 수 |", "|---|---|"]
        lines += [f"| `{f}` | {n} |" for f, n in sorted(uncovered.items())]
        lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")


# ---------------------------------------------------------------- main

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    scope = parser.add_mutually_exclusive_group(required=True)
    scope.add_argument("--base", help="이 ref 대비 바뀐 줄만 변이한다 (예: origin/develop)")
    scope.add_argument("--all", action="store_true", help="lib 전체를 변이한다")
    parser.add_argument("--concurrency", type=int, default=2, help="flutter test 동시 실행 수")
    parser.add_argument("--timeout", type=float, default=180, help="변이 하나당 제한 시간(초)")
    parser.add_argument("--max-mutants", type=int, default=0, help="돌릴 변이 수 상한 (0=제한 없음)")
    parser.add_argument("--skip-coverage", action="store_true", help="기존 coverage/lcov.info 를 쓴다")
    parser.add_argument("--report", default="mutation-report.md")
    parser.add_argument("--json", default="mutation-report.json")
    args = parser.parse_args()

    repo = Path(subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True,
                               text=True, check=True).stdout.strip())
    report, report_json = Path(args.report).resolve(), Path(args.json).resolve()
    title = "변경된 줄" if args.base else "lib 전체"

    if subprocess.run(["git", "status", "--porcelain", "lib"], cwd=repo, capture_output=True,
                      text=True).stdout.strip():
        sys.exit("lib 에 커밋하지 않은 변경이 있습니다. 변이를 되돌리다 덮어쓸 수 있어 중단합니다.")

    if args.base:
        targets: dict[str, set[int] | None] = dict(changed_lines(repo, args.base))
    else:
        targets = {p.relative_to(repo).as_posix(): None for p in repo.glob("lib/**/*.dart")
                   if not p.name.endswith(GENERATED)}
    if not targets:
        write_report(report, title, [], {}, 0, "변경된 `lib/` Dart 코드가 없어 건너뛰었습니다.")
        report_json.write_text("[]", encoding="utf-8")
        print("변경된 lib 코드 없음")
        return 0

    if not args.skip_coverage:
        print("커버리지 수집 중 (flutter test --coverage)", flush=True)
        code, output = run_flutter(repo, ["test", "--coverage", f"--concurrency={args.concurrency}"], None)
        if code != 0:
            write_report(report, title, [], {}, 0,
                         "기존 테스트가 실패해서 뮤테이션 테스트를 건너뛰었습니다. 테스트부터 고쳐 주세요.")
            report_json.write_text("[]", encoding="utf-8")
            print(output[-3000:])
            return 0
    covered = covered_lines(repo)

    graph = import_graph(repo, package_name(repo))
    tests = [t for t in graph if t.startswith("test/") and t.endswith("_test.dart")]
    reach = {t: reachable(graph, t) for t in tests}

    mutants, uncovered = [], {}
    for file, lines in sorted(targets.items()):
        related = sorted(t for t in tests if file in reach[t])
        for m in find_mutants(read_source(repo / file), lines):
            if related and m["line"] in covered.get(file, set()):
                mutants.append({**m, "file": file, "tests": related})
            else:
                uncovered[file] = uncovered.get(file, 0) + 1

    skipped = 0
    if args.max_mutants and len(mutants) > args.max_mutants:
        skipped = len(mutants) - args.max_mutants
        mutants = mutants[:args.max_mutants]

    print(f"변이 {len(mutants)}개 실행 (커버리지 없음 {sum(uncovered.values())}, 생략 {skipped})", flush=True)
    results = []
    note = None
    try:
        for i, m in enumerate(mutants, 1):
            started = time.time()
            status = run_mutant(repo, m, m["tests"], args.concurrency, args.timeout)
            results.append({k: m[k] for k in ("file", "line", "op", "code")} | {"status": status})
            print(f"[{i}/{len(mutants)}] {m['file']}:{m['line']} {m['op']} -> {status} "
                  f"({time.time() - started:.0f}s)", flush=True)
    except RuntimeError as e:
        note = f"⚠️ 중간에 멈췄습니다: flutter test 가 정상적으로 돌지 않았습니다. ({len(results)}개까지만 반영)"
        print(e, file=sys.stderr)
    finally:
        write_report(report, title, results, uncovered, skipped, note)
        report_json.write_text(json.dumps(results, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"리포트: {report}")
    return 0


if __name__ == "__main__":
    # Windows 콘솔 기본 인코딩(cp949)으로 리다이렉트하면 한글 로그가 깨진다.
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
    # CI 취소(SIGTERM)에도 finally 가 돌아 변이한 파일을 되돌리게 한다.
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(1))
    sys.exit(main())
