import 'package:equatable/equatable.dart';

/// 회의록에 붙은 파일 하나.
///
/// 서버는 파일을 [objectKey] 로 알아보고 이름만 같이 돌려준다. 크기·형식은 주지
/// 않으므로 화면에 보일 형식은 이름의 확장자로 짐작한다.
class NoteAttachment extends Equatable {
  const NoteAttachment({required this.objectKey, required this.name});

  /// 업로드 확인(`files/confirm`)이 돌려준 확정 키. 다운로드 주소를 받을 때 쓴다.
  final String objectKey;

  /// 받을 때 보일 파일 이름 (예: 회의자료.pdf).
  final String name;

  /// 소문자 확장자. 없으면 빈 문자열이다.
  String get extension => extensionOf(name);

  @override
  List<Object?> get props => [objectKey, name];
}

/// 첨부하려고 고른 파일. 아직 서버에 없다.
///
/// 크기는 업로드 주소를 받을 때 서버에 미리 알려야 하고, 실제 올린 크기와 다르면
/// 서버가 거절한다. [read] 는 부를 때마다 처음부터 읽는 새 스트림을 준다. 큰 파일을
/// 통째로 메모리에 올리지 않으려고 바이트 대신 스트림을 들고 다닌다.
typedef NoteUploadFile = ({
  String name,
  int size,
  Stream<List<int>> Function() read,
});

/// 서버(cowork-chat)가 받는 첨부 형식. 확장자 → MIME 타입.
///
/// 서버는 이 목록 밖의 형식을 400 으로 거절하므로 파일을 고를 때부터 걸러 낸다. 서버
/// 설정(`S3_CHAT_ALLOWED_CONTENT_TYPES`)의 기본값을 옮긴 것이라, 서버가 형식을 늘리면
/// 여기도 늘려야 한다.
const noteAttachmentContentTypes = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'gif': 'image/gif',
  'webp': 'image/webp',
  'mp4': 'video/mp4',
  'mov': 'video/quicktime',
  'avi': 'video/x-msvideo',
  'mp3': 'audio/mpeg',
  'ogg': 'audio/ogg',
  'wav': 'audio/wav',
  'm4a': 'audio/mp4',
  'pdf': 'application/pdf',
  'txt': 'text/plain',
};

/// [name] 의 소문자 확장자. 점이 없거나 점으로 끝나면 빈 문자열이다.
String extensionOf(String name) {
  final dot = name.lastIndexOf('.');
  if (dot <= 0 || dot == name.length - 1) return '';
  return name.substring(dot + 1).toLowerCase();
}
