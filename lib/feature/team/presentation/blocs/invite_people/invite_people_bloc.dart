import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../search/data/repositories/search_repository.dart';
import '../../../../search/domain/search_result.dart';
import '../../../data/repositories/team_repository.dart';

part 'invite_people_event.dart';
part 'invite_people_state.dart';

/// [teamId] 팀에 바로 넣을 사람을 찾아 고르고 초대하는 Bloc.
///
/// 웹 `팀원 초대` 모달과 같은 흐름이다. 이름·닉네임으로 모든 사용자에서 찾고, 이미
/// 멤버인 사람과 고른 사람은 결과에서 뺀다. 초대하면 서버가 받는 쪽 수락 없이 바로
/// 멤버로 넣는다.
class InvitePeopleBloc extends Bloc<InvitePeopleEvent, InvitePeopleState> {
  InvitePeopleBloc({
    required TeamRepository teams,
    required SearchRepository search,
    required this.teamId,
  }) : _teams = teams,
       _search = search,
       super(const InvitePeopleState()) {
    on<InvitePeopleStarted>(_onStarted);
    on<InvitePeopleSearched>(_onSearched);
    on<InvitePersonToggled>(_onToggled);
    on<InvitePeopleSubmitted>(_onSubmitted);
  }

  final TeamRepository _teams;
  final SearchRepository _search;
  final int teamId;

  /// 마지막으로 보낸 검색 번호. 검색어를 빠르게 바꾸면 이전 검색 응답이 늦게 올 수
  /// 있어, 이 번호가 아닌 응답은 버린다.
  int _generation = 0;

  /// 이미 멤버인 사람을 결과에서 빼려고 멤버 목록을 읽는다.
  ///
  /// 못 읽어도 초대는 할 수 있다(서버가 이미 멤버인 사람은 건너뛴다). 결과에 멤버가
  /// 섞여 보일 뿐이라 화면에 실패를 알리지 않는다.
  Future<void> _onStarted(
    InvitePeopleStarted event,
    Emitter<InvitePeopleState> emit,
  ) async {
    try {
      final members = await _teams.fetchMembers(teamId);
      emit(
        state.copyWith(
          memberIds: {
            ...state.memberIds,
            for (final member in members) member.userId,
          },
        ),
      );
    } catch (e, s) {
      Logger.e('팀 멤버 조회 실패', tag: 'Team', error: e, stackTrace: s);
    }
  }

  Future<void> _onSearched(
    InvitePeopleSearched event,
    Emitter<InvitePeopleState> emit,
  ) async {
    final generation = ++_generation;
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(state.copyWith(query: '', results: const AsyncState.initial()));
      return;
    }
    emit(state.copyWith(query: query, results: const AsyncState.loading()));
    try {
      final people = await _search.searchPeople(query: query);
      if (generation != _generation) return;
      emit(state.copyWith(results: AsyncState.success(people)));
    } catch (e, s) {
      Logger.e('사용자 검색 실패', tag: 'Team', error: e, stackTrace: s);
      if (generation != _generation) return;
      emit(state.copyWith(results: AsyncState.failure(failureMessageOf(e))));
    }
  }

  /// 고르지 않은 사람이면 고르고, 고른 사람이면 뺀다.
  void _onToggled(InvitePersonToggled event, Emitter<InvitePeopleState> emit) {
    // 보내는 중에 고른 사람을 바꾸면 무엇을 초대했는지 어긋난다.
    if (state.submission is AsyncLoading) return;
    final person = event.person;
    final selected = state.selected.any((p) => p.id == person.id)
        ? [
            for (final p in state.selected)
              if (p.id != person.id) p,
          ]
        : [...state.selected, person];
    emit(state.copyWith(selected: selected));
  }

  /// 고른 사람을 초대한다. 성공하면 그 사람들을 멤버로 보고 고른 목록을 비운다.
  ///
  /// id 를 숫자로 못 읽은 사람은 보낼 수 없어 빠진다. 성공 인원은 실제로 보낸 수로
  /// 세고, 보낼 사람이 하나도 없으면 빈 요청을 보내지 않고 실패로 알린다.
  Future<void> _onSubmitted(
    InvitePeopleSubmitted event,
    Emitter<InvitePeopleState> emit,
  ) async {
    if (state.submission is AsyncLoading || state.selected.isEmpty) return;
    final userIds = [
      for (final person in state.selected) ?int.tryParse(person.id),
    ];
    if (userIds.isEmpty) {
      Logger.d('초대할 사용자 id 를 읽지 못함', tag: 'Team');
      emit(
        state.copyWith(
          submission: const AsyncState.failure('고른 사람을 초대할 수 없어요.'),
        ),
      );
      return;
    }
    emit(state.copyWith(submission: const AsyncState.loading()));
    try {
      await _teams.inviteMembers(teamId, userIds);
    } catch (e, s) {
      Logger.e('멤버 초대 실패', tag: 'Team', error: e, stackTrace: s);
      emit(state.copyWith(submission: AsyncState.failure(failureMessageOf(e))));
      return;
    }
    emit(
      state.copyWith(
        selected: const [],
        memberIds: {...state.memberIds, ...userIds},
        submission: AsyncState.success(userIds.length),
      ),
    );
  }
}
