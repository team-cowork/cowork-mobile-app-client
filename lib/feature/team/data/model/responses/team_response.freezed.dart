// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeamResponse {

 int get id; String get name;/// 정한 적 없으면 null, 지웠으면 빈 문자열로 온다.
 String? get description;/// 아이콘이 없으면 null.
 String? get iconUrl;/// 소유자 사용자 id.
 int? get ownerId;
/// Create a copy of TeamResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamResponseCopyWith<TeamResponse> get copyWith => _$TeamResponseCopyWithImpl<TeamResponse>(this as TeamResponse, _$identity);

  /// Serializes this TeamResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,iconUrl,ownerId);

@override
String toString() {
  return 'TeamResponse(id: $id, name: $name, description: $description, iconUrl: $iconUrl, ownerId: $ownerId)';
}


}

/// @nodoc
abstract mixin class $TeamResponseCopyWith<$Res>  {
  factory $TeamResponseCopyWith(TeamResponse value, $Res Function(TeamResponse) _then) = _$TeamResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? description, String? iconUrl, int? ownerId
});




}
/// @nodoc
class _$TeamResponseCopyWithImpl<$Res>
    implements $TeamResponseCopyWith<$Res> {
  _$TeamResponseCopyWithImpl(this._self, this._then);

  final TeamResponse _self;
  final $Res Function(TeamResponse) _then;

/// Create a copy of TeamResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? iconUrl = freezed,Object? ownerId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamResponse].
extension TeamResponsePatterns on TeamResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamResponse value)  $default,){
final _that = this;
switch (_that) {
case _TeamResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TeamResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? description,  String? iconUrl,  int? ownerId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamResponse() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.iconUrl,_that.ownerId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? description,  String? iconUrl,  int? ownerId)  $default,) {final _that = this;
switch (_that) {
case _TeamResponse():
return $default(_that.id,_that.name,_that.description,_that.iconUrl,_that.ownerId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? description,  String? iconUrl,  int? ownerId)?  $default,) {final _that = this;
switch (_that) {
case _TeamResponse() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.iconUrl,_that.ownerId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamResponse extends TeamResponse {
  const _TeamResponse({required this.id, this.name = '', this.description, this.iconUrl, this.ownerId}): super._();
  factory _TeamResponse.fromJson(Map<String, dynamic> json) => _$TeamResponseFromJson(json);

@override final  int id;
@override@JsonKey() final  String name;
/// 정한 적 없으면 null, 지웠으면 빈 문자열로 온다.
@override final  String? description;
/// 아이콘이 없으면 null.
@override final  String? iconUrl;
/// 소유자 사용자 id.
@override final  int? ownerId;

/// Create a copy of TeamResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamResponseCopyWith<_TeamResponse> get copyWith => __$TeamResponseCopyWithImpl<_TeamResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,iconUrl,ownerId);

@override
String toString() {
  return 'TeamResponse(id: $id, name: $name, description: $description, iconUrl: $iconUrl, ownerId: $ownerId)';
}


}

/// @nodoc
abstract mixin class _$TeamResponseCopyWith<$Res> implements $TeamResponseCopyWith<$Res> {
  factory _$TeamResponseCopyWith(_TeamResponse value, $Res Function(_TeamResponse) _then) = __$TeamResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? description, String? iconUrl, int? ownerId
});




}
/// @nodoc
class __$TeamResponseCopyWithImpl<$Res>
    implements _$TeamResponseCopyWith<$Res> {
  __$TeamResponseCopyWithImpl(this._self, this._then);

  final _TeamResponse _self;
  final $Res Function(_TeamResponse) _then;

/// Create a copy of TeamResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? iconUrl = freezed,Object? ownerId = freezed,}) {
  return _then(_TeamResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
