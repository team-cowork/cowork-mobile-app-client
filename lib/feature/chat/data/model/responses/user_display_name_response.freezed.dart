// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_display_name_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserDisplayNameResponse {

 int get id; String get name; String? get nickname;
/// Create a copy of UserDisplayNameResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDisplayNameResponseCopyWith<UserDisplayNameResponse> get copyWith => _$UserDisplayNameResponseCopyWithImpl<UserDisplayNameResponse>(this as UserDisplayNameResponse, _$identity);

  /// Serializes this UserDisplayNameResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDisplayNameResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nickname, nickname) || other.nickname == nickname));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nickname);

@override
String toString() {
  return 'UserDisplayNameResponse(id: $id, name: $name, nickname: $nickname)';
}


}

/// @nodoc
abstract mixin class $UserDisplayNameResponseCopyWith<$Res>  {
  factory $UserDisplayNameResponseCopyWith(UserDisplayNameResponse value, $Res Function(UserDisplayNameResponse) _then) = _$UserDisplayNameResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? nickname
});




}
/// @nodoc
class _$UserDisplayNameResponseCopyWithImpl<$Res>
    implements $UserDisplayNameResponseCopyWith<$Res> {
  _$UserDisplayNameResponseCopyWithImpl(this._self, this._then);

  final UserDisplayNameResponse _self;
  final $Res Function(UserDisplayNameResponse) _then;

/// Create a copy of UserDisplayNameResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? nickname = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserDisplayNameResponse].
extension UserDisplayNameResponsePatterns on UserDisplayNameResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDisplayNameResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDisplayNameResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDisplayNameResponse value)  $default,){
final _that = this;
switch (_that) {
case _UserDisplayNameResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDisplayNameResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UserDisplayNameResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? nickname)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDisplayNameResponse() when $default != null:
return $default(_that.id,_that.name,_that.nickname);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? nickname)  $default,) {final _that = this;
switch (_that) {
case _UserDisplayNameResponse():
return $default(_that.id,_that.name,_that.nickname);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? nickname)?  $default,) {final _that = this;
switch (_that) {
case _UserDisplayNameResponse() when $default != null:
return $default(_that.id,_that.name,_that.nickname);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDisplayNameResponse implements UserDisplayNameResponse {
  const _UserDisplayNameResponse({required this.id, this.name = '', this.nickname});
  factory _UserDisplayNameResponse.fromJson(Map<String, dynamic> json) => _$UserDisplayNameResponseFromJson(json);

@override final  int id;
@override@JsonKey() final  String name;
@override final  String? nickname;

/// Create a copy of UserDisplayNameResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDisplayNameResponseCopyWith<_UserDisplayNameResponse> get copyWith => __$UserDisplayNameResponseCopyWithImpl<_UserDisplayNameResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDisplayNameResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDisplayNameResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nickname, nickname) || other.nickname == nickname));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nickname);

@override
String toString() {
  return 'UserDisplayNameResponse(id: $id, name: $name, nickname: $nickname)';
}


}

/// @nodoc
abstract mixin class _$UserDisplayNameResponseCopyWith<$Res> implements $UserDisplayNameResponseCopyWith<$Res> {
  factory _$UserDisplayNameResponseCopyWith(_UserDisplayNameResponse value, $Res Function(_UserDisplayNameResponse) _then) = __$UserDisplayNameResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? nickname
});




}
/// @nodoc
class __$UserDisplayNameResponseCopyWithImpl<$Res>
    implements _$UserDisplayNameResponseCopyWith<$Res> {
  __$UserDisplayNameResponseCopyWithImpl(this._self, this._then);

  final _UserDisplayNameResponse _self;
  final $Res Function(_UserDisplayNameResponse) _then;

/// Create a copy of UserDisplayNameResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? nickname = freezed,}) {
  return _then(_UserDisplayNameResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
