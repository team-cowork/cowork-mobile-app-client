// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attachment_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttachmentResponse {

 String get name;/// 바이트 단위.
 int get size; String get mimeType;
/// Create a copy of AttachmentResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachmentResponseCopyWith<AttachmentResponse> get copyWith => _$AttachmentResponseCopyWithImpl<AttachmentResponse>(this as AttachmentResponse, _$identity);

  /// Serializes this AttachmentResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttachmentResponse&&(identical(other.name, name) || other.name == name)&&(identical(other.size, size) || other.size == size)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,size,mimeType);

@override
String toString() {
  return 'AttachmentResponse(name: $name, size: $size, mimeType: $mimeType)';
}


}

/// @nodoc
abstract mixin class $AttachmentResponseCopyWith<$Res>  {
  factory $AttachmentResponseCopyWith(AttachmentResponse value, $Res Function(AttachmentResponse) _then) = _$AttachmentResponseCopyWithImpl;
@useResult
$Res call({
 String name, int size, String mimeType
});




}
/// @nodoc
class _$AttachmentResponseCopyWithImpl<$Res>
    implements $AttachmentResponseCopyWith<$Res> {
  _$AttachmentResponseCopyWithImpl(this._self, this._then);

  final AttachmentResponse _self;
  final $Res Function(AttachmentResponse) _then;

/// Create a copy of AttachmentResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? size = null,Object? mimeType = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AttachmentResponse].
extension AttachmentResponsePatterns on AttachmentResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttachmentResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttachmentResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttachmentResponse value)  $default,){
final _that = this;
switch (_that) {
case _AttachmentResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttachmentResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AttachmentResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int size,  String mimeType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttachmentResponse() when $default != null:
return $default(_that.name,_that.size,_that.mimeType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int size,  String mimeType)  $default,) {final _that = this;
switch (_that) {
case _AttachmentResponse():
return $default(_that.name,_that.size,_that.mimeType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int size,  String mimeType)?  $default,) {final _that = this;
switch (_that) {
case _AttachmentResponse() when $default != null:
return $default(_that.name,_that.size,_that.mimeType);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _AttachmentResponse implements AttachmentResponse {
  const _AttachmentResponse({this.name = '', this.size = 0, this.mimeType = ''});
  factory _AttachmentResponse.fromJson(Map<String, dynamic> json) => _$AttachmentResponseFromJson(json);

@override@JsonKey() final  String name;
/// 바이트 단위.
@override@JsonKey() final  int size;
@override@JsonKey() final  String mimeType;

/// Create a copy of AttachmentResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachmentResponseCopyWith<_AttachmentResponse> get copyWith => __$AttachmentResponseCopyWithImpl<_AttachmentResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttachmentResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttachmentResponse&&(identical(other.name, name) || other.name == name)&&(identical(other.size, size) || other.size == size)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,size,mimeType);

@override
String toString() {
  return 'AttachmentResponse(name: $name, size: $size, mimeType: $mimeType)';
}


}

/// @nodoc
abstract mixin class _$AttachmentResponseCopyWith<$Res> implements $AttachmentResponseCopyWith<$Res> {
  factory _$AttachmentResponseCopyWith(_AttachmentResponse value, $Res Function(_AttachmentResponse) _then) = __$AttachmentResponseCopyWithImpl;
@override @useResult
$Res call({
 String name, int size, String mimeType
});




}
/// @nodoc
class __$AttachmentResponseCopyWithImpl<$Res>
    implements _$AttachmentResponseCopyWith<$Res> {
  __$AttachmentResponseCopyWithImpl(this._self, this._then);

  final _AttachmentResponse _self;
  final $Res Function(_AttachmentResponse) _then;

/// Create a copy of AttachmentResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? size = null,Object? mimeType = null,}) {
  return _then(_AttachmentResponse(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
