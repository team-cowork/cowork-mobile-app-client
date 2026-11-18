// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_role_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeamRoleResponse {

 int get id; String get name;/// 권한 키(`manage_team` 등)별 허용 여부. 서버는 모든 키를 채워 보낸다.
 Map<String, bool> get permissions;
/// Create a copy of TeamRoleResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamRoleResponseCopyWith<TeamRoleResponse> get copyWith => _$TeamRoleResponseCopyWithImpl<TeamRoleResponse>(this as TeamRoleResponse, _$identity);

  /// Serializes this TeamRoleResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamRoleResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.permissions, permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(permissions));

@override
String toString() {
  return 'TeamRoleResponse(id: $id, name: $name, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class $TeamRoleResponseCopyWith<$Res>  {
  factory $TeamRoleResponseCopyWith(TeamRoleResponse value, $Res Function(TeamRoleResponse) _then) = _$TeamRoleResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name, Map<String, bool> permissions
});




}
/// @nodoc
class _$TeamRoleResponseCopyWithImpl<$Res>
    implements $TeamRoleResponseCopyWith<$Res> {
  _$TeamRoleResponseCopyWithImpl(this._self, this._then);

  final TeamRoleResponse _self;
  final $Res Function(TeamRoleResponse) _then;

/// Create a copy of TeamRoleResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? permissions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamRoleResponse].
extension TeamRoleResponsePatterns on TeamRoleResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamRoleResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamRoleResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamRoleResponse value)  $default,){
final _that = this;
switch (_that) {
case _TeamRoleResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamRoleResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TeamRoleResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  Map<String, bool> permissions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamRoleResponse() when $default != null:
return $default(_that.id,_that.name,_that.permissions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  Map<String, bool> permissions)  $default,) {final _that = this;
switch (_that) {
case _TeamRoleResponse():
return $default(_that.id,_that.name,_that.permissions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  Map<String, bool> permissions)?  $default,) {final _that = this;
switch (_that) {
case _TeamRoleResponse() when $default != null:
return $default(_that.id,_that.name,_that.permissions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamRoleResponse implements TeamRoleResponse {
  const _TeamRoleResponse({required this.id, this.name = '', final  Map<String, bool> permissions = const {}}): _permissions = permissions;
  factory _TeamRoleResponse.fromJson(Map<String, dynamic> json) => _$TeamRoleResponseFromJson(json);

@override final  int id;
@override@JsonKey() final  String name;
/// 권한 키(`manage_team` 등)별 허용 여부. 서버는 모든 키를 채워 보낸다.
 final  Map<String, bool> _permissions;
/// 권한 키(`manage_team` 등)별 허용 여부. 서버는 모든 키를 채워 보낸다.
@override@JsonKey() Map<String, bool> get permissions {
  if (_permissions is EqualUnmodifiableMapView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_permissions);
}


/// Create a copy of TeamRoleResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamRoleResponseCopyWith<_TeamRoleResponse> get copyWith => __$TeamRoleResponseCopyWithImpl<_TeamRoleResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamRoleResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamRoleResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._permissions, _permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_permissions));

@override
String toString() {
  return 'TeamRoleResponse(id: $id, name: $name, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class _$TeamRoleResponseCopyWith<$Res> implements $TeamRoleResponseCopyWith<$Res> {
  factory _$TeamRoleResponseCopyWith(_TeamRoleResponse value, $Res Function(_TeamRoleResponse) _then) = __$TeamRoleResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, Map<String, bool> permissions
});




}
/// @nodoc
class __$TeamRoleResponseCopyWithImpl<$Res>
    implements _$TeamRoleResponseCopyWith<$Res> {
  __$TeamRoleResponseCopyWithImpl(this._self, this._then);

  final _TeamRoleResponse _self;
  final $Res Function(_TeamRoleResponse) _then;

/// Create a copy of TeamRoleResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? permissions = null,}) {
  return _then(_TeamRoleResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,
  ));
}


}

// dart format on
