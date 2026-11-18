part of 'team_settings_bloc.dart';

sealed class TeamSettingsEvent extends Equatable {
  const TeamSettingsEvent();

  /// 설정을 처음 불러온다. 다시 시도에도 쓴다.
  const factory TeamSettingsEvent.requested() = TeamSettingsRequested;

  /// 읽지 못한 내 권한만 다시 읽는다. 팀 정보는 그대로 둔다.
  const factory TeamSettingsEvent.permissionsRetried() =
      TeamSettingsPermissionsRetried;

  /// 팀 이름을 바꾼다. 앞뒤 공백을 떼고 비면 무시한다.
  const factory TeamSettingsEvent.nameChanged(String name) =
      TeamSettingsNameChanged;

  /// 팀 설명을 바꾼다. 비우는 것도 바꾸는 것이다.
  const factory TeamSettingsEvent.descriptionChanged(String description) =
      TeamSettingsDescriptionChanged;

  /// 갤러리에서 고른 사진([path])을 새 팀 아이콘으로 올린다.
  const factory TeamSettingsEvent.iconPicked(String path) =
      TeamSettingsIconPicked;

  /// 팀 아이콘을 지운다.
  const factory TeamSettingsEvent.iconRemoved() = TeamSettingsIconRemoved;

  @override
  List<Object?> get props => [];
}

final class TeamSettingsRequested extends TeamSettingsEvent {
  const TeamSettingsRequested();
}

final class TeamSettingsPermissionsRetried extends TeamSettingsEvent {
  const TeamSettingsPermissionsRetried();
}

final class TeamSettingsNameChanged extends TeamSettingsEvent {
  const TeamSettingsNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class TeamSettingsDescriptionChanged extends TeamSettingsEvent {
  const TeamSettingsDescriptionChanged(this.description);

  final String description;

  @override
  List<Object?> get props => [description];
}

final class TeamSettingsIconPicked extends TeamSettingsEvent {
  const TeamSettingsIconPicked(this.path);

  final String path;

  @override
  List<Object?> get props => [path];
}

final class TeamSettingsIconRemoved extends TeamSettingsEvent {
  const TeamSettingsIconRemoved();
}
