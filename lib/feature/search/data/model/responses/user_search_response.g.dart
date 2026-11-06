// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSearchResponse _$UserSearchResponseFromJson(Map<String, dynamic> json) =>
    _UserSearchResponse(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hasNext: json['has_next'] as bool? ?? false,
    );

Map<String, dynamic> _$UserSearchResponseToJson(_UserSearchResponse instance) =>
    <String, dynamic>{'items': instance.items, 'has_next': instance.hasNext};
