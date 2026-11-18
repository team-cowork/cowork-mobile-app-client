// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_icon_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeamIconResponse {

/// 업로드를 마친 아이콘의 CDN URL.
 String get iconUrl;
/// Create a copy of TeamIconResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamIconResponseCopyWith<TeamIconResponse> get copyWith => _$TeamIconResponseCopyWithImpl<TeamIconResponse>(this as TeamIconResponse, _$identity);

  /// Serializes this TeamIconResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamIconResponse&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iconUrl);

@override
String toString() {
  return 'TeamIconResponse(iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class $TeamIconResponseCopyWith<$Res>  {
  factory $TeamIconResponseCopyWith(TeamIconResponse value, $Res Function(TeamIconResponse) _then) = _$TeamIconResponseCopyWithImpl;
@useResult
$Res call({
 String iconUrl
});




}
/// @nodoc
class _$TeamIconResponseCopyWithImpl<$Res>
    implements $TeamIconResponseCopyWith<$Res> {
  _$TeamIconResponseCopyWithImpl(this._self, this._then);

  final TeamIconResponse _self;
  final $Res Function(TeamIconResponse) _then;

/// Create a copy of TeamIconResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? iconUrl = null,}) {
  return _then(_self.copyWith(
iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamIconResponse].
extension TeamIconResponsePatterns on TeamIconResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamIconResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamIconResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamIconResponse value)  $default,){
final _that = this;
switch (_that) {
case _TeamIconResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamIconResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TeamIconResponse() when $default != null:
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
case _TeamIconResponse() when $default != null:
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
case _TeamIconResponse():
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
case _TeamIconResponse() when $default != null:
return $default(_that.iconUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamIconResponse implements TeamIconResponse {
  const _TeamIconResponse({required this.iconUrl});
  factory _TeamIconResponse.fromJson(Map<String, dynamic> json) => _$TeamIconResponseFromJson(json);

/// 업로드를 마친 아이콘의 CDN URL.
@override final  String iconUrl;

/// Create a copy of TeamIconResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamIconResponseCopyWith<_TeamIconResponse> get copyWith => __$TeamIconResponseCopyWithImpl<_TeamIconResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamIconResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamIconResponse&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iconUrl);

@override
String toString() {
  return 'TeamIconResponse(iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class _$TeamIconResponseCopyWith<$Res> implements $TeamIconResponseCopyWith<$Res> {
  factory _$TeamIconResponseCopyWith(_TeamIconResponse value, $Res Function(_TeamIconResponse) _then) = __$TeamIconResponseCopyWithImpl;
@override @useResult
$Res call({
 String iconUrl
});




}
/// @nodoc
class __$TeamIconResponseCopyWithImpl<$Res>
    implements _$TeamIconResponseCopyWith<$Res> {
  __$TeamIconResponseCopyWithImpl(this._self, this._then);

  final _TeamIconResponse _self;
  final $Res Function(_TeamIconResponse) _then;

/// Create a copy of TeamIconResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? iconUrl = null,}) {
  return _then(_TeamIconResponse(
iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
