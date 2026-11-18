// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_icon_upload_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TeamIconUploadRequest {

 String get contentType;
/// Create a copy of TeamIconUploadRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamIconUploadRequestCopyWith<TeamIconUploadRequest> get copyWith => _$TeamIconUploadRequestCopyWithImpl<TeamIconUploadRequest>(this as TeamIconUploadRequest, _$identity);

  /// Serializes this TeamIconUploadRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamIconUploadRequest&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contentType);

@override
String toString() {
  return 'TeamIconUploadRequest(contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class $TeamIconUploadRequestCopyWith<$Res>  {
  factory $TeamIconUploadRequestCopyWith(TeamIconUploadRequest value, $Res Function(TeamIconUploadRequest) _then) = _$TeamIconUploadRequestCopyWithImpl;
@useResult
$Res call({
 String contentType
});




}
/// @nodoc
class _$TeamIconUploadRequestCopyWithImpl<$Res>
    implements $TeamIconUploadRequestCopyWith<$Res> {
  _$TeamIconUploadRequestCopyWithImpl(this._self, this._then);

  final TeamIconUploadRequest _self;
  final $Res Function(TeamIconUploadRequest) _then;

/// Create a copy of TeamIconUploadRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contentType = null,}) {
  return _then(_self.copyWith(
contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamIconUploadRequest].
extension TeamIconUploadRequestPatterns on TeamIconUploadRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamIconUploadRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamIconUploadRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamIconUploadRequest value)  $default,){
final _that = this;
switch (_that) {
case _TeamIconUploadRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamIconUploadRequest value)?  $default,){
final _that = this;
switch (_that) {
case _TeamIconUploadRequest() when $default != null:
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
case _TeamIconUploadRequest() when $default != null:
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
case _TeamIconUploadRequest():
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
case _TeamIconUploadRequest() when $default != null:
return $default(_that.contentType);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(createFactory: false)
class _TeamIconUploadRequest implements TeamIconUploadRequest {
  const _TeamIconUploadRequest({required this.contentType});
  

@override final  String contentType;

/// Create a copy of TeamIconUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamIconUploadRequestCopyWith<_TeamIconUploadRequest> get copyWith => __$TeamIconUploadRequestCopyWithImpl<_TeamIconUploadRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamIconUploadRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamIconUploadRequest&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contentType);

@override
String toString() {
  return 'TeamIconUploadRequest(contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class _$TeamIconUploadRequestCopyWith<$Res> implements $TeamIconUploadRequestCopyWith<$Res> {
  factory _$TeamIconUploadRequestCopyWith(_TeamIconUploadRequest value, $Res Function(_TeamIconUploadRequest) _then) = __$TeamIconUploadRequestCopyWithImpl;
@override @useResult
$Res call({
 String contentType
});




}
/// @nodoc
class __$TeamIconUploadRequestCopyWithImpl<$Res>
    implements _$TeamIconUploadRequestCopyWith<$Res> {
  __$TeamIconUploadRequestCopyWithImpl(this._self, this._then);

  final _TeamIconUploadRequest _self;
  final $Res Function(_TeamIconUploadRequest) _then;

/// Create a copy of TeamIconUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contentType = null,}) {
  return _then(_TeamIconUploadRequest(
contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
