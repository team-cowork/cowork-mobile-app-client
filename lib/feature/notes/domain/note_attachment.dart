import 'package:equatable/equatable.dart';

/// 회의록에 붙은 파일 하나.
///
/// 서버는 파일을 [objectKey] 로 알아보고 이름만 같이 돌려준다.
class NoteAttachment extends Equatable {
  const NoteAttachment({required this.objectKey, required this.name});

  /// 업로드 확인(`files/confirm`)이 돌려준 확정 키. 다운로드 주소를 받을 때 쓴다.
  final String objectKey;

  /// 받을 때 보일 파일 이름 (예: 회의자료.pdf).
  final String name;

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
