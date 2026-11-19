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
