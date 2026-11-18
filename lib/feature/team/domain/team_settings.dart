import 'package:equatable/equatable.dart';

/// 팀 설정 화면이 그리는 팀 정보와, 내가 할 수 있는 일.
class TeamSettings extends Equatable {
  const TeamSettings({
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.canManage,
    required this.canDelete,
    this.uploadingIcon = false,
  });

  final String name;

  /// 없으면 빈 문자열.
  final String description;

  /// 아이콘이 없으면 null.
  final String? iconUrl;

  /// 이름·설명·아이콘을 바꿀 수 있는지. (`manage_team`)
  final bool canManage;

  /// 팀을 지울 수 있는지. (`delete_team`)
  final bool canDelete;

  /// 새 아이콘을 올리는 중인지. 그동안 아이콘 버튼을 잠근다.
  final bool uploadingIcon;

  /// [clearIcon] 이 true 면 [iconUrl] 을 무시하고 아이콘을 비운다.
  TeamSettings copyWith({
    String? name,
    String? description,
    String? iconUrl,
    bool clearIcon = false,
    bool? uploadingIcon,
  }) => TeamSettings(
    name: name ?? this.name,
    description: description ?? this.description,
    iconUrl: clearIcon ? null : iconUrl ?? this.iconUrl,
    canManage: canManage,
    canDelete: canDelete,
    uploadingIcon: uploadingIcon ?? this.uploadingIcon,
  );

  @override
  List<Object?> get props => [
    name,
    description,
    iconUrl,
    canManage,
    canDelete,
    uploadingIcon,
  ];
}
