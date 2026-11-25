// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webhook_author_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WebhookAuthorResponse {

/// 웹훅 id. 사용자 id 와 다른 번호 체계다.
 int get id; String get name; String? get avatarUrl;
/// Create a copy of WebhookAuthorResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebhookAuthorResponseCopyWith<WebhookAuthorResponse> get copyWith => _$WebhookAuthorResponseCopyWithImpl<WebhookAuthorResponse>(this as WebhookAuthorResponse, _$identity);

  /// Serializes this WebhookAuthorResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebhookAuthorResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl);

@override
String toString() {
  return 'WebhookAuthorResponse(id: $id, name: $name, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $WebhookAuthorResponseCopyWith<$Res>  {
  factory $WebhookAuthorResponseCopyWith(WebhookAuthorResponse value, $Res Function(WebhookAuthorResponse) _then) = _$WebhookAuthorResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? avatarUrl
});




}
/// @nodoc
class _$WebhookAuthorResponseCopyWithImpl<$Res>
    implements $WebhookAuthorResponseCopyWith<$Res> {
  _$WebhookAuthorResponseCopyWithImpl(this._self, this._then);

  final WebhookAuthorResponse _self;
  final $Res Function(WebhookAuthorResponse) _then;

/// Create a copy of WebhookAuthorResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WebhookAuthorResponse].
extension WebhookAuthorResponsePatterns on WebhookAuthorResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WebhookAuthorResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WebhookAuthorResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WebhookAuthorResponse value)  $default,){
final _that = this;
switch (_that) {
case _WebhookAuthorResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WebhookAuthorResponse value)?  $default,){
final _that = this;
switch (_that) {
case _WebhookAuthorResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WebhookAuthorResponse() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _WebhookAuthorResponse():
return $default(_that.id,_that.name,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _WebhookAuthorResponse() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _WebhookAuthorResponse implements WebhookAuthorResponse {
  const _WebhookAuthorResponse({required this.id, this.name = '', this.avatarUrl});
  factory _WebhookAuthorResponse.fromJson(Map<String, dynamic> json) => _$WebhookAuthorResponseFromJson(json);

/// 웹훅 id. 사용자 id 와 다른 번호 체계다.
@override final  int id;
@override@JsonKey() final  String name;
@override final  String? avatarUrl;

/// Create a copy of WebhookAuthorResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebhookAuthorResponseCopyWith<_WebhookAuthorResponse> get copyWith => __$WebhookAuthorResponseCopyWithImpl<_WebhookAuthorResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WebhookAuthorResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebhookAuthorResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl);

@override
String toString() {
  return 'WebhookAuthorResponse(id: $id, name: $name, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$WebhookAuthorResponseCopyWith<$Res> implements $WebhookAuthorResponseCopyWith<$Res> {
  factory _$WebhookAuthorResponseCopyWith(_WebhookAuthorResponse value, $Res Function(_WebhookAuthorResponse) _then) = __$WebhookAuthorResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? avatarUrl
});




}
/// @nodoc
class __$WebhookAuthorResponseCopyWithImpl<$Res>
    implements _$WebhookAuthorResponseCopyWith<$Res> {
  __$WebhookAuthorResponseCopyWithImpl(this._self, this._then);

  final _WebhookAuthorResponse _self;
  final $Res Function(_WebhookAuthorResponse) _then;

/// Create a copy of WebhookAuthorResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,}) {
  return _then(_WebhookAuthorResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
