// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_messages_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchMessagesResponse {

 List<SearchMessageItemResponse> get messages;/// 다음 페이지 요청의 `before` 에 그대로 넣는 값. 마지막 페이지면 null.
 String? get nextCursor;
/// Create a copy of SearchMessagesResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchMessagesResponseCopyWith<SearchMessagesResponse> get copyWith => _$SearchMessagesResponseCopyWithImpl<SearchMessagesResponse>(this as SearchMessagesResponse, _$identity);

  /// Serializes this SearchMessagesResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchMessagesResponse&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(messages),nextCursor);

@override
String toString() {
  return 'SearchMessagesResponse(messages: $messages, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $SearchMessagesResponseCopyWith<$Res>  {
  factory $SearchMessagesResponseCopyWith(SearchMessagesResponse value, $Res Function(SearchMessagesResponse) _then) = _$SearchMessagesResponseCopyWithImpl;
@useResult
$Res call({
 List<SearchMessageItemResponse> messages, String? nextCursor
});




}
/// @nodoc
class _$SearchMessagesResponseCopyWithImpl<$Res>
    implements $SearchMessagesResponseCopyWith<$Res> {
  _$SearchMessagesResponseCopyWithImpl(this._self, this._then);

  final SearchMessagesResponse _self;
  final $Res Function(SearchMessagesResponse) _then;

/// Create a copy of SearchMessagesResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messages = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<SearchMessageItemResponse>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchMessagesResponse].
extension SearchMessagesResponsePatterns on SearchMessagesResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchMessagesResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchMessagesResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchMessagesResponse value)  $default,){
final _that = this;
switch (_that) {
case _SearchMessagesResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchMessagesResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SearchMessagesResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SearchMessageItemResponse> messages,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchMessagesResponse() when $default != null:
return $default(_that.messages,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SearchMessageItemResponse> messages,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _SearchMessagesResponse():
return $default(_that.messages,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SearchMessageItemResponse> messages,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _SearchMessagesResponse() when $default != null:
return $default(_that.messages,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchMessagesResponse implements SearchMessagesResponse {
  const _SearchMessagesResponse({final  List<SearchMessageItemResponse> messages = const [], this.nextCursor}): _messages = messages;
  factory _SearchMessagesResponse.fromJson(Map<String, dynamic> json) => _$SearchMessagesResponseFromJson(json);

 final  List<SearchMessageItemResponse> _messages;
@override@JsonKey() List<SearchMessageItemResponse> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

/// 다음 페이지 요청의 `before` 에 그대로 넣는 값. 마지막 페이지면 null.
@override final  String? nextCursor;

/// Create a copy of SearchMessagesResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchMessagesResponseCopyWith<_SearchMessagesResponse> get copyWith => __$SearchMessagesResponseCopyWithImpl<_SearchMessagesResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchMessagesResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchMessagesResponse&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),nextCursor);

@override
String toString() {
  return 'SearchMessagesResponse(messages: $messages, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$SearchMessagesResponseCopyWith<$Res> implements $SearchMessagesResponseCopyWith<$Res> {
  factory _$SearchMessagesResponseCopyWith(_SearchMessagesResponse value, $Res Function(_SearchMessagesResponse) _then) = __$SearchMessagesResponseCopyWithImpl;
@override @useResult
$Res call({
 List<SearchMessageItemResponse> messages, String? nextCursor
});




}
/// @nodoc
class __$SearchMessagesResponseCopyWithImpl<$Res>
    implements _$SearchMessagesResponseCopyWith<$Res> {
  __$SearchMessagesResponseCopyWithImpl(this._self, this._then);

  final _SearchMessagesResponse _self;
  final $Res Function(_SearchMessagesResponse) _then;

/// Create a copy of SearchMessagesResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? nextCursor = freezed,}) {
  return _then(_SearchMessagesResponse(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<SearchMessageItemResponse>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
