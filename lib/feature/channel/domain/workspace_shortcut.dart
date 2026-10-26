import 'package:equatable/equatable.dart';

import 'enums/workspace_avatar_color.dart';

class WorkspaceShortcut extends Equatable {
  const WorkspaceShortcut({
    required this.id,
    required this.initial,
    required this.color,
    this.isSelected = false,
  });

  /// 팀 id. 누르면 이 팀으로 홈을 바꾼다.
  final int id;
  final String initial;
  final WorkspaceAvatarColor color;
  final bool isSelected;

  @override
  List<Object?> get props => [id, initial, color, isSelected];
}
