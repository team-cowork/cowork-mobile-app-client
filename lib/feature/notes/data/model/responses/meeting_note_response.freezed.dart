// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting_note_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeetingNoteResponse {

 int get id;/// 회의록이 속한 채널. 수정·삭제 경로에 필요해 같이 들고 다닌다.
 int get channelId;/// 회의록을 쓸 때 고른 템플릿. 편집 화면이 섹션 형식을 여기서 읽는다.
 int get templateId; String get title;/// 섹션 이름 → 내용. 예: `{'안건': '1. ...', '결정 사항': '· ...'}`.
@JsonKey(name: 'content', fromJson: parseNoteContent) Map<String, String> get sections;/// 작성자 사용자 id. 이름·사진은 `/users/{id}` 에서 따로 읽는다.
 int get createdBy;/// 정렬에만 쓰므로 못 읽으면 맨 뒤로 보낸다.
@JsonKey(fromJson: _createdAtOf) DateTime get createdAt;
/// Create a copy of MeetingNoteResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeetingNoteResponseCopyWith<MeetingNoteResponse> get copyWith => _$MeetingNoteResponseCopyWithImpl<MeetingNoteResponse>(this as MeetingNoteResponse, _$identity);

  /// Serializes this MeetingNoteResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeetingNoteResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.sections, sections)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,templateId,title,const DeepCollectionEquality().hash(sections),createdBy,createdAt);

@override
String toString() {
  return 'MeetingNoteResponse(id: $id, channelId: $channelId, templateId: $templateId, title: $title, sections: $sections, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MeetingNoteResponseCopyWith<$Res>  {
  factory $MeetingNoteResponseCopyWith(MeetingNoteResponse value, $Res Function(MeetingNoteResponse) _then) = _$MeetingNoteResponseCopyWithImpl;
@useResult
$Res call({
 int id, int channelId, int templateId, String title,@JsonKey(name: 'content', fromJson: parseNoteContent) Map<String, String> sections, int createdBy,@JsonKey(fromJson: _createdAtOf) DateTime createdAt
});




}
/// @nodoc
class _$MeetingNoteResponseCopyWithImpl<$Res>
    implements $MeetingNoteResponseCopyWith<$Res> {
  _$MeetingNoteResponseCopyWithImpl(this._self, this._then);

  final MeetingNoteResponse _self;
  final $Res Function(MeetingNoteResponse) _then;

/// Create a copy of MeetingNoteResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? templateId = null,Object? title = null,Object? sections = null,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as Map<String, String>,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MeetingNoteResponse].
extension MeetingNoteResponsePatterns on MeetingNoteResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeetingNoteResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeetingNoteResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeetingNoteResponse value)  $default,){
final _that = this;
switch (_that) {
case _MeetingNoteResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeetingNoteResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MeetingNoteResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int channelId,  int templateId,  String title, @JsonKey(name: 'content', fromJson: parseNoteContent)  Map<String, String> sections,  int createdBy, @JsonKey(fromJson: _createdAtOf)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeetingNoteResponse() when $default != null:
return $default(_that.id,_that.channelId,_that.templateId,_that.title,_that.sections,_that.createdBy,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int channelId,  int templateId,  String title, @JsonKey(name: 'content', fromJson: parseNoteContent)  Map<String, String> sections,  int createdBy, @JsonKey(fromJson: _createdAtOf)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MeetingNoteResponse():
return $default(_that.id,_that.channelId,_that.templateId,_that.title,_that.sections,_that.createdBy,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int channelId,  int templateId,  String title, @JsonKey(name: 'content', fromJson: parseNoteContent)  Map<String, String> sections,  int createdBy, @JsonKey(fromJson: _createdAtOf)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MeetingNoteResponse() when $default != null:
return $default(_that.id,_that.channelId,_that.templateId,_that.title,_that.sections,_that.createdBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeetingNoteResponse extends MeetingNoteResponse {
  const _MeetingNoteResponse({this.id = 0, this.channelId = 0, this.templateId = 0, this.title = '', @JsonKey(name: 'content', fromJson: parseNoteContent) final  Map<String, String> sections = const {}, this.createdBy = 0, @JsonKey(fromJson: _createdAtOf) required this.createdAt}): _sections = sections,super._();
  factory _MeetingNoteResponse.fromJson(Map<String, dynamic> json) => _$MeetingNoteResponseFromJson(json);

@override@JsonKey() final  int id;
/// 회의록이 속한 채널. 수정·삭제 경로에 필요해 같이 들고 다닌다.
@override@JsonKey() final  int channelId;
/// 회의록을 쓸 때 고른 템플릿. 편집 화면이 섹션 형식을 여기서 읽는다.
@override@JsonKey() final  int templateId;
@override@JsonKey() final  String title;
/// 섹션 이름 → 내용. 예: `{'안건': '1. ...', '결정 사항': '· ...'}`.
 final  Map<String, String> _sections;
/// 섹션 이름 → 내용. 예: `{'안건': '1. ...', '결정 사항': '· ...'}`.
@override@JsonKey(name: 'content', fromJson: parseNoteContent) Map<String, String> get sections {
  if (_sections is EqualUnmodifiableMapView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sections);
}

/// 작성자 사용자 id. 이름·사진은 `/users/{id}` 에서 따로 읽는다.
@override@JsonKey() final  int createdBy;
/// 정렬에만 쓰므로 못 읽으면 맨 뒤로 보낸다.
@override@JsonKey(fromJson: _createdAtOf) final  DateTime createdAt;

/// Create a copy of MeetingNoteResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeetingNoteResponseCopyWith<_MeetingNoteResponse> get copyWith => __$MeetingNoteResponseCopyWithImpl<_MeetingNoteResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeetingNoteResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeetingNoteResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._sections, _sections)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,templateId,title,const DeepCollectionEquality().hash(_sections),createdBy,createdAt);

@override
String toString() {
  return 'MeetingNoteResponse(id: $id, channelId: $channelId, templateId: $templateId, title: $title, sections: $sections, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MeetingNoteResponseCopyWith<$Res> implements $MeetingNoteResponseCopyWith<$Res> {
  factory _$MeetingNoteResponseCopyWith(_MeetingNoteResponse value, $Res Function(_MeetingNoteResponse) _then) = __$MeetingNoteResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int channelId, int templateId, String title,@JsonKey(name: 'content', fromJson: parseNoteContent) Map<String, String> sections, int createdBy,@JsonKey(fromJson: _createdAtOf) DateTime createdAt
});




}
/// @nodoc
class __$MeetingNoteResponseCopyWithImpl<$Res>
    implements _$MeetingNoteResponseCopyWith<$Res> {
  __$MeetingNoteResponseCopyWithImpl(this._self, this._then);

  final _MeetingNoteResponse _self;
  final $Res Function(_MeetingNoteResponse) _then;

/// Create a copy of MeetingNoteResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? templateId = null,Object? title = null,Object? sections = null,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_MeetingNoteResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as Map<String, String>,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
