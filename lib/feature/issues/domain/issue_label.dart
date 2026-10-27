import 'package:equatable/equatable.dart';

import 'enums/issue_tag_color.dart';

class IssueLabel extends Equatable {
  const IssueLabel({required this.name, this.color});

  final String name;

  /// null이면 중립 배지(카테고리 없는 보조 태그)로 표시한다.
  final IssueTagColor? color;

  @override
  List<Object?> get props => [name, color];
}
