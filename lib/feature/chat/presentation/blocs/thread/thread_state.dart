part of 'thread_bloc.dart';

typedef ThreadState = AsyncState<ThreadConversation>;

/// 스레드 화면이 그리는 데이터. 스레드와, 화면이 한 번 알릴 전송 실패 사유를 든다.
///
/// 실패 사유는 화면에 알리기 위한 일회성 값이라 도메인([MessageThread])이 아니라 여기에
/// 둔다.
final class ThreadConversation extends Equatable {
  const ThreadConversation({required this.thread, this.errorMessage});

  final MessageThread thread;

  /// 직전 답글 전송이 실패한 사유. 화면이 한 번 보여 준다.
  final String? errorMessage;

  ThreadConversation withError(String message) =>
      ThreadConversation(thread: thread, errorMessage: message);

  @override
  List<Object?> get props => [thread, errorMessage];
}
