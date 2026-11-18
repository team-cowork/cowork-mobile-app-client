// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InviteResponse _$InviteResponseFromJson(Map<String, dynamic> json) =>
    _InviteResponse(
      inviteCode: json['inviteCode'] as String,
      duration: InviteDuration.fromValue(json['duration'] as String?),
      expiresAt: _serverTimeOf(json['expiresAt'] as String?),
      expired: json['expired'] as bool? ?? false,
      createdAt: _serverTimeOf(json['createdAt'] as String?),
    );

Map<String, dynamic> _$InviteResponseToJson(_InviteResponse instance) =>
    <String, dynamic>{
      'inviteCode': instance.inviteCode,
      'duration': _$InviteDurationEnumMap[instance.duration],
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'expired': instance.expired,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$InviteDurationEnumMap = {
  InviteDuration.oneDay: 'oneDay',
  InviteDuration.sevenDays: 'sevenDays',
  InviteDuration.thirtyDays: 'thirtyDays',
  InviteDuration.never: 'never',
};
