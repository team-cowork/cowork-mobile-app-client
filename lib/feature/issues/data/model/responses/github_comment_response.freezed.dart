// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'github_comment_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GithubCommentResponse {

 int get id;/// 작성자 GitHub 사용자명.
 String get author; String get body; DateTime get createdAt;
/// Create a copy of GithubCommentResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubCommentResponseCopyWith<GithubCommentResponse> get copyWith => _$GithubCommentResponseCopyWithImpl<GithubCommentResponse>(this as GithubCommentResponse, _$identity);

  /// Serializes this GithubCommentResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubCommentResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.body, body) || other.body == body)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,body,createdAt);

@override
String toString() {
  return 'GithubCommentResponse(id: $id, author: $author, body: $body, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GithubCommentResponseCopyWith<$Res>  {
  factory $GithubCommentResponseCopyWith(GithubCommentResponse value, $Res Function(GithubCommentResponse) _then) = _$GithubCommentResponseCopyWithImpl;
@useResult
$Res call({
 int id, String author, String body, DateTime createdAt
});




}
/// @nodoc
class _$GithubCommentResponseCopyWithImpl<$Res>
    implements $GithubCommentResponseCopyWith<$Res> {
  _$GithubCommentResponseCopyWithImpl(this._self, this._then);

  final GithubCommentResponse _self;
  final $Res Function(GithubCommentResponse) _then;

/// Create a copy of GithubCommentResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? author = null,Object? body = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GithubCommentResponse].
extension GithubCommentResponsePatterns on GithubCommentResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GithubCommentResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GithubCommentResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GithubCommentResponse value)  $default,){
final _that = this;
switch (_that) {
case _GithubCommentResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GithubCommentResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GithubCommentResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String author,  String body,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GithubCommentResponse() when $default != null:
return $default(_that.id,_that.author,_that.body,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String author,  String body,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _GithubCommentResponse():
return $default(_that.id,_that.author,_that.body,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String author,  String body,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GithubCommentResponse() when $default != null:
return $default(_that.id,_that.author,_that.body,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GithubCommentResponse implements GithubCommentResponse {
  const _GithubCommentResponse({required this.id, this.author = '', this.body = '', required this.createdAt});
  factory _GithubCommentResponse.fromJson(Map<String, dynamic> json) => _$GithubCommentResponseFromJson(json);

@override final  int id;
/// 작성자 GitHub 사용자명.
@override@JsonKey() final  String author;
@override@JsonKey() final  String body;
@override final  DateTime createdAt;

/// Create a copy of GithubCommentResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GithubCommentResponseCopyWith<_GithubCommentResponse> get copyWith => __$GithubCommentResponseCopyWithImpl<_GithubCommentResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GithubCommentResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GithubCommentResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.body, body) || other.body == body)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,body,createdAt);

@override
String toString() {
  return 'GithubCommentResponse(id: $id, author: $author, body: $body, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GithubCommentResponseCopyWith<$Res> implements $GithubCommentResponseCopyWith<$Res> {
  factory _$GithubCommentResponseCopyWith(_GithubCommentResponse value, $Res Function(_GithubCommentResponse) _then) = __$GithubCommentResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String author, String body, DateTime createdAt
});




}
/// @nodoc
class __$GithubCommentResponseCopyWithImpl<$Res>
    implements _$GithubCommentResponseCopyWith<$Res> {
  __$GithubCommentResponseCopyWithImpl(this._self, this._then);

  final _GithubCommentResponse _self;
  final $Res Function(_GithubCommentResponse) _then;

/// Create a copy of GithubCommentResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? author = null,Object? body = null,Object? createdAt = null,}) {
  return _then(_GithubCommentResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
