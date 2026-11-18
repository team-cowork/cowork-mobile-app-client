// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_thread_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateThreadRequest {

 String get name; String get parentMessageId;
/// Create a copy of CreateThreadRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateThreadRequestCopyWith<CreateThreadRequest> get copyWith => _$CreateThreadRequestCopyWithImpl<CreateThreadRequest>(this as CreateThreadRequest, _$identity);

  /// Serializes this CreateThreadRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateThreadRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.parentMessageId, parentMessageId) || other.parentMessageId == parentMessageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,parentMessageId);

@override
String toString() {
  return 'CreateThreadRequest(name: $name, parentMessageId: $parentMessageId)';
}


}

/// @nodoc
abstract mixin class $CreateThreadRequestCopyWith<$Res>  {
  factory $CreateThreadRequestCopyWith(CreateThreadRequest value, $Res Function(CreateThreadRequest) _then) = _$CreateThreadRequestCopyWithImpl;
@useResult
$Res call({
 String name, String parentMessageId
});




}
/// @nodoc
class _$CreateThreadRequestCopyWithImpl<$Res>
    implements $CreateThreadRequestCopyWith<$Res> {
  _$CreateThreadRequestCopyWithImpl(this._self, this._then);

  final CreateThreadRequest _self;
  final $Res Function(CreateThreadRequest) _then;

/// Create a copy of CreateThreadRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? parentMessageId = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentMessageId: null == parentMessageId ? _self.parentMessageId : parentMessageId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateThreadRequest].
extension CreateThreadRequestPatterns on CreateThreadRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateThreadRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateThreadRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateThreadRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateThreadRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateThreadRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateThreadRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String parentMessageId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateThreadRequest() when $default != null:
return $default(_that.name,_that.parentMessageId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String parentMessageId)  $default,) {final _that = this;
switch (_that) {
case _CreateThreadRequest():
return $default(_that.name,_that.parentMessageId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String parentMessageId)?  $default,) {final _that = this;
switch (_that) {
case _CreateThreadRequest() when $default != null:
return $default(_that.name,_that.parentMessageId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _CreateThreadRequest implements CreateThreadRequest {
  const _CreateThreadRequest({required this.name, required this.parentMessageId});
  

@override final  String name;
@override final  String parentMessageId;

/// Create a copy of CreateThreadRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateThreadRequestCopyWith<_CreateThreadRequest> get copyWith => __$CreateThreadRequestCopyWithImpl<_CreateThreadRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateThreadRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateThreadRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.parentMessageId, parentMessageId) || other.parentMessageId == parentMessageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,parentMessageId);

@override
String toString() {
  return 'CreateThreadRequest(name: $name, parentMessageId: $parentMessageId)';
}


}

/// @nodoc
abstract mixin class _$CreateThreadRequestCopyWith<$Res> implements $CreateThreadRequestCopyWith<$Res> {
  factory _$CreateThreadRequestCopyWith(_CreateThreadRequest value, $Res Function(_CreateThreadRequest) _then) = __$CreateThreadRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String parentMessageId
});




}
/// @nodoc
class __$CreateThreadRequestCopyWithImpl<$Res>
    implements _$CreateThreadRequestCopyWith<$Res> {
  __$CreateThreadRequestCopyWithImpl(this._self, this._then);

  final _CreateThreadRequest _self;
  final $Res Function(_CreateThreadRequest) _then;

/// Create a copy of CreateThreadRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? parentMessageId = null,}) {
  return _then(_CreateThreadRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentMessageId: null == parentMessageId ? _self.parentMessageId : parentMessageId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
