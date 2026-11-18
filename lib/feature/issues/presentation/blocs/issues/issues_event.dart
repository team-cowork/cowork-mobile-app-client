part of 'issues_bloc.dart';

sealed class IssuesEvent extends Equatable {
  const IssuesEvent();

  /// 대상 저장소와 이슈 목록을 처음부터 읽는다.
  const factory IssuesEvent.requested() = IssuesRequested;

  /// 목록만 다시 읽는다. 화면을 로딩으로 바꾸지 않는다. 끝나면 [done] 을 완료한다.
  const factory IssuesEvent.refreshed({Completer<void>? done}) =
      IssuesRefreshed;

  /// 이슈를 만든다.
  const factory IssuesEvent.created({
    required String title,
    String body,
    String? label,
  }) = IssueCreated;

  @override
  List<Object?> get props => [];
}

final class IssuesRequested extends IssuesEvent {
  const IssuesRequested();
}

final class IssuesRefreshed extends IssuesEvent {
  const IssuesRefreshed({this.done});

  final Completer<void>? done;

  @override
  List<Object?> get props => [done];
}

final class IssueCreated extends IssuesEvent {
  const IssueCreated({required this.title, this.body = '', this.label});

  final String title;
  final String body;
  final String? label;

  @override
  List<Object?> get props => [title, body, label];
}
