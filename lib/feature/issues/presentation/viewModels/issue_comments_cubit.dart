import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/data/profile_store.dart';
import '../../../profile/domain/profile_entity.dart';
import '../../data/issue_comments_store.dart';
import '../../domain/issue_comment.dart';

class IssueCommentsCubit extends Cubit<List<IssueComment>> {
  IssueCommentsCubit(this.issueNumber)
    : super(IssueCommentsStore.instance.commentsFor(issueNumber));

  final int issueNumber;

  void addComment(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    final profile = ProfileStore.instance;
    final comment = IssueComment(
      id: 'comment-$issueNumber-${DateTime.now().microsecondsSinceEpoch}',
      author: ProfileEntity(
        id: profile.currentUserId,
        name: profile.name,
        avatarInitial: profile.avatarInitial,
        avatarUrl: profile.avatarUrl,
      ),
      message: trimmed,
      timestamp: '방금',
    );

    IssueCommentsStore.instance.addComment(issueNumber, comment);
    emit([...state, comment]);
  }
}
