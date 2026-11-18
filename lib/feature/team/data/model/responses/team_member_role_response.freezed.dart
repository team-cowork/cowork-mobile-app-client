// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_member_role_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeamMemberRoleResponse {

 String get name;/// 활성 멤버 모두에게 자동으로 붙는 기본 역할인지.
 bool get isDefault;
/// Create a copy of TeamMemberRoleResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamMemberRoleResponseCopyWith<TeamMemberRoleResponse> get copyWith => _$TeamMemberRoleResponseCopyWithImpl<TeamMemberRoleResponse>(this as TeamMemberRoleResponse, _$identity);

  /// Serializes this TeamMemberRoleResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamMemberRoleResponse&&(identical(other.name, name) || other.name == name)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,isDefault);

@override
String toString() {
  return 'TeamMemberRoleResponse(name: $name, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $TeamMemberRoleResponseCopyWith<$Res>  {
  factory $TeamMemberRoleResponseCopyWith(TeamMemberRoleResponse value, $Res Function(TeamMemberRoleResponse) _then) = _$TeamMemberRoleResponseCopyWithImpl;
@useResult
$Res call({
 String name, bool isDefault
});




}
/// @nodoc
class _$TeamMemberRoleResponseCopyWithImpl<$Res>
    implements $TeamMemberRoleResponseCopyWith<$Res> {
  _$TeamMemberRoleResponseCopyWithImpl(this._self, this._then);

  final TeamMemberRoleResponse _self;
  final $Res Function(TeamMemberRoleResponse) _then;

/// Create a copy of TeamMemberRoleResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? isDefault = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamMemberRoleResponse].
extension TeamMemberRoleResponsePatterns on TeamMemberRoleResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamMemberRoleResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamMemberRoleResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamMemberRoleResponse value)  $default,){
final _that = this;
switch (_that) {
case _TeamMemberRoleResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamMemberRoleResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TeamMemberRoleResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamMemberRoleResponse() when $default != null:
return $default(_that.name,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _TeamMemberRoleResponse():
return $default(_that.name,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _TeamMemberRoleResponse() when $default != null:
return $default(_that.name,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamMemberRoleResponse implements TeamMemberRoleResponse {
  const _TeamMemberRoleResponse({this.name = '', this.isDefault = false});
  factory _TeamMemberRoleResponse.fromJson(Map<String, dynamic> json) => _$TeamMemberRoleResponseFromJson(json);

@override@JsonKey() final  String name;
/// 활성 멤버 모두에게 자동으로 붙는 기본 역할인지.
@override@JsonKey() final  bool isDefault;

/// Create a copy of TeamMemberRoleResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamMemberRoleResponseCopyWith<_TeamMemberRoleResponse> get copyWith => __$TeamMemberRoleResponseCopyWithImpl<_TeamMemberRoleResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamMemberRoleResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamMemberRoleResponse&&(identical(other.name, name) || other.name == name)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,isDefault);

@override
String toString() {
  return 'TeamMemberRoleResponse(name: $name, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$TeamMemberRoleResponseCopyWith<$Res> implements $TeamMemberRoleResponseCopyWith<$Res> {
  factory _$TeamMemberRoleResponseCopyWith(_TeamMemberRoleResponse value, $Res Function(_TeamMemberRoleResponse) _then) = __$TeamMemberRoleResponseCopyWithImpl;
@override @useResult
$Res call({
 String name, bool isDefault
});




}
/// @nodoc
class __$TeamMemberRoleResponseCopyWithImpl<$Res>
    implements _$TeamMemberRoleResponseCopyWith<$Res> {
  __$TeamMemberRoleResponseCopyWithImpl(this._self, this._then);

  final _TeamMemberRoleResponse _self;
  final $Res Function(_TeamMemberRoleResponse) _then;

/// Create a copy of TeamMemberRoleResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? isDefault = null,}) {
  return _then(_TeamMemberRoleResponse(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
