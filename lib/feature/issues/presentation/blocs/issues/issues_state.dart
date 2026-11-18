part of 'issues_bloc.dart';

typedef IssuesState = AsyncState<IssuesData>;

/// 이슈 목록 화면의 데이터. 연결된 저장소가 없으면 [target] 이 null 이다.
class IssuesData extends Equatable {
  const IssuesData({
    required this.target,
    required this.issues,
    this.errorMessage,
  });

  final IssueTarget? target;
  final List<Issue> issues;

  /// 이슈를 만들지 못한 사유. 화면이 스낵바로 알린다.
  final String? errorMessage;

  IssuesData withError(String message) =>
      IssuesData(target: target, issues: issues, errorMessage: message);

  @override
  List<Object?> get props => [target, issues, errorMessage];
}
