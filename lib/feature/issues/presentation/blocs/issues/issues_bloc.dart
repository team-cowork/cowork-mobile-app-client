import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../data/model/issue_mapping.dart';
import '../../../data/model/requests/create_issue_request.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../domain/issue.dart';
import '../../../domain/issue_target.dart';

part 'issues_event.dart';
part 'issues_state.dart';

/// 이슈 목록 화면 상태를 관리하는 Bloc.
///
/// 이슈를 만드는 요청은 서버가 접수만 확인하고 GitHub 에는 비동기로 만든다. 그래서
/// 요청 직후엔 목록에 안 보일 수 있어, [refreshDelay] 뒤에 한 번 더 읽는다.
class IssuesBloc extends Bloc<IssuesEvent, IssuesState> {
  IssuesBloc(this._repository, {this.refreshDelay = const Duration(seconds: 2)})
    : super(const IssuesState.initial()) {
    on<IssuesRequested>(_onLoad);
    on<IssuesRefreshed>(_onRefresh);
    on<IssueCreated>(_onCreate);
  }

  final IssueRepository _repository;
  final Duration refreshDelay;
  Timer? _refresh;

  IssuesData? get _data => switch (state) {
    AsyncSuccess<IssuesData>(:final data) => data,
    _ => null,
  };

  Future<void> _onLoad(IssuesRequested event, Emitter<IssuesState> emit) async {
    emit(const IssuesState.loading());
    try {
      final target = await _repository.fetchTarget();
      emit(
        IssuesState.success(
          target == null
              ? const IssuesData(target: null, issues: [])
              : IssuesData(target: target, issues: await _fetch(target)),
        ),
      );
    } catch (e, s) {
      Logger.e('이슈 조회 실패', tag: 'Issues', error: e, stackTrace: s);
      emit(IssuesState.failure(failureMessageOf(e)));
    }
  }

  /// 목록만 조용히 다시 읽는다. 실패하면 보던 목록을 둔다.
  Future<void> _onRefresh(
    IssuesRefreshed event,
    Emitter<IssuesState> emit,
  ) async {
    final target = _data?.target;
    if (target == null) {
      event.done?.complete();
      return;
    }
    try {
      final issues = await _fetch(target);
      if (!isClosed) {
        emit(IssuesState.success(IssuesData(target: target, issues: issues)));
      }
    } catch (e, s) {
      Logger.e('이슈 새로고침 실패', tag: 'Issues', error: e, stackTrace: s);
    } finally {
      event.done?.complete();
    }
  }

  Future<void> _onCreate(IssueCreated event, Emitter<IssuesState> emit) async {
    final data = _data;
    final target = data?.target;
    if (data == null || target == null) return;
    try {
      await _repository.createIssue(
        target,
        CreateIssueRequest(
          title: event.title.trim(),
          body: event.body.trim().isEmpty ? null : event.body.trim(),
          label: event.label,
        ),
      );
      _refresh?.cancel();
      _refresh = Timer(refreshDelay, () {
        if (!isClosed) add(const IssuesRefreshed());
      });
    } catch (e, s) {
      Logger.e('이슈 생성 실패', tag: 'Issues', error: e, stackTrace: s);
      // 같은 사유로 연달아 실패해도 화면이 매번 알리게 사유 없는 상태를 먼저 낸다.
      emit(IssuesState.success(data));
      emit(
        IssuesState.success(
          data.withError(failureMessageOf(e, '이슈를 만들지 못했어요.')!),
        ),
      );
    }
  }

  Future<List<Issue>> _fetch(IssueTarget target) async => [
    for (final issue in await _repository.fetchIssues(target)) issueOf(issue),
  ];

  @override
  Future<void> close() {
    _refresh?.cancel();
    return super.close();
  }
}
