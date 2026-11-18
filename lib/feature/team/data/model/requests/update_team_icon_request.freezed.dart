// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_team_icon_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateTeamIconRequest {

/// `POST /teams/icon/confirm` 이 돌려준 URL. 직접 업로드하고 확인한 것만 받는다.
 String get iconUrl;
/// Create a copy of UpdateTeamIconRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateTeamIconRequestCopyWith<UpdateTeamIconRequest> get copyWith => _$UpdateTeamIconRequestCopyWithImpl<UpdateTeamIconRequest>(this as UpdateTeamIconRequest, _$identity);

  /// Serializes this UpdateTeamIconRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateTeamIconRequest&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iconUrl);

@override
String toString() {
  return 'UpdateTeamIconRequest(iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class $UpdateTeamIconRequestCopyWith<$Res>  {
  factory $UpdateTeamIconRequestCopyWith(UpdateTeamIconRequest value, $Res Function(UpdateTeamIconRequest) _then) = _$UpdateTeamIconRequestCopyWithImpl;
@useResult
$Res call({
 String iconUrl
});




}
/// @nodoc
class _$UpdateTeamIconRequestCopyWithImpl<$Res>
    implements $UpdateTeamIconRequestCopyWith<$Res> {
  _$UpdateTeamIconRequestCopyWithImpl(this._self, this._then);

  final UpdateTeamIconRequest _self;
  final $Res Function(UpdateTeamIconRequest) _then;

/// Create a copy of UpdateTeamIconRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? iconUrl = null,}) {
  return _then(_self.copyWith(
iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateTeamIconRequest].
extension UpdateTeamIconRequestPatterns on UpdateTeamIconRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateTeamIconRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateTeamIconRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateTeamIconRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateTeamIconRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateTeamIconRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateTeamIconRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String iconUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateTeamIconRequest() when $default != null:
return $default(_that.iconUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String iconUrl)  $default,) {final _that = this;
switch (_that) {
case _UpdateTeamIconRequest():
return $default(_that.iconUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String iconUrl)?  $default,) {final _that = this;
switch (_that) {
case _UpdateTeamIconRequest() when $default != null:
return $default(_that.iconUrl);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(createFactory: false)
class _UpdateTeamIconRequest implements UpdateTeamIconRequest {
  const _UpdateTeamIconRequest({required this.iconUrl});
  

/// `POST /teams/icon/confirm` 이 돌려준 URL. 직접 업로드하고 확인한 것만 받는다.
@override final  String iconUrl;

/// Create a copy of UpdateTeamIconRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateTeamIconRequestCopyWith<_UpdateTeamIconRequest> get copyWith => __$UpdateTeamIconRequestCopyWithImpl<_UpdateTeamIconRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateTeamIconRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateTeamIconRequest&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iconUrl);

@override
String toString() {
  return 'UpdateTeamIconRequest(iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class _$UpdateTeamIconRequestCopyWith<$Res> implements $UpdateTeamIconRequestCopyWith<$Res> {
  factory _$UpdateTeamIconRequestCopyWith(_UpdateTeamIconRequest value, $Res Function(_UpdateTeamIconRequest) _then) = __$UpdateTeamIconRequestCopyWithImpl;
@override @useResult
$Res call({
 String iconUrl
});




}
/// @nodoc
class __$UpdateTeamIconRequestCopyWithImpl<$Res>
    implements _$UpdateTeamIconRequestCopyWith<$Res> {
  __$UpdateTeamIconRequestCopyWithImpl(this._self, this._then);

  final _UpdateTeamIconRequest _self;
  final $Res Function(_UpdateTeamIconRequest) _then;

/// Create a copy of UpdateTeamIconRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? iconUrl = null,}) {
  return _then(_UpdateTeamIconRequest(
iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
