// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting_note_template_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MeetingNoteTemplateRequest {

 String get name;
/// Create a copy of MeetingNoteTemplateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeetingNoteTemplateRequestCopyWith<MeetingNoteTemplateRequest> get copyWith => _$MeetingNoteTemplateRequestCopyWithImpl<MeetingNoteTemplateRequest>(this as MeetingNoteTemplateRequest, _$identity);

  /// Serializes this MeetingNoteTemplateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeetingNoteTemplateRequest&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'MeetingNoteTemplateRequest(name: $name)';
}


}

/// @nodoc
abstract mixin class $MeetingNoteTemplateRequestCopyWith<$Res>  {
  factory $MeetingNoteTemplateRequestCopyWith(MeetingNoteTemplateRequest value, $Res Function(MeetingNoteTemplateRequest) _then) = _$MeetingNoteTemplateRequestCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$MeetingNoteTemplateRequestCopyWithImpl<$Res>
    implements $MeetingNoteTemplateRequestCopyWith<$Res> {
  _$MeetingNoteTemplateRequestCopyWithImpl(this._self, this._then);

  final MeetingNoteTemplateRequest _self;
  final $Res Function(MeetingNoteTemplateRequest) _then;

/// Create a copy of MeetingNoteTemplateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MeetingNoteTemplateRequest].
extension MeetingNoteTemplateRequestPatterns on MeetingNoteTemplateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeetingNoteTemplateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeetingNoteTemplateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeetingNoteTemplateRequest value)  $default,){
final _that = this;
switch (_that) {
case _MeetingNoteTemplateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeetingNoteTemplateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MeetingNoteTemplateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeetingNoteTemplateRequest() when $default != null:
return $default(_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name)  $default,) {final _that = this;
switch (_that) {
case _MeetingNoteTemplateRequest():
return $default(_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name)?  $default,) {final _that = this;
switch (_that) {
case _MeetingNoteTemplateRequest() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _MeetingNoteTemplateRequest implements MeetingNoteTemplateRequest {
  const _MeetingNoteTemplateRequest({required this.name});
  

@override final  String name;

/// Create a copy of MeetingNoteTemplateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeetingNoteTemplateRequestCopyWith<_MeetingNoteTemplateRequest> get copyWith => __$MeetingNoteTemplateRequestCopyWithImpl<_MeetingNoteTemplateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeetingNoteTemplateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeetingNoteTemplateRequest&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'MeetingNoteTemplateRequest(name: $name)';
}


}

/// @nodoc
abstract mixin class _$MeetingNoteTemplateRequestCopyWith<$Res> implements $MeetingNoteTemplateRequestCopyWith<$Res> {
  factory _$MeetingNoteTemplateRequestCopyWith(_MeetingNoteTemplateRequest value, $Res Function(_MeetingNoteTemplateRequest) _then) = __$MeetingNoteTemplateRequestCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class __$MeetingNoteTemplateRequestCopyWithImpl<$Res>
    implements _$MeetingNoteTemplateRequestCopyWith<$Res> {
  __$MeetingNoteTemplateRequestCopyWithImpl(this._self, this._then);

  final _MeetingNoteTemplateRequest _self;
  final $Res Function(_MeetingNoteTemplateRequest) _then;

/// Create a copy of MeetingNoteTemplateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_MeetingNoteTemplateRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
