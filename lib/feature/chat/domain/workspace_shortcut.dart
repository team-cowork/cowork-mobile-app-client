import 'package:equatable/equatable.dart';

import 'enums/workspace_avatar_color.dart';

class WorkspaceShortcut extends Equatable {
  const WorkspaceShortcut({
    required this.id,
    required this.initial,
    required this.color,
    this.isSelected = false,
  });

  final String id;
  final String initial;
  final WorkspaceAvatarColor color;
  final bool isSelected;

  @override
  List<Object?> get props => [id, initial, color, isSelected];
}
