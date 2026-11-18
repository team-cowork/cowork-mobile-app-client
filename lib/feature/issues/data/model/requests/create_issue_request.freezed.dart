// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_issue_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateIssueRequest {

 String get title; String? get body;/// 만들면서 붙일 라벨 하나.
 String? get label;
/// Create a copy of CreateIssueRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateIssueRequestCopyWith<CreateIssueRequest> get copyWith => _$CreateIssueRequestCopyWithImpl<CreateIssueRequest>(this as CreateIssueRequest, _$identity);

  /// Serializes this CreateIssueRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateIssueRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body,label);

@override
String toString() {
  return 'CreateIssueRequest(title: $title, body: $body, label: $label)';
}


}

/// @nodoc
abstract mixin class $CreateIssueRequestCopyWith<$Res>  {
  factory $CreateIssueRequestCopyWith(CreateIssueRequest value, $Res Function(CreateIssueRequest) _then) = _$CreateIssueRequestCopyWithImpl;
@useResult
$Res call({
 String title, String? body, String? label
});




}
/// @nodoc
class _$CreateIssueRequestCopyWithImpl<$Res>
    implements $CreateIssueRequestCopyWith<$Res> {
  _$CreateIssueRequestCopyWithImpl(this._self, this._then);

  final CreateIssueRequest _self;
  final $Res Function(CreateIssueRequest) _then;

/// Create a copy of CreateIssueRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? body = freezed,Object? label = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateIssueRequest].
extension CreateIssueRequestPatterns on CreateIssueRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateIssueRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateIssueRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateIssueRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateIssueRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateIssueRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateIssueRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? body,  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateIssueRequest() when $default != null:
return $default(_that.title,_that.body,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? body,  String? label)  $default,) {final _that = this;
switch (_that) {
case _CreateIssueRequest():
return $default(_that.title,_that.body,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? body,  String? label)?  $default,) {final _that = this;
switch (_that) {
case _CreateIssueRequest() when $default != null:
return $default(_that.title,_that.body,_that.label);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _CreateIssueRequest implements CreateIssueRequest {
  const _CreateIssueRequest({required this.title, this.body, this.label});
  

@override final  String title;
@override final  String? body;
/// 만들면서 붙일 라벨 하나.
@override final  String? label;

/// Create a copy of CreateIssueRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateIssueRequestCopyWith<_CreateIssueRequest> get copyWith => __$CreateIssueRequestCopyWithImpl<_CreateIssueRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateIssueRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateIssueRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body,label);

@override
String toString() {
  return 'CreateIssueRequest(title: $title, body: $body, label: $label)';
}


}

/// @nodoc
abstract mixin class _$CreateIssueRequestCopyWith<$Res> implements $CreateIssueRequestCopyWith<$Res> {
  factory _$CreateIssueRequestCopyWith(_CreateIssueRequest value, $Res Function(_CreateIssueRequest) _then) = __$CreateIssueRequestCopyWithImpl;
@override @useResult
$Res call({
 String title, String? body, String? label
});




}
/// @nodoc
class __$CreateIssueRequestCopyWithImpl<$Res>
    implements _$CreateIssueRequestCopyWith<$Res> {
  __$CreateIssueRequestCopyWithImpl(this._self, this._then);

  final _CreateIssueRequest _self;
  final $Res Function(_CreateIssueRequest) _then;

/// Create a copy of CreateIssueRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? body = freezed,Object? label = freezed,}) {
  return _then(_CreateIssueRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
