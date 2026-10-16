// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserResponse {

/// 사용자 id. 회의록 소유 판별에 쓴다.
 int? get id; String? get name; String? get email; String? get nickname;/// 접속 상태. 서버가 `offline` 처럼 소문자로 내려준다.
 String? get status; String? get statusMessage;/// 상태 만료 시각(ISO8601). 아직 화면에서 쓰지 않아 문자열 그대로 둔다.
 String? get statusExpiresAt;/// 자기소개.
 String? get description;/// 계정 설명. `description` 과 별개 필드다.
 String? get accountDescription;/// 직군 (예: 프론트엔드 개발자).
 String? get specialty; String? get major;/// 학번 코드 (예: 3413).
 String? get studentNumber; String? get studentRole; String? get githubId; String? get profileImageUrl; String? get sex;/// 역할 목록. 없으면 빈 배열로 온다.
 List<String> get roles;
/// Create a copy of UserResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserResponseCopyWith<UserResponse> get copyWith => _$UserResponseCopyWithImpl<UserResponse>(this as UserResponse, _$identity);

  /// Serializes this UserResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage)&&(identical(other.statusExpiresAt, statusExpiresAt) || other.statusExpiresAt == statusExpiresAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.accountDescription, accountDescription) || other.accountDescription == accountDescription)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.major, major) || other.major == major)&&(identical(other.studentNumber, studentNumber) || other.studentNumber == studentNumber)&&(identical(other.studentRole, studentRole) || other.studentRole == studentRole)&&(identical(other.githubId, githubId) || other.githubId == githubId)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.sex, sex) || other.sex == sex)&&const DeepCollectionEquality().equals(other.roles, roles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,nickname,status,statusMessage,statusExpiresAt,description,accountDescription,specialty,major,studentNumber,studentRole,githubId,profileImageUrl,sex,const DeepCollectionEquality().hash(roles));

@override
String toString() {
  return 'UserResponse(id: $id, name: $name, email: $email, nickname: $nickname, status: $status, statusMessage: $statusMessage, statusExpiresAt: $statusExpiresAt, description: $description, accountDescription: $accountDescription, specialty: $specialty, major: $major, studentNumber: $studentNumber, studentRole: $studentRole, githubId: $githubId, profileImageUrl: $profileImageUrl, sex: $sex, roles: $roles)';
}


}

