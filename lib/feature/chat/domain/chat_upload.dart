import 'package:equatable/equatable.dart';

/// 내가 보내는 파일 메시지의 전송 상태. 서버에 저장된 메시지에는 없다.
class ChatUpload extends Equatable {
  const ChatUpload({required this.progress, this.failed = false});

  /// 올린 비율(0~1). 파일이 여럿이면 전체 크기 기준이다.
  final double progress;

  /// 보내지 못했다. 다시 보내거나 지울 수 있다.
  final bool failed;

  @override
  List<Object?> get props => [progress, failed];
}
