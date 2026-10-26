// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_me_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateMeRequest {

 String get name; String get nickname;/// 자기소개.
 String get description;
/// Create a copy of UpdateMeRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateMeRequestCopyWith<UpdateMeRequest> get copyWith => _$UpdateMeRequestCopyWithImpl<UpdateMeRequest>(this as UpdateMeRequest, _$identity);

  /// Serializes this UpdateMeRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateMeRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,nickname,description);

@override
String toString() {
  return 'UpdateMeRequest(name: $name, nickname: $nickname, description: $description)';
}


}

/// @nodoc
abstract mixin class $UpdateMeRequestCopyWith<$Res>  {
  factory $UpdateMeRequestCopyWith(UpdateMeRequest value, $Res Function(UpdateMeRequest) _then) = _$UpdateMeRequestCopyWithImpl;
@useResult
$Res call({
 String name, String nickname, String description
});




}
/// @nodoc
class _$UpdateMeRequestCopyWithImpl<$Res>
    implements $UpdateMeRequestCopyWith<$Res> {
  _$UpdateMeRequestCopyWithImpl(this._self, this._then);

  final UpdateMeRequest _self;
  final $Res Function(UpdateMeRequest) _then;

/// Create a copy of UpdateMeRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? nickname = null,Object? description = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateMeRequest].
extension UpdateMeRequestPatterns on UpdateMeRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateMeRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateMeRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateMeRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateMeRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateMeRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateMeRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String nickname,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateMeRequest() when $default != null:
return $default(_that.name,_that.nickname,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String nickname,  String description)  $default,) {final _that = this;
switch (_that) {
case _UpdateMeRequest():
return $default(_that.name,_that.nickname,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String nickname,  String description)?  $default,) {final _that = this;
switch (_that) {
case _UpdateMeRequest() when $default != null:
return $default(_that.name,_that.nickname,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _UpdateMeRequest implements UpdateMeRequest {
  const _UpdateMeRequest({required this.name, required this.nickname, required this.description});
  

@override final  String name;
@override final  String nickname;
/// 자기소개.
@override final  String description;

/// Create a copy of UpdateMeRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateMeRequestCopyWith<_UpdateMeRequest> get copyWith => __$UpdateMeRequestCopyWithImpl<_UpdateMeRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateMeRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateMeRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,nickname,description);

@override
String toString() {
  return 'UpdateMeRequest(name: $name, nickname: $nickname, description: $description)';
}


}

/// @nodoc
abstract mixin class _$UpdateMeRequestCopyWith<$Res> implements $UpdateMeRequestCopyWith<$Res> {
  factory _$UpdateMeRequestCopyWith(_UpdateMeRequest value, $Res Function(_UpdateMeRequest) _then) = __$UpdateMeRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String nickname, String description
});




}
/// @nodoc
class __$UpdateMeRequestCopyWithImpl<$Res>
    implements _$UpdateMeRequestCopyWith<$Res> {
  __$UpdateMeRequestCopyWithImpl(this._self, this._then);

  final _UpdateMeRequest _self;
  final $Res Function(_UpdateMeRequest) _then;

/// Create a copy of UpdateMeRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? nickname = null,Object? description = null,}) {
  return _then(_UpdateMeRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
