// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_status_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateStatusRequest {

/// 사용자가 고른 상태(예: `DO_NOT_DISTURB`). 접속 상태(`status`)와 별개다.
 String get customStatus; String? get message;
/// Create a copy of UpdateStatusRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateStatusRequestCopyWith<UpdateStatusRequest> get copyWith => _$UpdateStatusRequestCopyWithImpl<UpdateStatusRequest>(this as UpdateStatusRequest, _$identity);

  /// Serializes this UpdateStatusRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateStatusRequest&&(identical(other.customStatus, customStatus) || other.customStatus == customStatus)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customStatus,message);

@override
String toString() {
  return 'UpdateStatusRequest(customStatus: $customStatus, message: $message)';
}


}

/// @nodoc
abstract mixin class $UpdateStatusRequestCopyWith<$Res>  {
  factory $UpdateStatusRequestCopyWith(UpdateStatusRequest value, $Res Function(UpdateStatusRequest) _then) = _$UpdateStatusRequestCopyWithImpl;
@useResult
$Res call({
 String customStatus, String? message
});




}
/// @nodoc
class _$UpdateStatusRequestCopyWithImpl<$Res>
    implements $UpdateStatusRequestCopyWith<$Res> {
  _$UpdateStatusRequestCopyWithImpl(this._self, this._then);

  final UpdateStatusRequest _self;
  final $Res Function(UpdateStatusRequest) _then;

/// Create a copy of UpdateStatusRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customStatus = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
customStatus: null == customStatus ? _self.customStatus : customStatus // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateStatusRequest].
extension UpdateStatusRequestPatterns on UpdateStatusRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateStatusRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateStatusRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateStatusRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateStatusRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateStatusRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateStatusRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String customStatus,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateStatusRequest() when $default != null:
return $default(_that.customStatus,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String customStatus,  String? message)  $default,) {final _that = this;
switch (_that) {
case _UpdateStatusRequest():
return $default(_that.customStatus,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String customStatus,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _UpdateStatusRequest() when $default != null:
return $default(_that.customStatus,_that.message);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
class _UpdateStatusRequest implements UpdateStatusRequest {
  const _UpdateStatusRequest({required this.customStatus, this.message});
  

/// 사용자가 고른 상태(예: `DO_NOT_DISTURB`). 접속 상태(`status`)와 별개다.
@override final  String customStatus;
@override final  String? message;

/// Create a copy of UpdateStatusRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateStatusRequestCopyWith<_UpdateStatusRequest> get copyWith => __$UpdateStatusRequestCopyWithImpl<_UpdateStatusRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateStatusRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateStatusRequest&&(identical(other.customStatus, customStatus) || other.customStatus == customStatus)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customStatus,message);

@override
String toString() {
  return 'UpdateStatusRequest(customStatus: $customStatus, message: $message)';
}


}

/// @nodoc
abstract mixin class _$UpdateStatusRequestCopyWith<$Res> implements $UpdateStatusRequestCopyWith<$Res> {
  factory _$UpdateStatusRequestCopyWith(_UpdateStatusRequest value, $Res Function(_UpdateStatusRequest) _then) = __$UpdateStatusRequestCopyWithImpl;
@override @useResult
$Res call({
 String customStatus, String? message
});




}
/// @nodoc
class __$UpdateStatusRequestCopyWithImpl<$Res>
    implements _$UpdateStatusRequestCopyWith<$Res> {
  __$UpdateStatusRequestCopyWithImpl(this._self, this._then);

  final _UpdateStatusRequest _self;
  final $Res Function(_UpdateStatusRequest) _then;

/// Create a copy of UpdateStatusRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customStatus = null,Object? message = freezed,}) {
  return _then(_UpdateStatusRequest(
customStatus: null == customStatus ? _self.customStatus : customStatus // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
