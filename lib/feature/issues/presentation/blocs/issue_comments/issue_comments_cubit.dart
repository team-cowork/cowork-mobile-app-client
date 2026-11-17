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
/// 먼저 목록 끝에 보이고, [refreshDelay] 뒤에 서버 목록으로 맞춘다.
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

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      emit(IssueCommentsState(comments: await _fetch()));
    } catch (e, s) {
      Logger.e('이슈 댓글 조회 실패', tag: 'Issues', error: e, stackTrace: s);
      emit(
        state.copyWith(
          loading: false,
          error: failureMessageOf(e, '댓글을 불러오지 못했어요.'),
        ),
      );
    }
  }

  Future<void> send(String message) async {
    final body = message.trim();
    if (body.isEmpty) return;
    try {
      await _repository.createComment(_target, issueNumber, body);
    } catch (e, s) {
      Logger.e('이슈 댓글 작성 실패', tag: 'Issues', error: e, stackTrace: s);
      emit(state.copyWith(error: failureMessageOf(e, '댓글을 남기지 못했어요.')));
      return;
    }
    emit(
      state.copyWith(
        comments: [
          ...state.comments,
          IssueComment(
            id: 'sending-${DateTime.now().microsecondsSinceEpoch}',
            author: '나',
            message: body,
            timestamp: '방금',
          ),
        ],
        clearError: true,
      ),
    );
    _refresh?.cancel();
    _refresh = Timer(refreshDelay, _syncSilently);
  }

  /// 서버 목록으로 맞춘다. 실패하면 보이던 댓글을 둔다.
  Future<void> _syncSilently() async {
    try {
      final comments = await _fetch();
      if (!isClosed) emit(IssueCommentsState(comments: comments));
    } catch (e, s) {
      Logger.e('이슈 댓글 새로고침 실패', tag: 'Issues', error: e, stackTrace: s);
    }
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
