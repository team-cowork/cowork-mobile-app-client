// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_upload_url_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FileUploadUrlResponse {

/// 업로드 확인에 되돌려 보낼 임시 키.
 String get objectKey; String get uploadUrl;/// PUT 에 그대로 실어야 하는 헤더. 서명에 `Content-Type` 이 들어 있다.
 Map<String, String> get headers;
/// Create a copy of FileUploadUrlResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileUploadUrlResponseCopyWith<FileUploadUrlResponse> get copyWith => _$FileUploadUrlResponseCopyWithImpl<FileUploadUrlResponse>(this as FileUploadUrlResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileUploadUrlResponse&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&const DeepCollectionEquality().equals(other.headers, headers));
}


@override
int get hashCode => Object.hash(runtimeType,objectKey,uploadUrl,const DeepCollectionEquality().hash(headers));

@override
String toString() {
  return 'FileUploadUrlResponse(objectKey: $objectKey, uploadUrl: $uploadUrl, headers: $headers)';
}


}

/// @nodoc
abstract mixin class $FileUploadUrlResponseCopyWith<$Res>  {
  factory $FileUploadUrlResponseCopyWith(FileUploadUrlResponse value, $Res Function(FileUploadUrlResponse) _then) = _$FileUploadUrlResponseCopyWithImpl;
@useResult
$Res call({
 String objectKey, String uploadUrl, Map<String, String> headers
});




}
/// @nodoc
class _$FileUploadUrlResponseCopyWithImpl<$Res>
    implements $FileUploadUrlResponseCopyWith<$Res> {
  _$FileUploadUrlResponseCopyWithImpl(this._self, this._then);

  final FileUploadUrlResponse _self;
  final $Res Function(FileUploadUrlResponse) _then;

/// Create a copy of FileUploadUrlResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? objectKey = null,Object? uploadUrl = null,Object? headers = null,}) {
  return _then(_self.copyWith(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [FileUploadUrlResponse].
extension FileUploadUrlResponsePatterns on FileUploadUrlResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileUploadUrlResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileUploadUrlResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileUploadUrlResponse value)  $default,){
final _that = this;
switch (_that) {
case _FileUploadUrlResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileUploadUrlResponse value)?  $default,){
final _that = this;
switch (_that) {
case _FileUploadUrlResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String objectKey,  String uploadUrl,  Map<String, String> headers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileUploadUrlResponse() when $default != null:
return $default(_that.objectKey,_that.uploadUrl,_that.headers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String objectKey,  String uploadUrl,  Map<String, String> headers)  $default,) {final _that = this;
switch (_that) {
case _FileUploadUrlResponse():
return $default(_that.objectKey,_that.uploadUrl,_that.headers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String objectKey,  String uploadUrl,  Map<String, String> headers)?  $default,) {final _that = this;
switch (_that) {
case _FileUploadUrlResponse() when $default != null:
return $default(_that.objectKey,_that.uploadUrl,_that.headers);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable()
class _FileUploadUrlResponse implements FileUploadUrlResponse {
  const _FileUploadUrlResponse({this.objectKey = '', this.uploadUrl = '', final  Map<String, String> headers = const {}}): _headers = headers;
  

/// 업로드 확인에 되돌려 보낼 임시 키.
@override@JsonKey() final  String objectKey;
@override@JsonKey() final  String uploadUrl;
/// PUT 에 그대로 실어야 하는 헤더. 서명에 `Content-Type` 이 들어 있다.
 final  Map<String, String> _headers;
/// PUT 에 그대로 실어야 하는 헤더. 서명에 `Content-Type` 이 들어 있다.
@override@JsonKey() Map<String, String> get headers {
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_headers);
}


/// Create a copy of FileUploadUrlResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileUploadUrlResponseCopyWith<_FileUploadUrlResponse> get copyWith => __$FileUploadUrlResponseCopyWithImpl<_FileUploadUrlResponse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileUploadUrlResponse&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&const DeepCollectionEquality().equals(other._headers, _headers));
}


@override
int get hashCode => Object.hash(runtimeType,objectKey,uploadUrl,const DeepCollectionEquality().hash(_headers));

@override
String toString() {
  return 'FileUploadUrlResponse(objectKey: $objectKey, uploadUrl: $uploadUrl, headers: $headers)';
}


}

/// @nodoc
abstract mixin class _$FileUploadUrlResponseCopyWith<$Res> implements $FileUploadUrlResponseCopyWith<$Res> {
  factory _$FileUploadUrlResponseCopyWith(_FileUploadUrlResponse value, $Res Function(_FileUploadUrlResponse) _then) = __$FileUploadUrlResponseCopyWithImpl;
@override @useResult
$Res call({
 String objectKey, String uploadUrl, Map<String, String> headers
});




}
/// @nodoc
class __$FileUploadUrlResponseCopyWithImpl<$Res>
    implements _$FileUploadUrlResponseCopyWith<$Res> {
  __$FileUploadUrlResponseCopyWithImpl(this._self, this._then);

  final _FileUploadUrlResponse _self;
  final $Res Function(_FileUploadUrlResponse) _then;

/// Create a copy of FileUploadUrlResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? objectKey = null,Object? uploadUrl = null,Object? headers = null,}) {
  return _then(_FileUploadUrlResponse(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
