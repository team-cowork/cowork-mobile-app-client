// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_github_repo_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectGithubRepoResponse {

 int get id; String get githubRepoUrl;
/// Create a copy of ProjectGithubRepoResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectGithubRepoResponseCopyWith<ProjectGithubRepoResponse> get copyWith => _$ProjectGithubRepoResponseCopyWithImpl<ProjectGithubRepoResponse>(this as ProjectGithubRepoResponse, _$identity);

  /// Serializes this ProjectGithubRepoResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectGithubRepoResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.githubRepoUrl, githubRepoUrl) || other.githubRepoUrl == githubRepoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,githubRepoUrl);

@override
String toString() {
  return 'ProjectGithubRepoResponse(id: $id, githubRepoUrl: $githubRepoUrl)';
}


}

/// @nodoc
abstract mixin class $ProjectGithubRepoResponseCopyWith<$Res>  {
  factory $ProjectGithubRepoResponseCopyWith(ProjectGithubRepoResponse value, $Res Function(ProjectGithubRepoResponse) _then) = _$ProjectGithubRepoResponseCopyWithImpl;
@useResult
$Res call({
 int id, String githubRepoUrl
});




}
/// @nodoc
class _$ProjectGithubRepoResponseCopyWithImpl<$Res>
    implements $ProjectGithubRepoResponseCopyWith<$Res> {
  _$ProjectGithubRepoResponseCopyWithImpl(this._self, this._then);

  final ProjectGithubRepoResponse _self;
  final $Res Function(ProjectGithubRepoResponse) _then;

/// Create a copy of ProjectGithubRepoResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? githubRepoUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,githubRepoUrl: null == githubRepoUrl ? _self.githubRepoUrl : githubRepoUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectGithubRepoResponse].
extension ProjectGithubRepoResponsePatterns on ProjectGithubRepoResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectGithubRepoResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectGithubRepoResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectGithubRepoResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProjectGithubRepoResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectGithubRepoResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectGithubRepoResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String githubRepoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectGithubRepoResponse() when $default != null:
return $default(_that.id,_that.githubRepoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String githubRepoUrl)  $default,) {final _that = this;
switch (_that) {
case _ProjectGithubRepoResponse():
return $default(_that.id,_that.githubRepoUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String githubRepoUrl)?  $default,) {final _that = this;
switch (_that) {
case _ProjectGithubRepoResponse() when $default != null:
return $default(_that.id,_that.githubRepoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectGithubRepoResponse implements ProjectGithubRepoResponse {
  const _ProjectGithubRepoResponse({required this.id, this.githubRepoUrl = ''});
  factory _ProjectGithubRepoResponse.fromJson(Map<String, dynamic> json) => _$ProjectGithubRepoResponseFromJson(json);

@override final  int id;
@override@JsonKey() final  String githubRepoUrl;

/// Create a copy of ProjectGithubRepoResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectGithubRepoResponseCopyWith<_ProjectGithubRepoResponse> get copyWith => __$ProjectGithubRepoResponseCopyWithImpl<_ProjectGithubRepoResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectGithubRepoResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectGithubRepoResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.githubRepoUrl, githubRepoUrl) || other.githubRepoUrl == githubRepoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,githubRepoUrl);

@override
String toString() {
  return 'ProjectGithubRepoResponse(id: $id, githubRepoUrl: $githubRepoUrl)';
}


}

/// @nodoc
abstract mixin class _$ProjectGithubRepoResponseCopyWith<$Res> implements $ProjectGithubRepoResponseCopyWith<$Res> {
  factory _$ProjectGithubRepoResponseCopyWith(_ProjectGithubRepoResponse value, $Res Function(_ProjectGithubRepoResponse) _then) = __$ProjectGithubRepoResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String githubRepoUrl
});




}
/// @nodoc
class __$ProjectGithubRepoResponseCopyWithImpl<$Res>
    implements _$ProjectGithubRepoResponseCopyWith<$Res> {
  __$ProjectGithubRepoResponseCopyWithImpl(this._self, this._then);

  final _ProjectGithubRepoResponse _self;
  final $Res Function(_ProjectGithubRepoResponse) _then;

/// Create a copy of ProjectGithubRepoResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? githubRepoUrl = null,}) {
  return _then(_ProjectGithubRepoResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,githubRepoUrl: null == githubRepoUrl ? _self.githubRepoUrl : githubRepoUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
