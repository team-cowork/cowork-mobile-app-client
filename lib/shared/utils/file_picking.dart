import 'package:file_picker/file_picker.dart';

import '../domain/upload_file.dart';

/// 올릴 파일 하나를 고른다. 사용자가 취소하면 null.
///
/// 형식은 거르지 않는다. 어떤 형식을 받을지는 서버가 정하고, 받지 않는 형식이면
/// 업로드 주소를 줄 때 거절한다.
///
/// Android 에서 고른 파일은 경로 없는 content URI 일 수 있어서, 경로로 열지 않고
/// 선택기가 주는 스트림으로 읽는다. 크기를 알 수 없으면 업로드 주소를 받을 수 없으므로
/// [StateError] 를 던진다.
Future<UploadFile?> pickUploadFile() async {
  final file = await FilePicker.pickFile();
  if (file == null) return null;
  return _uploadFileOf(file);
}

Future<UploadFile> _uploadFileOf(PlatformFile file) async {
  final size = file.lengthSync() ?? await file.length();
  if (size == null) throw StateError('고른 파일의 크기를 알 수 없다: ${file.name}');
  return (name: file.name, size: size, read: file.readAsByteStream);
}
