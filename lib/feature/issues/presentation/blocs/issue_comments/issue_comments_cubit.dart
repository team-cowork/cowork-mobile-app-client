import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/logger.dart';
import '../../../data/model/issue_mapping.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../domain/issue_comment.dart';
import '../../../domain/issue_target.dart';

/// 이슈 댓글 상태를 관리하는 Cubit.
///
/// 댓글 작성은 서버가 접수만 확인하고 GitHub 에는 비동기로 만든다. 그래서 보낸 댓글을
/// 먼저 목록 끝에 보이고, [refreshDelay] 뒤에 서버 목록으로 맞춘다. 서버가 아직 그
/// 댓글을 목록에 넣지 않았으면 보낸 댓글은 남겨 두고, 최대 [maxSyncAttempts] 번 다시
/// 읽는다.
class IssueCommentsCubit extends Cubit<IssueCommentsState> {
  IssueCommentsCubit(
    this._repository,
    this._target,
    this.issueNumber, {
    this.refreshDelay = const Duration(seconds: 2),
  }) : super(const IssueCommentsState());

  final IssueRepository _repository;
  final IssueTarget _target;
  final int issueNumber;
  final Duration refreshDelay;
  Timer? _refresh;

  /// 서버가 목록에 넣는 데 걸리는 시간은 보장되지 않아 한 번 읽고 끝내지 않는다.
  static const maxSyncAttempts = 5;

  static const _sendingPrefix = 'sending-';

  /// 서버 목록에서 마지막으로 본 댓글 id. 보낸 댓글이 반영됐는지 가릴 때 쓴다.
  final _seenIds = <String>{};
  int _syncAttempts = 0;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final comments = await _fetch();
      if (isClosed) return;
      _remember(comments);
      emit(IssueCommentsState(comments: comments));
    } catch (e, s) {
      Logger.e('이슈 댓글 조회 실패', tag: 'Issues', error: e, stackTrace: s);
      if (isClosed) return;
      _fail('댓글을 불러오지 못했어요.', e, loading: false);
    }
  }

  /// 댓글을 보내고, 서버가 접수했으면 true 를 돌려준다. 입력창은 접수됐을 때만 비운다.
  Future<bool> send(String message) async {
    final body = message.trim();
    if (body.isEmpty) return false;
    try {
      await _repository.createComment(_target, issueNumber, body);
    } catch (e, s) {
      Logger.e('이슈 댓글 작성 실패', tag: 'Issues', error: e, stackTrace: s);
      if (!isClosed) _fail('댓글을 남기지 못했어요.', e);
      return false;
    }
    if (isClosed) return true;
    emit(
      state.copyWith(
        comments: [
          ...state.comments,
          IssueComment(
            id: '$_sendingPrefix${DateTime.now().microsecondsSinceEpoch}',
            author: '나',
            message: body,
            timestamp: '방금',
          ),
        ],
        clearError: true,
      ),
    );
    _syncAttempts = 0;
    _scheduleSync();
    return true;
  }

  /// 같은 사유로 연달아 실패해도 화면이 매번 알리게, 사유를 지운 상태를 먼저 낸다.
  void _fail(String fallback, Object error, {bool? loading}) {
    emit(state.copyWith(loading: loading, clearError: true));
    emit(state.copyWith(error: failureMessageOf(error, fallback)));
  }

  void _remember(List<IssueComment> comments) => _seenIds
    ..clear()
    ..addAll(comments.map((comment) => comment.id));

  void _scheduleSync() {
    _refresh?.cancel();
    _refresh = Timer(refreshDelay, _syncSilently);
  }

  /// 서버 목록으로 맞춘다. 서버에 아직 없는 보낸 댓글은 남기고 다시 읽는다. 실패하면
  /// 보이던 댓글을 둔다.
  Future<void> _syncSilently() async {
    try {
      final server = await _fetch();
      if (isClosed) return;
      // 처음 보는 서버 댓글이 보낸 댓글(본문이 같은 것) 하나를 대신한다.
      final fresh = [
        for (final comment in server)
          if (!_seenIds.contains(comment.id)) comment.message,
      ];
      final unsynced = [
        for (final comment in state.comments)
          if (comment.id.startsWith(_sendingPrefix) &&
              !fresh.remove(comment.message))
            comment,
      ];
      _remember(server);
      emit(IssueCommentsState(comments: [...server, ...unsynced]));
      if (unsynced.isNotEmpty) _retrySync();
    } catch (e, s) {
      Logger.e('이슈 댓글 새로고침 실패', tag: 'Issues', error: e, stackTrace: s);
      if (!isClosed &&
          state.comments.any((c) => c.id.startsWith(_sendingPrefix))) {
        _retrySync();
      }
    }
  }

  void _retrySync() {
    if (++_syncAttempts < maxSyncAttempts) _scheduleSync();
  }

  Future<List<IssueComment>> _fetch() async => [
    for (final comment in await _repository.fetchComments(_target, issueNumber))
      issueCommentOf(comment),
  ];

  @override
  Future<void> close() {
    _refresh?.cancel();
    return super.close();
  }
}

class IssueCommentsState extends Equatable {
  const IssueCommentsState({
    this.comments = const [],
    this.loading = false,
    this.error,
  });

  final List<IssueComment> comments;
  final bool loading;

  /// 댓글을 읽거나 남기지 못한 사유. 화면이 스낵바로 알린다.
  final String? error;

  IssueCommentsState copyWith({
    List<IssueComment>? comments,
    bool? loading,
    String? error,
    bool clearError = false,
  }) => IssueCommentsState(
    comments: comments ?? this.comments,
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [comments, loading, error];
}
