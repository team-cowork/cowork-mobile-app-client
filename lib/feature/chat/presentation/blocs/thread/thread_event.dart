part of 'thread_bloc.dart';

sealed class ThreadEvent extends Equatable {
  const ThreadEvent();

  /// 부모 메시지와 답글을 불러온다.
  const factory ThreadEvent.requested() = ThreadRequested;

  /// 입력한 답글을 보낸다.
  const factory ThreadEvent.replySent(String text) = ThreadReplySent;

  /// 스레드 이름을 정한다. 이름을 붙인 적이 없으면 스레드를 만든다.
  const factory ThreadEvent.renamed(String name) = ThreadRenamed;

  /// 스레드를 보관하거나 보관을 푼다. 이름을 붙여 만든 스레드만 보관할 수 있다.
  const factory ThreadEvent.archivedChanged(bool archived) =
      ThreadArchivedChanged;

  @override
  List<Object?> get props => [];
}

final class ThreadRequested extends ThreadEvent {
  const ThreadRequested();
}

final class ThreadReplySent extends ThreadEvent {
  const ThreadReplySent(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class ThreadRenamed extends ThreadEvent {
  const ThreadRenamed(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class ThreadArchivedChanged extends ThreadEvent {
  const ThreadArchivedChanged(this.archived);

  final bool archived;

  @override
  List<Object?> get props => [archived];
}

/// 소켓으로 스레드에 반영할 이벤트가 왔다. 화면이 아니라 Bloc 이 스스로 넣는다.
final class _ThreadSocketEventReceived extends ThreadEvent {
  const _ThreadSocketEventReceived(this.event);

  final MessageSocketEvent event;

  @override
  List<Object?> get props => [event];
}

/// 이름을 몰랐던 작성자의 이름을 받아 왔다. Bloc 이 스스로 넣는다.
final class _ThreadAuthorsResolved extends ThreadEvent {
  const _ThreadAuthorsResolved(this.authors);

  final List<ProfileEntity> authors;

  @override
  List<Object?> get props => [authors];
}

/// 보낸 답글이 기다린 시간 안에 소켓으로 오지 않았다. Bloc 이 스스로 넣는다.
final class _ThreadConfirmTimedOut extends ThreadEvent {
  const _ThreadConfirmTimedOut(this.clientMessageId);

  final String clientMessageId;

  @override
  List<Object?> get props => [clientMessageId];
}

/// 소켓이 끊김 복구 없이 다시 붙었다. Bloc 이 스스로 넣는다.
final class _ThreadResynced extends ThreadEvent {
  const _ThreadResynced();
}
