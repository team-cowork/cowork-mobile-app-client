// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserResponse _$UserResponseFromJson(Map<String, dynamic> json) =>
    _UserResponse(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      nickname: json['nickname'] as String?,
      status: json['status'] as String?,
      customStatus: json['custom_status'] as String?,
      statusMessage: json['status_message'] as String?,
      statusExpiresAt: json['status_expires_at'] as String?,
      description: json['description'] as String?,
      accountDescription: json['account_description'] as String?,
      specialty: json['specialty'] as String?,
      major: json['major'] as String?,
      studentNumber: json['student_number'] as String?,
      studentRole: json['student_role'] as String?,
      githubId: json['github_id'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      sex: json['sex'] as String?,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$UserResponseToJson(_UserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'nickname': instance.nickname,
      'status': instance.status,
      'custom_status': instance.customStatus,
      'status_message': instance.statusMessage,
      'status_expires_at': instance.statusExpiresAt,
      'description': instance.description,
      'account_description': instance.accountDescription,
      'specialty': instance.specialty,
      'major': instance.major,
      'student_number': instance.studentNumber,
      'student_role': instance.studentRole,
      'github_id': instance.githubId,
      'profile_image_url': instance.profileImageUrl,
      'sex': instance.sex,
      'roles': instance.roles,
    };
