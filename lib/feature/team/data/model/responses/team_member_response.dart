import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_member_response.freezed.dart';
part 'team_member_response.g.dart';

/// `GET /teams/{teamId}/members` 응답의 멤버 하나.
///
/// 초대할 사람을 고를 때 이미 멤버인 사람을 빼는 데만 쓴다. 역할·팀 닉네임은 아직
/// 보여 주는 화면이 없어 받지 않는다.
@freezed
abstract class TeamMemberResponse with _$TeamMemberResponse {
  const factory TeamMemberResponse({
    /// 없으면 fromJson 이 던진다.
    required int userId,
  }) = _TeamMemberResponse;

  factory TeamMemberResponse.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberResponseFromJson(json);
}
