// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_icon_upload_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TeamIconUploadResponse {

 String get uploadUrl; String get objectKey;
/// Create a copy of TeamIconUploadResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamIconUploadResponseCopyWith<TeamIconUploadResponse> get copyWith => _$TeamIconUploadResponseCopyWithImpl<TeamIconUploadResponse>(this as TeamIconUploadResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamIconUploadResponse&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey));
}


@override
int get hashCode => Object.hash(runtimeType,uploadUrl,objectKey);

@override
String toString() {
  return 'TeamIconUploadResponse(uploadUrl: $uploadUrl, objectKey: $objectKey)';
}


}

/// @nodoc
abstract mixin class $TeamIconUploadResponseCopyWith<$Res>  {
  factory $TeamIconUploadResponseCopyWith(TeamIconUploadResponse value, $Res Function(TeamIconUploadResponse) _then) = _$TeamIconUploadResponseCopyWithImpl;
@useResult
$Res call({
 String uploadUrl, String objectKey
});




}
/// @nodoc
class _$TeamIconUploadResponseCopyWithImpl<$Res>
    implements $TeamIconUploadResponseCopyWith<$Res> {
  _$TeamIconUploadResponseCopyWithImpl(this._self, this._then);

  final TeamIconUploadResponse _self;
  final $Res Function(TeamIconUploadResponse) _then;

/// Create a copy of TeamIconUploadResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uploadUrl = null,Object? objectKey = null,}) {
  return _then(_self.copyWith(
uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamIconUploadResponse].
extension TeamIconUploadResponsePatterns on TeamIconUploadResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamIconUploadResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamIconUploadResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamIconUploadResponse value)  $default,){
final _that = this;
switch (_that) {
case _TeamIconUploadResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamIconUploadResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TeamIconUploadResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uploadUrl,  String objectKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamIconUploadResponse() when $default != null:
return $default(_that.uploadUrl,_that.objectKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uploadUrl,  String objectKey)  $default,) {final _that = this;
switch (_that) {
case _TeamIconUploadResponse():
return $default(_that.uploadUrl,_that.objectKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uploadUrl,  String objectKey)?  $default,) {final _that = this;
switch (_that) {
case _TeamIconUploadResponse() when $default != null:
return $default(_that.uploadUrl,_that.objectKey);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable()
class _TeamIconUploadResponse implements TeamIconUploadResponse {
  const _TeamIconUploadResponse({this.uploadUrl = '', this.objectKey = ''});
  

@override@JsonKey() final  String uploadUrl;
@override@JsonKey() final  String objectKey;

/// Create a copy of TeamIconUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamIconUploadResponseCopyWith<_TeamIconUploadResponse> get copyWith => __$TeamIconUploadResponseCopyWithImpl<_TeamIconUploadResponse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamIconUploadResponse&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey));
}


@override
int get hashCode => Object.hash(runtimeType,uploadUrl,objectKey);

@override
String toString() {
  return 'TeamIconUploadResponse(uploadUrl: $uploadUrl, objectKey: $objectKey)';
}


}

/// @nodoc
abstract mixin class _$TeamIconUploadResponseCopyWith<$Res> implements $TeamIconUploadResponseCopyWith<$Res> {
  factory _$TeamIconUploadResponseCopyWith(_TeamIconUploadResponse value, $Res Function(_TeamIconUploadResponse) _then) = __$TeamIconUploadResponseCopyWithImpl;
@override @useResult
$Res call({
 String uploadUrl, String objectKey
});




}
/// @nodoc
class __$TeamIconUploadResponseCopyWithImpl<$Res>
    implements _$TeamIconUploadResponseCopyWith<$Res> {
  __$TeamIconUploadResponseCopyWithImpl(this._self, this._then);

  final _TeamIconUploadResponse _self;
  final $Res Function(_TeamIconUploadResponse) _then;

/// Create a copy of TeamIconUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uploadUrl = null,Object? objectKey = null,}) {
  return _then(_TeamIconUploadResponse(
uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
