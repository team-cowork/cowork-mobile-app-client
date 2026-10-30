// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting_note_template_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeetingNoteTemplateResponse {

/// 없으면 fromJson 이 던진다.
 int get id; int get channelId; String get name;/// 채널에서 켜져 있는 템플릿인지. 채널마다 하나다.
 bool get isActive; List<TemplateSectionResponse> get sections;
/// Create a copy of MeetingNoteTemplateResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeetingNoteTemplateResponseCopyWith<MeetingNoteTemplateResponse> get copyWith => _$MeetingNoteTemplateResponseCopyWithImpl<MeetingNoteTemplateResponse>(this as MeetingNoteTemplateResponse, _$identity);

  /// Serializes this MeetingNoteTemplateResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeetingNoteTemplateResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.sections, sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,name,isActive,const DeepCollectionEquality().hash(sections));

@override
String toString() {
  return 'MeetingNoteTemplateResponse(id: $id, channelId: $channelId, name: $name, isActive: $isActive, sections: $sections)';
}


}

/// @nodoc
abstract mixin class $MeetingNoteTemplateResponseCopyWith<$Res>  {
  factory $MeetingNoteTemplateResponseCopyWith(MeetingNoteTemplateResponse value, $Res Function(MeetingNoteTemplateResponse) _then) = _$MeetingNoteTemplateResponseCopyWithImpl;
@useResult
$Res call({
 int id, int channelId, String name, bool isActive, List<TemplateSectionResponse> sections
});




}
/// @nodoc
class _$MeetingNoteTemplateResponseCopyWithImpl<$Res>
    implements $MeetingNoteTemplateResponseCopyWith<$Res> {
  _$MeetingNoteTemplateResponseCopyWithImpl(this._self, this._then);

  final MeetingNoteTemplateResponse _self;
  final $Res Function(MeetingNoteTemplateResponse) _then;

/// Create a copy of MeetingNoteTemplateResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? name = null,Object? isActive = null,Object? sections = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<TemplateSectionResponse>,
  ));
}

}


/// Adds pattern-matching-related methods to [MeetingNoteTemplateResponse].
extension MeetingNoteTemplateResponsePatterns on MeetingNoteTemplateResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeetingNoteTemplateResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeetingNoteTemplateResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeetingNoteTemplateResponse value)  $default,){
final _that = this;
switch (_that) {
case _MeetingNoteTemplateResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeetingNoteTemplateResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MeetingNoteTemplateResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int channelId,  String name,  bool isActive,  List<TemplateSectionResponse> sections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeetingNoteTemplateResponse() when $default != null:
return $default(_that.id,_that.channelId,_that.name,_that.isActive,_that.sections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int channelId,  String name,  bool isActive,  List<TemplateSectionResponse> sections)  $default,) {final _that = this;
switch (_that) {
case _MeetingNoteTemplateResponse():
return $default(_that.id,_that.channelId,_that.name,_that.isActive,_that.sections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int channelId,  String name,  bool isActive,  List<TemplateSectionResponse> sections)?  $default,) {final _that = this;
switch (_that) {
case _MeetingNoteTemplateResponse() when $default != null:
return $default(_that.id,_that.channelId,_that.name,_that.isActive,_that.sections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeetingNoteTemplateResponse extends MeetingNoteTemplateResponse {
  const _MeetingNoteTemplateResponse({required this.id, required this.channelId, this.name = '', this.isActive = false, final  List<TemplateSectionResponse> sections = const []}): _sections = sections,super._();
  factory _MeetingNoteTemplateResponse.fromJson(Map<String, dynamic> json) => _$MeetingNoteTemplateResponseFromJson(json);

/// 없으면 fromJson 이 던진다.
@override final  int id;
@override final  int channelId;
@override@JsonKey() final  String name;
/// 채널에서 켜져 있는 템플릿인지. 채널마다 하나다.
@override@JsonKey() final  bool isActive;
 final  List<TemplateSectionResponse> _sections;
@override@JsonKey() List<TemplateSectionResponse> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}


/// Create a copy of MeetingNoteTemplateResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeetingNoteTemplateResponseCopyWith<_MeetingNoteTemplateResponse> get copyWith => __$MeetingNoteTemplateResponseCopyWithImpl<_MeetingNoteTemplateResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeetingNoteTemplateResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeetingNoteTemplateResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other._sections, _sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,name,isActive,const DeepCollectionEquality().hash(_sections));

@override
String toString() {
  return 'MeetingNoteTemplateResponse(id: $id, channelId: $channelId, name: $name, isActive: $isActive, sections: $sections)';
}


}

/// @nodoc
abstract mixin class _$MeetingNoteTemplateResponseCopyWith<$Res> implements $MeetingNoteTemplateResponseCopyWith<$Res> {
  factory _$MeetingNoteTemplateResponseCopyWith(_MeetingNoteTemplateResponse value, $Res Function(_MeetingNoteTemplateResponse) _then) = __$MeetingNoteTemplateResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int channelId, String name, bool isActive, List<TemplateSectionResponse> sections
});




}
/// @nodoc
class __$MeetingNoteTemplateResponseCopyWithImpl<$Res>
    implements _$MeetingNoteTemplateResponseCopyWith<$Res> {
  __$MeetingNoteTemplateResponseCopyWithImpl(this._self, this._then);

  final _MeetingNoteTemplateResponse _self;
  final $Res Function(_MeetingNoteTemplateResponse) _then;

/// Create a copy of MeetingNoteTemplateResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? name = null,Object? isActive = null,Object? sections = null,}) {
  return _then(_MeetingNoteTemplateResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<TemplateSectionResponse>,
  ));
}


}

// dart format on
