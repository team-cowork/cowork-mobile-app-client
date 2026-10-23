// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presigned_upload_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PresignedUploadRequest {

 String get contentType;
/// Create a copy of PresignedUploadRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresignedUploadRequestCopyWith<PresignedUploadRequest> get copyWith => _$PresignedUploadRequestCopyWithImpl<PresignedUploadRequest>(this as PresignedUploadRequest, _$identity);

  /// Serializes this PresignedUploadRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresignedUploadRequest&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contentType);

@override
String toString() {
  return 'PresignedUploadRequest(contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class $PresignedUploadRequestCopyWith<$Res>  {
  factory $PresignedUploadRequestCopyWith(PresignedUploadRequest value, $Res Function(PresignedUploadRequest) _then) = _$PresignedUploadRequestCopyWithImpl;
@useResult
$Res call({
 String contentType
});




}
/// @nodoc
class _$PresignedUploadRequestCopyWithImpl<$Res>
    implements $PresignedUploadRequestCopyWith<$Res> {
  _$PresignedUploadRequestCopyWithImpl(this._self, this._then);

  final PresignedUploadRequest _self;
  final $Res Function(PresignedUploadRequest) _then;

/// Create a copy of PresignedUploadRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contentType = null,}) {
  return _then(_self.copyWith(
contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PresignedUploadRequest].
extension PresignedUploadRequestPatterns on PresignedUploadRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresignedUploadRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresignedUploadRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresignedUploadRequest value)  $default,){
final _that = this;
switch (_that) {
case _PresignedUploadRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresignedUploadRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PresignedUploadRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresignedUploadRequest() when $default != null:
return $default(_that.contentType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contentType)  $default,) {final _that = this;
switch (_that) {
case _PresignedUploadRequest():
return $default(_that.contentType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contentType)?  $default,) {final _that = this;
switch (_that) {
case _PresignedUploadRequest() when $default != null:
return $default(_that.contentType);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
class _PresignedUploadRequest implements PresignedUploadRequest {
  const _PresignedUploadRequest({required this.contentType});
  

@override final  String contentType;

/// Create a copy of PresignedUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresignedUploadRequestCopyWith<_PresignedUploadRequest> get copyWith => __$PresignedUploadRequestCopyWithImpl<_PresignedUploadRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresignedUploadRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresignedUploadRequest&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contentType);

@override
String toString() {
  return 'PresignedUploadRequest(contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class _$PresignedUploadRequestCopyWith<$Res> implements $PresignedUploadRequestCopyWith<$Res> {
  factory _$PresignedUploadRequestCopyWith(_PresignedUploadRequest value, $Res Function(_PresignedUploadRequest) _then) = __$PresignedUploadRequestCopyWithImpl;
@override @useResult
$Res call({
 String contentType
});




}
/// @nodoc
class __$PresignedUploadRequestCopyWithImpl<$Res>
    implements _$PresignedUploadRequestCopyWith<$Res> {
  __$PresignedUploadRequestCopyWithImpl(this._self, this._then);

  final _PresignedUploadRequest _self;
  final $Res Function(_PresignedUploadRequest) _then;

/// Create a copy of PresignedUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contentType = null,}) {
  return _then(_PresignedUploadRequest(
contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
