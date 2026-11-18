// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'github_label_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GithubLabelResponse {

 String get name; String get color;
/// Create a copy of GithubLabelResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubLabelResponseCopyWith<GithubLabelResponse> get copyWith => _$GithubLabelResponseCopyWithImpl<GithubLabelResponse>(this as GithubLabelResponse, _$identity);

  /// Serializes this GithubLabelResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubLabelResponse&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,color);

@override
String toString() {
  return 'GithubLabelResponse(name: $name, color: $color)';
}


}

/// @nodoc
abstract mixin class $GithubLabelResponseCopyWith<$Res>  {
  factory $GithubLabelResponseCopyWith(GithubLabelResponse value, $Res Function(GithubLabelResponse) _then) = _$GithubLabelResponseCopyWithImpl;
@useResult
$Res call({
 String name, String color
});




}
/// @nodoc
class _$GithubLabelResponseCopyWithImpl<$Res>
    implements $GithubLabelResponseCopyWith<$Res> {
  _$GithubLabelResponseCopyWithImpl(this._self, this._then);

  final GithubLabelResponse _self;
  final $Res Function(GithubLabelResponse) _then;

/// Create a copy of GithubLabelResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? color = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GithubLabelResponse].
extension GithubLabelResponsePatterns on GithubLabelResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GithubLabelResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GithubLabelResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GithubLabelResponse value)  $default,){
final _that = this;
switch (_that) {
case _GithubLabelResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GithubLabelResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GithubLabelResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GithubLabelResponse() when $default != null:
return $default(_that.name,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String color)  $default,) {final _that = this;
switch (_that) {
case _GithubLabelResponse():
return $default(_that.name,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String color)?  $default,) {final _that = this;
switch (_that) {
case _GithubLabelResponse() when $default != null:
return $default(_that.name,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GithubLabelResponse implements GithubLabelResponse {
  const _GithubLabelResponse({required this.name, this.color = ''});
  factory _GithubLabelResponse.fromJson(Map<String, dynamic> json) => _$GithubLabelResponseFromJson(json);

@override final  String name;
@override@JsonKey() final  String color;

/// Create a copy of GithubLabelResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GithubLabelResponseCopyWith<_GithubLabelResponse> get copyWith => __$GithubLabelResponseCopyWithImpl<_GithubLabelResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GithubLabelResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GithubLabelResponse&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,color);

@override
String toString() {
  return 'GithubLabelResponse(name: $name, color: $color)';
}


}

/// @nodoc
abstract mixin class _$GithubLabelResponseCopyWith<$Res> implements $GithubLabelResponseCopyWith<$Res> {
  factory _$GithubLabelResponseCopyWith(_GithubLabelResponse value, $Res Function(_GithubLabelResponse) _then) = __$GithubLabelResponseCopyWithImpl;
@override @useResult
$Res call({
 String name, String color
});




}
/// @nodoc
class __$GithubLabelResponseCopyWithImpl<$Res>
    implements _$GithubLabelResponseCopyWith<$Res> {
  __$GithubLabelResponseCopyWithImpl(this._self, this._then);

  final _GithubLabelResponse _self;
  final $Res Function(_GithubLabelResponse) _then;

/// Create a copy of GithubLabelResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? color = null,}) {
  return _then(_GithubLabelResponse(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
