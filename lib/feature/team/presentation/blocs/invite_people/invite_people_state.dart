part of 'invite_people_bloc.dart';

final class InvitePeopleState extends Equatable {
  const InvitePeopleState({
    this.query = '',
    this.results = const AsyncState.initial(),
    this.selected = const [],
    this.memberIds = const {},
    this.submission = const AsyncState.initial(),
  });

  /// 마지막으로 찾은 검색어. 앞뒤 공백은 자른 값이다.
  final String query;

  /// 검색 결과 그대로. 화면에는 [candidates] 를 보여 준다. 검색어가 없으면 initial.
  final AsyncState<List<SearchPersonResult>> results;

  /// 초대하려고 고른 사람. 고른 순서대로.
  final List<SearchPersonResult> selected;

  /// 이미 팀 멤버인 사용자 id. 이 화면에서 초대한 사람도 들어간다.
  final Set<int> memberIds;

  /// 마지막 초대 요청. 성공이면 초대한 사람 수를 담는다.
  final AsyncState<int> submission;

  /// 결과 중 고를 수 있는 사람. 이미 멤버이거나 이미 고른 사람은 뺀다.
  List<SearchPersonResult> get candidates => switch (results) {
    AsyncSuccess(:final data) => [
      for (final person in data)
        if (!memberIds.contains(int.tryParse(person.id)) &&
            !selected.any((p) => p.id == person.id))
          person,
    ],
    _ => const [],
  };

  InvitePeopleState copyWith({
    String? query,
    AsyncState<List<SearchPersonResult>>? results,
    List<SearchPersonResult>? selected,
    Set<int>? memberIds,
    AsyncState<int>? submission,
  }) => InvitePeopleState(
    query: query ?? this.query,
    results: results ?? this.results,
    selected: selected ?? this.selected,
    memberIds: memberIds ?? this.memberIds,
    submission: submission ?? this.submission,
  );

  @override
  List<Object?> get props => [query, results, selected, memberIds, submission];
}
