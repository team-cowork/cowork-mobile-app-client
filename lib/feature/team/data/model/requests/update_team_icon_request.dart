import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_team_icon_request.freezed.dart';
part 'update_team_icon_request.g.dart';

/// `PATCH /teams/{teamId}/icon` 요청 본문.
@Freezed(fromJson: false, toJson: true)
abstract class UpdateTeamIconRequest with _$UpdateTeamIconRequest {
  @JsonSerializable(createFactory: false)
  const factory UpdateTeamIconRequest({
    /// `POST /teams/icon/confirm` 이 돌려준 URL. 직접 업로드하고 확인한 것만 받는다.
    required String iconUrl,
  }) = _UpdateTeamIconRequest;
}
