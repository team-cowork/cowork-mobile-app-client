// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_members_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InviteMembersRequest {

 List<int> get userIds;
/// Create a copy of InviteMembersRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteMembersRequestCopyWith<InviteMembersRequest> get copyWith => _$InviteMembersRequestCopyWithImpl<InviteMembersRequest>(this as InviteMembersRequest, _$identity);

  /// Serializes this InviteMembersRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteMembersRequest&&const DeepCollectionEquality().equals(other.userIds, userIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(userIds));

@override
String toString() {
  return 'InviteMembersRequest(userIds: $userIds)';
}


}

/// @nodoc
abstract mixin class $InviteMembersRequestCopyWith<$Res>  {
  factory $InviteMembersRequestCopyWith(InviteMembersRequest value, $Res Function(InviteMembersRequest) _then) = _$InviteMembersRequestCopyWithImpl;
@useResult
$Res call({
 List<int> userIds
});




}
/// @nodoc
class _$InviteMembersRequestCopyWithImpl<$Res>
    implements $InviteMembersRequestCopyWith<$Res> {
  _$InviteMembersRequestCopyWithImpl(this._self, this._then);

  final InviteMembersRequest _self;
  final $Res Function(InviteMembersRequest) _then;

/// Create a copy of InviteMembersRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userIds = null,}) {
  return _then(_self.copyWith(
userIds: null == userIds ? _self.userIds : userIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [InviteMembersRequest].
extension InviteMembersRequestPatterns on InviteMembersRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteMembersRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteMembersRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteMembersRequest value)  $default,){
final _that = this;
switch (_that) {
case _InviteMembersRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteMembersRequest value)?  $default,){
final _that = this;
switch (_that) {
case _InviteMembersRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int> userIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteMembersRequest() when $default != null:
return $default(_that.userIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int> userIds)  $default,) {final _that = this;
switch (_that) {
case _InviteMembersRequest():
return $default(_that.userIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int> userIds)?  $default,) {final _that = this;
switch (_that) {
case _InviteMembersRequest() when $default != null:
return $default(_that.userIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _InviteMembersRequest implements InviteMembersRequest {
  const _InviteMembersRequest({required final  List<int> userIds}): _userIds = userIds;
  

 final  List<int> _userIds;
@override List<int> get userIds {
  if (_userIds is EqualUnmodifiableListView) return _userIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userIds);
}


/// Create a copy of InviteMembersRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteMembersRequestCopyWith<_InviteMembersRequest> get copyWith => __$InviteMembersRequestCopyWithImpl<_InviteMembersRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InviteMembersRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteMembersRequest&&const DeepCollectionEquality().equals(other._userIds, _userIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_userIds));

@override
String toString() {
  return 'InviteMembersRequest(userIds: $userIds)';
}


}

/// @nodoc
abstract mixin class _$InviteMembersRequestCopyWith<$Res> implements $InviteMembersRequestCopyWith<$Res> {
  factory _$InviteMembersRequestCopyWith(_InviteMembersRequest value, $Res Function(_InviteMembersRequest) _then) = __$InviteMembersRequestCopyWithImpl;
@override @useResult
$Res call({
 List<int> userIds
});




}
/// @nodoc
class __$InviteMembersRequestCopyWithImpl<$Res>
    implements _$InviteMembersRequestCopyWith<$Res> {
  __$InviteMembersRequestCopyWithImpl(this._self, this._then);

  final _InviteMembersRequest _self;
  final $Res Function(_InviteMembersRequest) _then;

/// Create a copy of InviteMembersRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userIds = null,}) {
  return _then(_InviteMembersRequest(
userIds: null == userIds ? _self._userIds : userIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
