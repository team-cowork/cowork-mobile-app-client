// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'confirm_team_icon_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConfirmTeamIconRequest {

/// presigned 발급 때 받은 값.
 String get objectKey;
/// Create a copy of ConfirmTeamIconRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmTeamIconRequestCopyWith<ConfirmTeamIconRequest> get copyWith => _$ConfirmTeamIconRequestCopyWithImpl<ConfirmTeamIconRequest>(this as ConfirmTeamIconRequest, _$identity);

  /// Serializes this ConfirmTeamIconRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmTeamIconRequest&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,objectKey);

@override
String toString() {
  return 'ConfirmTeamIconRequest(objectKey: $objectKey)';
}


}

/// @nodoc
abstract mixin class $ConfirmTeamIconRequestCopyWith<$Res>  {
  factory $ConfirmTeamIconRequestCopyWith(ConfirmTeamIconRequest value, $Res Function(ConfirmTeamIconRequest) _then) = _$ConfirmTeamIconRequestCopyWithImpl;
@useResult
$Res call({
 String objectKey
});




}
/// @nodoc
class _$ConfirmTeamIconRequestCopyWithImpl<$Res>
    implements $ConfirmTeamIconRequestCopyWith<$Res> {
  _$ConfirmTeamIconRequestCopyWithImpl(this._self, this._then);

  final ConfirmTeamIconRequest _self;
  final $Res Function(ConfirmTeamIconRequest) _then;

/// Create a copy of ConfirmTeamIconRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? objectKey = null,}) {
  return _then(_self.copyWith(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfirmTeamIconRequest].
extension ConfirmTeamIconRequestPatterns on ConfirmTeamIconRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmTeamIconRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmTeamIconRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmTeamIconRequest value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmTeamIconRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmTeamIconRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmTeamIconRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String objectKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmTeamIconRequest() when $default != null:
return $default(_that.objectKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String objectKey)  $default,) {final _that = this;
switch (_that) {
case _ConfirmTeamIconRequest():
return $default(_that.objectKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String objectKey)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmTeamIconRequest() when $default != null:
return $default(_that.objectKey);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(createFactory: false)
class _ConfirmTeamIconRequest implements ConfirmTeamIconRequest {
  const _ConfirmTeamIconRequest({required this.objectKey});
  

/// presigned 발급 때 받은 값.
@override final  String objectKey;

/// Create a copy of ConfirmTeamIconRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmTeamIconRequestCopyWith<_ConfirmTeamIconRequest> get copyWith => __$ConfirmTeamIconRequestCopyWithImpl<_ConfirmTeamIconRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmTeamIconRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmTeamIconRequest&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,objectKey);

@override
String toString() {
  return 'ConfirmTeamIconRequest(objectKey: $objectKey)';
}


}

/// @nodoc
abstract mixin class _$ConfirmTeamIconRequestCopyWith<$Res> implements $ConfirmTeamIconRequestCopyWith<$Res> {
  factory _$ConfirmTeamIconRequestCopyWith(_ConfirmTeamIconRequest value, $Res Function(_ConfirmTeamIconRequest) _then) = __$ConfirmTeamIconRequestCopyWithImpl;
@override @useResult
$Res call({
 String objectKey
});




}
/// @nodoc
class __$ConfirmTeamIconRequestCopyWithImpl<$Res>
    implements _$ConfirmTeamIconRequestCopyWith<$Res> {
  __$ConfirmTeamIconRequestCopyWithImpl(this._self, this._then);

  final _ConfirmTeamIconRequest _self;
  final $Res Function(_ConfirmTeamIconRequest) _then;

/// Create a copy of ConfirmTeamIconRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? objectKey = null,}) {
  return _then(_ConfirmTeamIconRequest(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
