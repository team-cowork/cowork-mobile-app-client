import 'package:freezed_annotation/freezed_annotation.dart';

part 'join_team_response.freezed.dart';
part 'join_team_response.g.dart';

/// `POST /teams/join/{inviteCode}` 응답.
///
/// 팀 이름은 오지 않는다. 가입한 팀을 보여 주려면 팀 목록을 다시 읽어야 한다.
///
/// 서버는 `nicknameFormatEnforced`·`nicknameFormatExample` 도 준다. 팀이 닉네임 형식을
/// 강제하면 가입 직후 팀 닉네임을 정하게 하라는 안내용이다. 웹도 아직 쓰지 않아
/// 앱도 받지 않는다(#149). 팀 닉네임 변경 화면이 생기면 그때 붙인다.
@freezed
abstract class JoinTeamResponse with _$JoinTeamResponse {
  const factory JoinTeamResponse({
    /// 가입 뒤 옮겨 갈 팀. 없으면 fromJson 이 던진다.
    required int teamId,
  }) = _JoinTeamResponse;

  factory JoinTeamResponse.fromJson(Map<String, dynamic> json) =>
      _$JoinTeamResponseFromJson(json);
}
