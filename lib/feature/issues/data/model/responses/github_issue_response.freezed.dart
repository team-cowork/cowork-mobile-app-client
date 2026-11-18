// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'github_issue_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GithubIssueResponse {

 int get number; String get title;/// 작성자 GitHub 사용자명.
 String get author; String get state; String get htmlUrl; List<String> get labels; DateTime get createdAt;
/// Create a copy of GithubIssueResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubIssueResponseCopyWith<GithubIssueResponse> get copyWith => _$GithubIssueResponseCopyWithImpl<GithubIssueResponse>(this as GithubIssueResponse, _$identity);

  /// Serializes this GithubIssueResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubIssueResponse&&(identical(other.number, number) || other.number == number)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.state, state) || other.state == state)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&const DeepCollectionEquality().equals(other.labels, labels)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,title,author,state,htmlUrl,const DeepCollectionEquality().hash(labels),createdAt);

@override
String toString() {
  return 'GithubIssueResponse(number: $number, title: $title, author: $author, state: $state, htmlUrl: $htmlUrl, labels: $labels, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GithubIssueResponseCopyWith<$Res>  {
  factory $GithubIssueResponseCopyWith(GithubIssueResponse value, $Res Function(GithubIssueResponse) _then) = _$GithubIssueResponseCopyWithImpl;
@useResult
$Res call({
 int number, String title, String author, String state, String htmlUrl, List<String> labels, DateTime createdAt
});




}
/// @nodoc
class _$GithubIssueResponseCopyWithImpl<$Res>
    implements $GithubIssueResponseCopyWith<$Res> {
  _$GithubIssueResponseCopyWithImpl(this._self, this._then);

  final GithubIssueResponse _self;
  final $Res Function(GithubIssueResponse) _then;

/// Create a copy of GithubIssueResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? title = null,Object? author = null,Object? state = null,Object? htmlUrl = null,Object? labels = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,htmlUrl: null == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GithubIssueResponse].
extension GithubIssueResponsePatterns on GithubIssueResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GithubIssueResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GithubIssueResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GithubIssueResponse value)  $default,){
final _that = this;
switch (_that) {
case _GithubIssueResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GithubIssueResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GithubIssueResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  String title,  String author,  String state,  String htmlUrl,  List<String> labels,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GithubIssueResponse() when $default != null:
return $default(_that.number,_that.title,_that.author,_that.state,_that.htmlUrl,_that.labels,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  String title,  String author,  String state,  String htmlUrl,  List<String> labels,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _GithubIssueResponse():
return $default(_that.number,_that.title,_that.author,_that.state,_that.htmlUrl,_that.labels,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  String title,  String author,  String state,  String htmlUrl,  List<String> labels,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GithubIssueResponse() when $default != null:
return $default(_that.number,_that.title,_that.author,_that.state,_that.htmlUrl,_that.labels,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GithubIssueResponse implements GithubIssueResponse {
  const _GithubIssueResponse({required this.number, this.title = '', this.author = '', this.state = 'open', this.htmlUrl = '', final  List<String> labels = const [], required this.createdAt}): _labels = labels;
  factory _GithubIssueResponse.fromJson(Map<String, dynamic> json) => _$GithubIssueResponseFromJson(json);

@override final  int number;
@override@JsonKey() final  String title;
/// 작성자 GitHub 사용자명.
@override@JsonKey() final  String author;
@override@JsonKey() final  String state;
@override@JsonKey() final  String htmlUrl;
 final  List<String> _labels;
@override@JsonKey() List<String> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}

@override final  DateTime createdAt;

/// Create a copy of GithubIssueResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GithubIssueResponseCopyWith<_GithubIssueResponse> get copyWith => __$GithubIssueResponseCopyWithImpl<_GithubIssueResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GithubIssueResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GithubIssueResponse&&(identical(other.number, number) || other.number == number)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.state, state) || other.state == state)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&const DeepCollectionEquality().equals(other._labels, _labels)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,title,author,state,htmlUrl,const DeepCollectionEquality().hash(_labels),createdAt);

@override
String toString() {
  return 'GithubIssueResponse(number: $number, title: $title, author: $author, state: $state, htmlUrl: $htmlUrl, labels: $labels, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GithubIssueResponseCopyWith<$Res> implements $GithubIssueResponseCopyWith<$Res> {
  factory _$GithubIssueResponseCopyWith(_GithubIssueResponse value, $Res Function(_GithubIssueResponse) _then) = __$GithubIssueResponseCopyWithImpl;
@override @useResult
$Res call({
 int number, String title, String author, String state, String htmlUrl, List<String> labels, DateTime createdAt
});




}
/// @nodoc
class __$GithubIssueResponseCopyWithImpl<$Res>
    implements _$GithubIssueResponseCopyWith<$Res> {
  __$GithubIssueResponseCopyWithImpl(this._self, this._then);

  final _GithubIssueResponse _self;
  final $Res Function(_GithubIssueResponse) _then;

/// Create a copy of GithubIssueResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? title = null,Object? author = null,Object? state = null,Object? htmlUrl = null,Object? labels = null,Object? createdAt = null,}) {
  return _then(_GithubIssueResponse(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,htmlUrl: null == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
