import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_team_request.freezed.dart';
part 'create_team_request.g.dart';

/// `POST /teams` 요청 본문.
@Freezed(fromJson: false, toJson: true)
abstract class CreateTeamRequest with _$CreateTeamRequest {
  // 값이 없는 필드는 null 로 보내지 않고 뺀다.
  @JsonSerializable(includeIfNull: false, createFactory: false)
  const factory CreateTeamRequest({
    required String name,

    /// 팀 소개. 없으면 보내지 않는다.
    String? description,
  }) = _CreateTeamRequest;
}
