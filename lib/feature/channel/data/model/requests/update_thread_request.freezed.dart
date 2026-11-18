// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_thread_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateThreadRequest {

 String? get name; bool? get isArchived;
/// Create a copy of UpdateThreadRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateThreadRequestCopyWith<UpdateThreadRequest> get copyWith => _$UpdateThreadRequestCopyWithImpl<UpdateThreadRequest>(this as UpdateThreadRequest, _$identity);

  /// Serializes this UpdateThreadRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateThreadRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,isArchived);

@override
String toString() {
  return 'UpdateThreadRequest(name: $name, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class $UpdateThreadRequestCopyWith<$Res>  {
  factory $UpdateThreadRequestCopyWith(UpdateThreadRequest value, $Res Function(UpdateThreadRequest) _then) = _$UpdateThreadRequestCopyWithImpl;
@useResult
$Res call({
 String? name, bool? isArchived
});




}
/// @nodoc
class _$UpdateThreadRequestCopyWithImpl<$Res>
    implements $UpdateThreadRequestCopyWith<$Res> {
  _$UpdateThreadRequestCopyWithImpl(this._self, this._then);

  final UpdateThreadRequest _self;
  final $Res Function(UpdateThreadRequest) _then;

/// Create a copy of UpdateThreadRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? isArchived = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,isArchived: freezed == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateThreadRequest].
extension UpdateThreadRequestPatterns on UpdateThreadRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateThreadRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateThreadRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateThreadRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateThreadRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateThreadRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateThreadRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  bool? isArchived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateThreadRequest() when $default != null:
return $default(_that.name,_that.isArchived);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  bool? isArchived)  $default,) {final _that = this;
switch (_that) {
case _UpdateThreadRequest():
return $default(_that.name,_that.isArchived);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  bool? isArchived)?  $default,) {final _that = this;
switch (_that) {
case _UpdateThreadRequest() when $default != null:
return $default(_that.name,_that.isArchived);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _UpdateThreadRequest implements UpdateThreadRequest {
  const _UpdateThreadRequest({this.name, this.isArchived});
  

@override final  String? name;
@override final  bool? isArchived;

/// Create a copy of UpdateThreadRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateThreadRequestCopyWith<_UpdateThreadRequest> get copyWith => __$UpdateThreadRequestCopyWithImpl<_UpdateThreadRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateThreadRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateThreadRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,isArchived);

@override
String toString() {
  return 'UpdateThreadRequest(name: $name, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class _$UpdateThreadRequestCopyWith<$Res> implements $UpdateThreadRequestCopyWith<$Res> {
  factory _$UpdateThreadRequestCopyWith(_UpdateThreadRequest value, $Res Function(_UpdateThreadRequest) _then) = __$UpdateThreadRequestCopyWithImpl;
@override @useResult
$Res call({
 String? name, bool? isArchived
});




}
/// @nodoc
class __$UpdateThreadRequestCopyWithImpl<$Res>
    implements _$UpdateThreadRequestCopyWith<$Res> {
  __$UpdateThreadRequestCopyWithImpl(this._self, this._then);

  final _UpdateThreadRequest _self;
  final $Res Function(_UpdateThreadRequest) _then;

/// Create a copy of UpdateThreadRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? isArchived = freezed,}) {
  return _then(_UpdateThreadRequest(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,isArchived: freezed == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
