// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_meeting_note_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateMeetingNoteRequest {

 String get title;/// 섹션 제목 → 내용. 서버에는 JSON 문자열 `content` 로 간다.
@JsonKey(name: 'content', toJson: encodeNoteContent) Map<String, String> get sections;
/// Create a copy of UpdateMeetingNoteRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateMeetingNoteRequestCopyWith<UpdateMeetingNoteRequest> get copyWith => _$UpdateMeetingNoteRequestCopyWithImpl<UpdateMeetingNoteRequest>(this as UpdateMeetingNoteRequest, _$identity);

  /// Serializes this UpdateMeetingNoteRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateMeetingNoteRequest&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.sections, sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(sections));

@override
String toString() {
  return 'UpdateMeetingNoteRequest(title: $title, sections: $sections)';
}


}

/// @nodoc
abstract mixin class $UpdateMeetingNoteRequestCopyWith<$Res>  {
  factory $UpdateMeetingNoteRequestCopyWith(UpdateMeetingNoteRequest value, $Res Function(UpdateMeetingNoteRequest) _then) = _$UpdateMeetingNoteRequestCopyWithImpl;
@useResult
$Res call({
 String title,@JsonKey(name: 'content', toJson: encodeNoteContent) Map<String, String> sections
});




}
/// @nodoc
class _$UpdateMeetingNoteRequestCopyWithImpl<$Res>
    implements $UpdateMeetingNoteRequestCopyWith<$Res> {
  _$UpdateMeetingNoteRequestCopyWithImpl(this._self, this._then);

  final UpdateMeetingNoteRequest _self;
  final $Res Function(UpdateMeetingNoteRequest) _then;

/// Create a copy of UpdateMeetingNoteRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? sections = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateMeetingNoteRequest].
extension UpdateMeetingNoteRequestPatterns on UpdateMeetingNoteRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateMeetingNoteRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateMeetingNoteRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateMeetingNoteRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateMeetingNoteRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateMeetingNoteRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateMeetingNoteRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title, @JsonKey(name: 'content', toJson: encodeNoteContent)  Map<String, String> sections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateMeetingNoteRequest() when $default != null:
return $default(_that.title,_that.sections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title, @JsonKey(name: 'content', toJson: encodeNoteContent)  Map<String, String> sections)  $default,) {final _that = this;
switch (_that) {
case _UpdateMeetingNoteRequest():
return $default(_that.title,_that.sections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title, @JsonKey(name: 'content', toJson: encodeNoteContent)  Map<String, String> sections)?  $default,) {final _that = this;
switch (_that) {
case _UpdateMeetingNoteRequest() when $default != null:
return $default(_that.title,_that.sections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _UpdateMeetingNoteRequest implements UpdateMeetingNoteRequest {
  const _UpdateMeetingNoteRequest({required this.title, @JsonKey(name: 'content', toJson: encodeNoteContent) required final  Map<String, String> sections}): _sections = sections;
  

@override final  String title;
/// 섹션 제목 → 내용. 서버에는 JSON 문자열 `content` 로 간다.
 final  Map<String, String> _sections;
/// 섹션 제목 → 내용. 서버에는 JSON 문자열 `content` 로 간다.
@override@JsonKey(name: 'content', toJson: encodeNoteContent) Map<String, String> get sections {
  if (_sections is EqualUnmodifiableMapView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sections);
}


/// Create a copy of UpdateMeetingNoteRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateMeetingNoteRequestCopyWith<_UpdateMeetingNoteRequest> get copyWith => __$UpdateMeetingNoteRequestCopyWithImpl<_UpdateMeetingNoteRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateMeetingNoteRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateMeetingNoteRequest&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._sections, _sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_sections));

@override
String toString() {
  return 'UpdateMeetingNoteRequest(title: $title, sections: $sections)';
}


}

/// @nodoc
abstract mixin class _$UpdateMeetingNoteRequestCopyWith<$Res> implements $UpdateMeetingNoteRequestCopyWith<$Res> {
  factory _$UpdateMeetingNoteRequestCopyWith(_UpdateMeetingNoteRequest value, $Res Function(_UpdateMeetingNoteRequest) _then) = __$UpdateMeetingNoteRequestCopyWithImpl;
@override @useResult
$Res call({
 String title,@JsonKey(name: 'content', toJson: encodeNoteContent) Map<String, String> sections
});




}
/// @nodoc
class __$UpdateMeetingNoteRequestCopyWithImpl<$Res>
    implements _$UpdateMeetingNoteRequestCopyWith<$Res> {
  __$UpdateMeetingNoteRequestCopyWithImpl(this._self, this._then);

  final _UpdateMeetingNoteRequest _self;
  final $Res Function(_UpdateMeetingNoteRequest) _then;

/// Create a copy of UpdateMeetingNoteRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? sections = null,}) {
  return _then(_UpdateMeetingNoteRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
