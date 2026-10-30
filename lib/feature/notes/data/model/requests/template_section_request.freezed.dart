// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_section_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TemplateSectionRequest {

 String get title;/// 입력 형식. (예: TEXT, MARKDOWN, DATETIME)
 String get type;/// 안내 문구. 없으면 null.
///
/// 서버는 추가에서 null 을 "문구 없음"으로, 수정에서는 "바꾸지 않음"으로 읽는다.
/// 그래서 수정에서 문구를 지울 때만 빈 문자열을 보낸다. [TemplateSectionRequest.of]
/// 가 고른다.
 String? get placeholder; bool get isRequired;
/// Create a copy of TemplateSectionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateSectionRequestCopyWith<TemplateSectionRequest> get copyWith => _$TemplateSectionRequestCopyWithImpl<TemplateSectionRequest>(this as TemplateSectionRequest, _$identity);

  /// Serializes this TemplateSectionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateSectionRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.placeholder, placeholder) || other.placeholder == placeholder)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,type,placeholder,isRequired);

@override
String toString() {
  return 'TemplateSectionRequest(title: $title, type: $type, placeholder: $placeholder, isRequired: $isRequired)';
}


}

/// @nodoc
abstract mixin class $TemplateSectionRequestCopyWith<$Res>  {
  factory $TemplateSectionRequestCopyWith(TemplateSectionRequest value, $Res Function(TemplateSectionRequest) _then) = _$TemplateSectionRequestCopyWithImpl;
@useResult
$Res call({
 String title, String type, String? placeholder, bool isRequired
});




}
/// @nodoc
class _$TemplateSectionRequestCopyWithImpl<$Res>
    implements $TemplateSectionRequestCopyWith<$Res> {
  _$TemplateSectionRequestCopyWithImpl(this._self, this._then);

  final TemplateSectionRequest _self;
  final $Res Function(TemplateSectionRequest) _then;

/// Create a copy of TemplateSectionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? type = null,Object? placeholder = freezed,Object? isRequired = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,placeholder: freezed == placeholder ? _self.placeholder : placeholder // ignore: cast_nullable_to_non_nullable
as String?,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateSectionRequest].
extension TemplateSectionRequestPatterns on TemplateSectionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateSectionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateSectionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateSectionRequest value)  $default,){
final _that = this;
switch (_that) {
case _TemplateSectionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateSectionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateSectionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String type,  String? placeholder,  bool isRequired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateSectionRequest() when $default != null:
return $default(_that.title,_that.type,_that.placeholder,_that.isRequired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String type,  String? placeholder,  bool isRequired)  $default,) {final _that = this;
switch (_that) {
case _TemplateSectionRequest():
return $default(_that.title,_that.type,_that.placeholder,_that.isRequired);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String type,  String? placeholder,  bool isRequired)?  $default,) {final _that = this;
switch (_that) {
case _TemplateSectionRequest() when $default != null:
return $default(_that.title,_that.type,_that.placeholder,_that.isRequired);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _TemplateSectionRequest implements TemplateSectionRequest {
  const _TemplateSectionRequest({required this.title, required this.type, required this.placeholder, required this.isRequired});
  

@override final  String title;
/// 입력 형식. (예: TEXT, MARKDOWN, DATETIME)
@override final  String type;
/// 안내 문구. 없으면 null.
///
/// 서버는 추가에서 null 을 "문구 없음"으로, 수정에서는 "바꾸지 않음"으로 읽는다.
/// 그래서 수정에서 문구를 지울 때만 빈 문자열을 보낸다. [TemplateSectionRequest.of]
/// 가 고른다.
@override final  String? placeholder;
@override final  bool isRequired;

/// Create a copy of TemplateSectionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateSectionRequestCopyWith<_TemplateSectionRequest> get copyWith => __$TemplateSectionRequestCopyWithImpl<_TemplateSectionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateSectionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateSectionRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.placeholder, placeholder) || other.placeholder == placeholder)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,type,placeholder,isRequired);

@override
String toString() {
  return 'TemplateSectionRequest(title: $title, type: $type, placeholder: $placeholder, isRequired: $isRequired)';
}


}

/// @nodoc
abstract mixin class _$TemplateSectionRequestCopyWith<$Res> implements $TemplateSectionRequestCopyWith<$Res> {
  factory _$TemplateSectionRequestCopyWith(_TemplateSectionRequest value, $Res Function(_TemplateSectionRequest) _then) = __$TemplateSectionRequestCopyWithImpl;
@override @useResult
$Res call({
 String title, String type, String? placeholder, bool isRequired
});




}
/// @nodoc
class __$TemplateSectionRequestCopyWithImpl<$Res>
    implements _$TemplateSectionRequestCopyWith<$Res> {
  __$TemplateSectionRequestCopyWithImpl(this._self, this._then);

  final _TemplateSectionRequest _self;
  final $Res Function(_TemplateSectionRequest) _then;

/// Create a copy of TemplateSectionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? type = null,Object? placeholder = freezed,Object? isRequired = null,}) {
  return _then(_TemplateSectionRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,placeholder: freezed == placeholder ? _self.placeholder : placeholder // ignore: cast_nullable_to_non_nullable
as String?,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
