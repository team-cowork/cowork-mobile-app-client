// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_channel_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateChannelRequest {

 String? get name; String? get description; bool? get isPrivate;
/// Create a copy of UpdateChannelRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateChannelRequestCopyWith<UpdateChannelRequest> get copyWith => _$UpdateChannelRequestCopyWithImpl<UpdateChannelRequest>(this as UpdateChannelRequest, _$identity);

  /// Serializes this UpdateChannelRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateChannelRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,isPrivate);

@override
String toString() {
  return 'UpdateChannelRequest(name: $name, description: $description, isPrivate: $isPrivate)';
}


}

/// @nodoc
abstract mixin class $UpdateChannelRequestCopyWith<$Res>  {
  factory $UpdateChannelRequestCopyWith(UpdateChannelRequest value, $Res Function(UpdateChannelRequest) _then) = _$UpdateChannelRequestCopyWithImpl;
@useResult
$Res call({
 String? name, String? description, bool? isPrivate
});




}
/// @nodoc
class _$UpdateChannelRequestCopyWithImpl<$Res>
    implements $UpdateChannelRequestCopyWith<$Res> {
  _$UpdateChannelRequestCopyWithImpl(this._self, this._then);

  final UpdateChannelRequest _self;
  final $Res Function(UpdateChannelRequest) _then;

/// Create a copy of UpdateChannelRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? description = freezed,Object? isPrivate = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPrivate: freezed == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateChannelRequest].
extension UpdateChannelRequestPatterns on UpdateChannelRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateChannelRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateChannelRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateChannelRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateChannelRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateChannelRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateChannelRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? description,  bool? isPrivate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateChannelRequest() when $default != null:
return $default(_that.name,_that.description,_that.isPrivate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? description,  bool? isPrivate)  $default,) {final _that = this;
switch (_that) {
case _UpdateChannelRequest():
return $default(_that.name,_that.description,_that.isPrivate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? description,  bool? isPrivate)?  $default,) {final _that = this;
switch (_that) {
case _UpdateChannelRequest() when $default != null:
return $default(_that.name,_that.description,_that.isPrivate);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _UpdateChannelRequest implements UpdateChannelRequest {
  const _UpdateChannelRequest({this.name, this.description, this.isPrivate});
  

@override final  String? name;
@override final  String? description;
@override final  bool? isPrivate;

/// Create a copy of UpdateChannelRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateChannelRequestCopyWith<_UpdateChannelRequest> get copyWith => __$UpdateChannelRequestCopyWithImpl<_UpdateChannelRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateChannelRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateChannelRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,isPrivate);

@override
String toString() {
  return 'UpdateChannelRequest(name: $name, description: $description, isPrivate: $isPrivate)';
}


}

/// @nodoc
abstract mixin class _$UpdateChannelRequestCopyWith<$Res> implements $UpdateChannelRequestCopyWith<$Res> {
  factory _$UpdateChannelRequestCopyWith(_UpdateChannelRequest value, $Res Function(_UpdateChannelRequest) _then) = __$UpdateChannelRequestCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? description, bool? isPrivate
});




}
/// @nodoc
class __$UpdateChannelRequestCopyWithImpl<$Res>
    implements _$UpdateChannelRequestCopyWith<$Res> {
  __$UpdateChannelRequestCopyWithImpl(this._self, this._then);

  final _UpdateChannelRequest _self;
  final $Res Function(_UpdateChannelRequest) _then;

/// Create a copy of UpdateChannelRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? description = freezed,Object? isPrivate = freezed,}) {
  return _then(_UpdateChannelRequest(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPrivate: freezed == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
