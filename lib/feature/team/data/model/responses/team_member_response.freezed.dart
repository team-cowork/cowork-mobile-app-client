// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_member_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeamMemberResponse {

 int get userId;/// `OWNER` / `ADMIN` / `MEMBER`.
 String get role;/// 사용자가 받은 커스텀 역할. 모든 멤버에게 자동으로 붙는 기본 역할도 들어 있다.
 List<TeamMemberRoleResponse> get roles;
/// Create a copy of TeamMemberResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamMemberResponseCopyWith<TeamMemberResponse> get copyWith => _$TeamMemberResponseCopyWithImpl<TeamMemberResponse>(this as TeamMemberResponse, _$identity);

  /// Serializes this TeamMemberResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamMemberResponse&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other.roles, roles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,role,const DeepCollectionEquality().hash(roles));

@override
String toString() {
  return 'TeamMemberResponse(userId: $userId, role: $role, roles: $roles)';
}


}

/// @nodoc
abstract mixin class $TeamMemberResponseCopyWith<$Res>  {
  factory $TeamMemberResponseCopyWith(TeamMemberResponse value, $Res Function(TeamMemberResponse) _then) = _$TeamMemberResponseCopyWithImpl;
@useResult
$Res call({
 int userId, String role, List<TeamMemberRoleResponse> roles
});




}
/// @nodoc
class _$TeamMemberResponseCopyWithImpl<$Res>
    implements $TeamMemberResponseCopyWith<$Res> {
  _$TeamMemberResponseCopyWithImpl(this._self, this._then);

  final TeamMemberResponse _self;
  final $Res Function(TeamMemberResponse) _then;

/// Create a copy of TeamMemberResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? role = null,Object? roles = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<TeamMemberRoleResponse>,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamMemberResponse].
extension TeamMemberResponsePatterns on TeamMemberResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamMemberResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamMemberResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamMemberResponse value)  $default,){
final _that = this;
switch (_that) {
case _TeamMemberResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamMemberResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TeamMemberResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int userId,  String role,  List<TeamMemberRoleResponse> roles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamMemberResponse() when $default != null:
return $default(_that.userId,_that.role,_that.roles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int userId,  String role,  List<TeamMemberRoleResponse> roles)  $default,) {final _that = this;
switch (_that) {
case _TeamMemberResponse():
return $default(_that.userId,_that.role,_that.roles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int userId,  String role,  List<TeamMemberRoleResponse> roles)?  $default,) {final _that = this;
switch (_that) {
case _TeamMemberResponse() when $default != null:
return $default(_that.userId,_that.role,_that.roles);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamMemberResponse implements TeamMemberResponse {
  const _TeamMemberResponse({required this.userId, this.role = 'MEMBER', final  List<TeamMemberRoleResponse> roles = const []}): _roles = roles;
  factory _TeamMemberResponse.fromJson(Map<String, dynamic> json) => _$TeamMemberResponseFromJson(json);

@override final  int userId;
/// `OWNER` / `ADMIN` / `MEMBER`.
@override@JsonKey() final  String role;
/// 사용자가 받은 커스텀 역할. 모든 멤버에게 자동으로 붙는 기본 역할도 들어 있다.
 final  List<TeamMemberRoleResponse> _roles;
/// 사용자가 받은 커스텀 역할. 모든 멤버에게 자동으로 붙는 기본 역할도 들어 있다.
@override@JsonKey() List<TeamMemberRoleResponse> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}


/// Create a copy of TeamMemberResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamMemberResponseCopyWith<_TeamMemberResponse> get copyWith => __$TeamMemberResponseCopyWithImpl<_TeamMemberResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamMemberResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamMemberResponse&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other._roles, _roles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,role,const DeepCollectionEquality().hash(_roles));

@override
String toString() {
  return 'TeamMemberResponse(userId: $userId, role: $role, roles: $roles)';
}


}

/// @nodoc
abstract mixin class _$TeamMemberResponseCopyWith<$Res> implements $TeamMemberResponseCopyWith<$Res> {
  factory _$TeamMemberResponseCopyWith(_TeamMemberResponse value, $Res Function(_TeamMemberResponse) _then) = __$TeamMemberResponseCopyWithImpl;
@override @useResult
$Res call({
 int userId, String role, List<TeamMemberRoleResponse> roles
});




}
/// @nodoc
class __$TeamMemberResponseCopyWithImpl<$Res>
    implements _$TeamMemberResponseCopyWith<$Res> {
  __$TeamMemberResponseCopyWithImpl(this._self, this._then);

  final _TeamMemberResponse _self;
  final $Res Function(_TeamMemberResponse) _then;

/// Create a copy of TeamMemberResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? role = null,Object? roles = null,}) {
  return _then(_TeamMemberResponse(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<TeamMemberRoleResponse>,
  ));
}


}


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
