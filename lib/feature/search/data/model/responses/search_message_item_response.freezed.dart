// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_message_item_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchMessageItemResponse {

/// 없으면 fromJson 이 던진다.
 String get messageId; int get channelId;/// 시스템·웹훅 메시지면 null.
 int? get authorId; String get content;/// 검색어를 `<em>키워드</em>` 로 감싼 본문 조각들.
 List<String> get highlight;/// `TEXT` / `FILE` / `SYSTEM`.
 String get type; bool get hasAttachments;/// ISO8601.
 String get createdAt;
/// Create a copy of SearchMessageItemResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchMessageItemResponseCopyWith<SearchMessageItemResponse> get copyWith => _$SearchMessageItemResponseCopyWithImpl<SearchMessageItemResponse>(this as SearchMessageItemResponse, _$identity);

  /// Serializes this SearchMessageItemResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchMessageItemResponse&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.highlight, highlight)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasAttachments, hasAttachments) || other.hasAttachments == hasAttachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,channelId,authorId,content,const DeepCollectionEquality().hash(highlight),type,hasAttachments,createdAt);

@override
String toString() {
  return 'SearchMessageItemResponse(messageId: $messageId, channelId: $channelId, authorId: $authorId, content: $content, highlight: $highlight, type: $type, hasAttachments: $hasAttachments, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SearchMessageItemResponseCopyWith<$Res>  {
  factory $SearchMessageItemResponseCopyWith(SearchMessageItemResponse value, $Res Function(SearchMessageItemResponse) _then) = _$SearchMessageItemResponseCopyWithImpl;
@useResult
$Res call({
 String messageId, int channelId, int? authorId, String content, List<String> highlight, String type, bool hasAttachments, String createdAt
});




}
/// @nodoc
class _$SearchMessageItemResponseCopyWithImpl<$Res>
    implements $SearchMessageItemResponseCopyWith<$Res> {
  _$SearchMessageItemResponseCopyWithImpl(this._self, this._then);

  final SearchMessageItemResponse _self;
  final $Res Function(SearchMessageItemResponse) _then;

/// Create a copy of SearchMessageItemResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messageId = null,Object? channelId = null,Object? authorId = freezed,Object? content = null,Object? highlight = null,Object? type = null,Object? hasAttachments = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as int?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,highlight: null == highlight ? _self.highlight : highlight // ignore: cast_nullable_to_non_nullable
as List<String>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,hasAttachments: null == hasAttachments ? _self.hasAttachments : hasAttachments // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchMessageItemResponse].
extension SearchMessageItemResponsePatterns on SearchMessageItemResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchMessageItemResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchMessageItemResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchMessageItemResponse value)  $default,){
final _that = this;
switch (_that) {
case _SearchMessageItemResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchMessageItemResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SearchMessageItemResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String messageId,  int channelId,  int? authorId,  String content,  List<String> highlight,  String type,  bool hasAttachments,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchMessageItemResponse() when $default != null:
return $default(_that.messageId,_that.channelId,_that.authorId,_that.content,_that.highlight,_that.type,_that.hasAttachments,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String messageId,  int channelId,  int? authorId,  String content,  List<String> highlight,  String type,  bool hasAttachments,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _SearchMessageItemResponse():
return $default(_that.messageId,_that.channelId,_that.authorId,_that.content,_that.highlight,_that.type,_that.hasAttachments,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String messageId,  int channelId,  int? authorId,  String content,  List<String> highlight,  String type,  bool hasAttachments,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SearchMessageItemResponse() when $default != null:
return $default(_that.messageId,_that.channelId,_that.authorId,_that.content,_that.highlight,_that.type,_that.hasAttachments,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchMessageItemResponse implements SearchMessageItemResponse {
  const _SearchMessageItemResponse({required this.messageId, required this.channelId, this.authorId, this.content = '', final  List<String> highlight = const [], this.type = 'TEXT', this.hasAttachments = false, required this.createdAt}): _highlight = highlight;
  factory _SearchMessageItemResponse.fromJson(Map<String, dynamic> json) => _$SearchMessageItemResponseFromJson(json);

/// 없으면 fromJson 이 던진다.
@override final  String messageId;
@override final  int channelId;
/// 시스템·웹훅 메시지면 null.
@override final  int? authorId;
@override@JsonKey() final  String content;
/// 검색어를 `<em>키워드</em>` 로 감싼 본문 조각들.
 final  List<String> _highlight;
/// 검색어를 `<em>키워드</em>` 로 감싼 본문 조각들.
@override@JsonKey() List<String> get highlight {
  if (_highlight is EqualUnmodifiableListView) return _highlight;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_highlight);
}

/// `TEXT` / `FILE` / `SYSTEM`.
@override@JsonKey() final  String type;
@override@JsonKey() final  bool hasAttachments;
/// ISO8601.
@override final  String createdAt;

/// Create a copy of SearchMessageItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchMessageItemResponseCopyWith<_SearchMessageItemResponse> get copyWith => __$SearchMessageItemResponseCopyWithImpl<_SearchMessageItemResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchMessageItemResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchMessageItemResponse&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._highlight, _highlight)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasAttachments, hasAttachments) || other.hasAttachments == hasAttachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,channelId,authorId,content,const DeepCollectionEquality().hash(_highlight),type,hasAttachments,createdAt);

@override
String toString() {
  return 'SearchMessageItemResponse(messageId: $messageId, channelId: $channelId, authorId: $authorId, content: $content, highlight: $highlight, type: $type, hasAttachments: $hasAttachments, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SearchMessageItemResponseCopyWith<$Res> implements $SearchMessageItemResponseCopyWith<$Res> {
  factory _$SearchMessageItemResponseCopyWith(_SearchMessageItemResponse value, $Res Function(_SearchMessageItemResponse) _then) = __$SearchMessageItemResponseCopyWithImpl;
@override @useResult
$Res call({
 String messageId, int channelId, int? authorId, String content, List<String> highlight, String type, bool hasAttachments, String createdAt
});




}
/// @nodoc
class __$SearchMessageItemResponseCopyWithImpl<$Res>
    implements _$SearchMessageItemResponseCopyWith<$Res> {
  __$SearchMessageItemResponseCopyWithImpl(this._self, this._then);

  final _SearchMessageItemResponse _self;
  final $Res Function(_SearchMessageItemResponse) _then;

/// Create a copy of SearchMessageItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messageId = null,Object? channelId = null,Object? authorId = freezed,Object? content = null,Object? highlight = null,Object? type = null,Object? hasAttachments = null,Object? createdAt = null,}) {
  return _then(_SearchMessageItemResponse(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as int?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,highlight: null == highlight ? _self._highlight : highlight // ignore: cast_nullable_to_non_nullable
as List<String>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,hasAttachments: null == hasAttachments ? _self.hasAttachments : hasAttachments // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