/// @nodoc
abstract mixin class $UserResponseCopyWith<$Res>  {
  factory $UserResponseCopyWith(UserResponse value, $Res Function(UserResponse) _then) = _$UserResponseCopyWithImpl;
@useResult
$Res call({
 int? id, String? name, String? email, String? nickname, String? status, String? statusMessage, String? statusExpiresAt, String? description, String? accountDescription, String? specialty, String? major, String? studentNumber, String? studentRole, String? githubId, String? profileImageUrl, String? sex, List<String> roles
});




}
/// @nodoc
class _$UserResponseCopyWithImpl<$Res>
    implements $UserResponseCopyWith<$Res> {
  _$UserResponseCopyWithImpl(this._self, this._then);

  final UserResponse _self;
  final $Res Function(UserResponse) _then;

/// Create a copy of UserResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? email = freezed,Object? nickname = freezed,Object? status = freezed,Object? statusMessage = freezed,Object? statusExpiresAt = freezed,Object? description = freezed,Object? accountDescription = freezed,Object? specialty = freezed,Object? major = freezed,Object? studentNumber = freezed,Object? studentRole = freezed,Object? githubId = freezed,Object? profileImageUrl = freezed,Object? sex = freezed,Object? roles = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,statusMessage: freezed == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String?,statusExpiresAt: freezed == statusExpiresAt ? _self.statusExpiresAt : statusExpiresAt // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,accountDescription: freezed == accountDescription ? _self.accountDescription : accountDescription // ignore: cast_nullable_to_non_nullable
as String?,specialty: freezed == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String?,major: freezed == major ? _self.major : major // ignore: cast_nullable_to_non_nullable
as String?,studentNumber: freezed == studentNumber ? _self.studentNumber : studentNumber // ignore: cast_nullable_to_non_nullable
as String?,studentRole: freezed == studentRole ? _self.studentRole : studentRole // ignore: cast_nullable_to_non_nullable
as String?,githubId: freezed == githubId ? _self.githubId : githubId // ignore: cast_nullable_to_non_nullable
as String?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserResponse].
extension UserResponsePatterns on UserResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserResponse value)  $default,){
final _that = this;
switch (_that) {
case _UserResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UserResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? name,  String? email,  String? nickname,  String? status,  String? statusMessage,  String? statusExpiresAt,  String? description,  String? accountDescription,  String? specialty,  String? major,  String? studentNumber,  String? studentRole,  String? githubId,  String? profileImageUrl,  String? sex,  List<String> roles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserResponse() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.nickname,_that.status,_that.statusMessage,_that.statusExpiresAt,_that.description,_that.accountDescription,_that.specialty,_that.major,_that.studentNumber,_that.studentRole,_that.githubId,_that.profileImageUrl,_that.sex,_that.roles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? name,  String? email,  String? nickname,  String? status,  String? statusMessage,  String? statusExpiresAt,  String? description,  String? accountDescription,  String? specialty,  String? major,  String? studentNumber,  String? studentRole,  String? githubId,  String? profileImageUrl,  String? sex,  List<String> roles)  $default,) {final _that = this;
switch (_that) {
case _UserResponse():
return $default(_that.id,_that.name,_that.email,_that.nickname,_that.status,_that.statusMessage,_that.statusExpiresAt,_that.description,_that.accountDescription,_that.specialty,_that.major,_that.studentNumber,_that.studentRole,_that.githubId,_that.profileImageUrl,_that.sex,_that.roles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? name,  String? email,  String? nickname,  String? status,  String? statusMessage,  String? statusExpiresAt,  String? description,  String? accountDescription,  String? specialty,  String? major,  String? studentNumber,  String? studentRole,  String? githubId,  String? profileImageUrl,  String? sex,  List<String> roles)?  $default,) {final _that = this;
switch (_that) {
case _UserResponse() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.nickname,_that.status,_that.statusMessage,_that.statusExpiresAt,_that.description,_that.accountDescription,_that.specialty,_that.major,_that.studentNumber,_that.studentRole,_that.githubId,_that.profileImageUrl,_that.sex,_that.roles);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _UserResponse implements UserResponse {
  const _UserResponse({this.id, this.name, this.email, this.nickname, this.status, this.statusMessage, this.statusExpiresAt, this.description, this.accountDescription, this.specialty, this.major, this.studentNumber, this.studentRole, this.githubId, this.profileImageUrl, this.sex, final  List<String> roles = const []}): _roles = roles;
  factory _UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);

/// 사용자 id. 회의록 소유 판별에 쓴다.
@override final  int? id;
@override final  String? name;
@override final  String? email;
@override final  String? nickname;
/// 접속 상태. 서버가 `offline` 처럼 소문자로 내려준다.
@override final  String? status;
@override final  String? statusMessage;
/// 상태 만료 시각(ISO8601). 아직 화면에서 쓰지 않아 문자열 그대로 둔다.
@override final  String? statusExpiresAt;
/// 자기소개.
@override final  String? description;
/// 계정 설명. `description` 과 별개 필드다.
@override final  String? accountDescription;
/// 직군 (예: 프론트엔드 개발자).
@override final  String? specialty;
@override final  String? major;
/// 학번 코드 (예: 3413).
@override final  String? studentNumber;
@override final  String? studentRole;
@override final  String? githubId;
@override final  String? profileImageUrl;
@override final  String? sex;
/// 역할 목록. 없으면 빈 배열로 온다.
 final  List<String> _roles;
/// 역할 목록. 없으면 빈 배열로 온다.
@override@JsonKey() List<String> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}


/// Create a copy of UserResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserResponseCopyWith<_UserResponse> get copyWith => __$UserResponseCopyWithImpl<_UserResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage)&&(identical(other.statusExpiresAt, statusExpiresAt) || other.statusExpiresAt == statusExpiresAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.accountDescription, accountDescription) || other.accountDescription == accountDescription)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.major, major) || other.major == major)&&(identical(other.studentNumber, studentNumber) || other.studentNumber == studentNumber)&&(identical(other.studentRole, studentRole) || other.studentRole == studentRole)&&(identical(other.githubId, githubId) || other.githubId == githubId)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.sex, sex) || other.sex == sex)&&const DeepCollectionEquality().equals(other._roles, _roles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,nickname,status,statusMessage,statusExpiresAt,description,accountDescription,specialty,major,studentNumber,studentRole,githubId,profileImageUrl,sex,const DeepCollectionEquality().hash(_roles));

@override
String toString() {
  return 'UserResponse(id: $id, name: $name, email: $email, nickname: $nickname, status: $status, statusMessage: $statusMessage, statusExpiresAt: $statusExpiresAt, description: $description, accountDescription: $accountDescription, specialty: $specialty, major: $major, studentNumber: $studentNumber, studentRole: $studentRole, githubId: $githubId, profileImageUrl: $profileImageUrl, sex: $sex, roles: $roles)';
}


}

/// @nodoc
abstract mixin class _$UserResponseCopyWith<$Res> implements $UserResponseCopyWith<$Res> {
  factory _$UserResponseCopyWith(_UserResponse value, $Res Function(_UserResponse) _then) = __$UserResponseCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? name, String? email, String? nickname, String? status, String? statusMessage, String? statusExpiresAt, String? description, String? accountDescription, String? specialty, String? major, String? studentNumber, String? studentRole, String? githubId, String? profileImageUrl, String? sex, List<String> roles
});




}
/// @nodoc
class __$UserResponseCopyWithImpl<$Res>
    implements _$UserResponseCopyWith<$Res> {
  __$UserResponseCopyWithImpl(this._self, this._then);

  final _UserResponse _self;
  final $Res Function(_UserResponse) _then;

/// Create a copy of UserResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? email = freezed,Object? nickname = freezed,Object? status = freezed,Object? statusMessage = freezed,Object? statusExpiresAt = freezed,Object? description = freezed,Object? accountDescription = freezed,Object? specialty = freezed,Object? major = freezed,Object? studentNumber = freezed,Object? studentRole = freezed,Object? githubId = freezed,Object? profileImageUrl = freezed,Object? sex = freezed,Object? roles = null,}) {
  return _then(_UserResponse(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,statusMessage: freezed == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String?,statusExpiresAt: freezed == statusExpiresAt ? _self.statusExpiresAt : statusExpiresAt // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,accountDescription: freezed == accountDescription ? _self.accountDescription : accountDescription // ignore: cast_nullable_to_non_nullable
as String?,specialty: freezed == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String?,major: freezed == major ? _self.major : major // ignore: cast_nullable_to_non_nullable
as String?,studentNumber: freezed == studentNumber ? _self.studentNumber : studentNumber // ignore: cast_nullable_to_non_nullable
as String?,studentRole: freezed == studentRole ? _self.studentRole : studentRole // ignore: cast_nullable_to_non_nullable
as String?,githubId: freezed == githubId ? _self.githubId : githubId // ignore: cast_nullable_to_non_nullable
as String?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
