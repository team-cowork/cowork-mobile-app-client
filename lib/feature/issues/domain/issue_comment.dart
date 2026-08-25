import 'package:equatable/equatable.dart';

import '../../profile/domain/profile_entity.dart';

class IssueComment extends Equatable {
  const IssueComment({
    required this.id,
    required this.author,
    required this.message,
    required this.timestamp,
  });

  final String id;
  final ProfileEntity author;
  final String message;
  final String timestamp;

  @override
  List<Object?> get props => [id, author, message, timestamp];
}
