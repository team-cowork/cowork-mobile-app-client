import 'package:file_picker/file_picker.dart';

import '../../domain/note_attachment.dart';

/// 첨부할 파일 하나를 고른다. 사용자가 취소하면 null.
///
/// 테스트가 기기 파일 선택 창 대신 가짜 파일을 넣을 수 있게 함수로 받는다.
typedef NoteFilePicker = Future<NoteUploadFile?> Function();

/// 기본 [NoteFilePicker]. 서버가 받는 형식([noteAttachmentContentTypes])만 고를 수
/// 있게 거른다.
///
/// Android 에서 고른 파일은 경로 없는 content URI 일 수 있어서, 경로로 열지 않고
/// 선택기가 주는 스트림으로 읽는다. 크기를 알 수 없으면 업로드 주소를 받을 수 없으므로
/// [StateError] 를 던진다.
Future<NoteUploadFile?> pickNoteFile() async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: noteAttachmentContentTypes.keys.toList(),
  );
  if (file == null) return null;

  final size = file.lengthSync() ?? await file.length();
  if (size == null) throw StateError('고른 파일의 크기를 알 수 없다: ${file.name}');
  return (name: file.name, size: size, read: file.readAsByteStream);
}
