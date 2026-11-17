// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_thread_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateThreadRequest _$UpdateThreadRequestFromJson(Map<String, dynamic> json) =>
    _UpdateThreadRequest(
      name: json['name'] as String?,
      isArchived: json['isArchived'] as bool?,
    );

Map<String, dynamic> _$UpdateThreadRequestToJson(
  _UpdateThreadRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'isArchived': ?instance.isArchived,
};
