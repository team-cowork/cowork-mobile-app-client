// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting_note_attachment_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeetingNoteAttachmentResponse {

 String get objectKey; String get name;
/// Create a copy of MeetingNoteAttachmentResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeetingNoteAttachmentResponseCopyWith<MeetingNoteAttachmentResponse> get copyWith => _$MeetingNoteAttachmentResponseCopyWithImpl<MeetingNoteAttachmentResponse>(this as MeetingNoteAttachmentResponse, _$identity);

  /// Serializes this MeetingNoteAttachmentResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeetingNoteAttachmentResponse&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,objectKey,name);

@override
String toString() {
  return 'MeetingNoteAttachmentResponse(objectKey: $objectKey, name: $name)';
}


}

/// @nodoc
abstract mixin class $MeetingNoteAttachmentResponseCopyWith<$Res>  {
  factory $MeetingNoteAttachmentResponseCopyWith(MeetingNoteAttachmentResponse value, $Res Function(MeetingNoteAttachmentResponse) _then) = _$MeetingNoteAttachmentResponseCopyWithImpl;
@useResult
$Res call({
 String objectKey, String name
});




}
/// @nodoc
class _$MeetingNoteAttachmentResponseCopyWithImpl<$Res>
    implements $MeetingNoteAttachmentResponseCopyWith<$Res> {
  _$MeetingNoteAttachmentResponseCopyWithImpl(this._self, this._then);

  final MeetingNoteAttachmentResponse _self;
  final $Res Function(MeetingNoteAttachmentResponse) _then;

/// Create a copy of MeetingNoteAttachmentResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? objectKey = null,Object? name = null,}) {
  return _then(_self.copyWith(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MeetingNoteAttachmentResponse].
extension MeetingNoteAttachmentResponsePatterns on MeetingNoteAttachmentResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeetingNoteAttachmentResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeetingNoteAttachmentResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeetingNoteAttachmentResponse value)  $default,){
final _that = this;
switch (_that) {
case _MeetingNoteAttachmentResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeetingNoteAttachmentResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MeetingNoteAttachmentResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String objectKey,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeetingNoteAttachmentResponse() when $default != null:
return $default(_that.objectKey,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String objectKey,  String name)  $default,) {final _that = this;
switch (_that) {
case _MeetingNoteAttachmentResponse():
return $default(_that.objectKey,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String objectKey,  String name)?  $default,) {final _that = this;
switch (_that) {
case _MeetingNoteAttachmentResponse() when $default != null:
return $default(_that.objectKey,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeetingNoteAttachmentResponse implements MeetingNoteAttachmentResponse {
  const _MeetingNoteAttachmentResponse({this.objectKey = '', this.name = ''});
  factory _MeetingNoteAttachmentResponse.fromJson(Map<String, dynamic> json) => _$MeetingNoteAttachmentResponseFromJson(json);

@override@JsonKey() final  String objectKey;
@override@JsonKey() final  String name;

/// Create a copy of MeetingNoteAttachmentResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeetingNoteAttachmentResponseCopyWith<_MeetingNoteAttachmentResponse> get copyWith => __$MeetingNoteAttachmentResponseCopyWithImpl<_MeetingNoteAttachmentResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeetingNoteAttachmentResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeetingNoteAttachmentResponse&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,objectKey,name);

@override
String toString() {
  return 'MeetingNoteAttachmentResponse(objectKey: $objectKey, name: $name)';
}


}

/// @nodoc
abstract mixin class _$MeetingNoteAttachmentResponseCopyWith<$Res> implements $MeetingNoteAttachmentResponseCopyWith<$Res> {
  factory _$MeetingNoteAttachmentResponseCopyWith(_MeetingNoteAttachmentResponse value, $Res Function(_MeetingNoteAttachmentResponse) _then) = __$MeetingNoteAttachmentResponseCopyWithImpl;
@override @useResult
$Res call({
 String objectKey, String name
});




}
/// @nodoc
class __$MeetingNoteAttachmentResponseCopyWithImpl<$Res>
    implements _$MeetingNoteAttachmentResponseCopyWith<$Res> {
  __$MeetingNoteAttachmentResponseCopyWithImpl(this._self, this._then);

  final _MeetingNoteAttachmentResponse _self;
  final $Res Function(_MeetingNoteAttachmentResponse) _then;

/// Create a copy of MeetingNoteAttachmentResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? objectKey = null,Object? name = null,}) {
  return _then(_MeetingNoteAttachmentResponse(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
