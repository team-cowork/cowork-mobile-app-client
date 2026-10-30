// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_section_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TemplateSectionResponse {

/// 없으면 fromJson 이 던진다.
 int get id; String get title;/// 입력 형식. (예: TEXT, MARKDOWN, DATETIME)
 String? get type; String? get placeholder; bool get isRequired;
/// Create a copy of TemplateSectionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateSectionResponseCopyWith<TemplateSectionResponse> get copyWith => _$TemplateSectionResponseCopyWithImpl<TemplateSectionResponse>(this as TemplateSectionResponse, _$identity);

  /// Serializes this TemplateSectionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateSectionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.placeholder, placeholder) || other.placeholder == placeholder)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,type,placeholder,isRequired);

@override
String toString() {
  return 'TemplateSectionResponse(id: $id, title: $title, type: $type, placeholder: $placeholder, isRequired: $isRequired)';
}


}

/// @nodoc
abstract mixin class $TemplateSectionResponseCopyWith<$Res>  {
  factory $TemplateSectionResponseCopyWith(TemplateSectionResponse value, $Res Function(TemplateSectionResponse) _then) = _$TemplateSectionResponseCopyWithImpl;
@useResult
$Res call({
 int id, String title, String? type, String? placeholder, bool isRequired
});




}
/// @nodoc
class _$TemplateSectionResponseCopyWithImpl<$Res>
    implements $TemplateSectionResponseCopyWith<$Res> {
  _$TemplateSectionResponseCopyWithImpl(this._self, this._then);

  final TemplateSectionResponse _self;
  final $Res Function(TemplateSectionResponse) _then;

/// Create a copy of TemplateSectionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? type = freezed,Object? placeholder = freezed,Object? isRequired = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,placeholder: freezed == placeholder ? _self.placeholder : placeholder // ignore: cast_nullable_to_non_nullable
as String?,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateSectionResponse].
extension TemplateSectionResponsePatterns on TemplateSectionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateSectionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateSectionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateSectionResponse value)  $default,){
final _that = this;
switch (_that) {
case _TemplateSectionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateSectionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateSectionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String? type,  String? placeholder,  bool isRequired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateSectionResponse() when $default != null:
return $default(_that.id,_that.title,_that.type,_that.placeholder,_that.isRequired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String? type,  String? placeholder,  bool isRequired)  $default,) {final _that = this;
switch (_that) {
case _TemplateSectionResponse():
return $default(_that.id,_that.title,_that.type,_that.placeholder,_that.isRequired);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String? type,  String? placeholder,  bool isRequired)?  $default,) {final _that = this;
switch (_that) {
case _TemplateSectionResponse() when $default != null:
return $default(_that.id,_that.title,_that.type,_that.placeholder,_that.isRequired);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateSectionResponse extends TemplateSectionResponse {
  const _TemplateSectionResponse({required this.id, this.title = '', this.type, this.placeholder, this.isRequired = false}): super._();
  factory _TemplateSectionResponse.fromJson(Map<String, dynamic> json) => _$TemplateSectionResponseFromJson(json);

/// 없으면 fromJson 이 던진다.
@override final  int id;
@override@JsonKey() final  String title;
/// 입력 형식. (예: TEXT, MARKDOWN, DATETIME)
@override final  String? type;
@override final  String? placeholder;
@override@JsonKey() final  bool isRequired;

/// Create a copy of TemplateSectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateSectionResponseCopyWith<_TemplateSectionResponse> get copyWith => __$TemplateSectionResponseCopyWithImpl<_TemplateSectionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateSectionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateSectionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.placeholder, placeholder) || other.placeholder == placeholder)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,type,placeholder,isRequired);

@override
String toString() {
  return 'TemplateSectionResponse(id: $id, title: $title, type: $type, placeholder: $placeholder, isRequired: $isRequired)';
}


}

/// @nodoc
abstract mixin class _$TemplateSectionResponseCopyWith<$Res> implements $TemplateSectionResponseCopyWith<$Res> {
  factory _$TemplateSectionResponseCopyWith(_TemplateSectionResponse value, $Res Function(_TemplateSectionResponse) _then) = __$TemplateSectionResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String? type, String? placeholder, bool isRequired
});




}
/// @nodoc
class __$TemplateSectionResponseCopyWithImpl<$Res>
    implements _$TemplateSectionResponseCopyWith<$Res> {
  __$TemplateSectionResponseCopyWithImpl(this._self, this._then);

  final _TemplateSectionResponse _self;
  final $Res Function(_TemplateSectionResponse) _then;

/// Create a copy of TemplateSectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? type = freezed,Object? placeholder = freezed,Object? isRequired = null,}) {
  return _then(_TemplateSectionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,placeholder: freezed == placeholder ? _self.placeholder : placeholder // ignore: cast_nullable_to_non_nullable
as String?,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
