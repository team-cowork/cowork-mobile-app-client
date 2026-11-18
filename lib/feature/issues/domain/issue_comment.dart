import 'package:equatable/equatable.dart';

/// 이슈 댓글 하나.
class IssueComment extends Equatable {
  const IssueComment({
    required this.id,
    required this.author,
    required this.message,
    required this.timestamp,
  });

  final String id;

  /// 작성자 GitHub 사용자명.
  final String author;
  final String message;
  final String timestamp;

  @override
  List<Object?> get props => [id, author, message, timestamp];
}
