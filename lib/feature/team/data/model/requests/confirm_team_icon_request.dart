import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_team_icon_request.freezed.dart';
part 'confirm_team_icon_request.g.dart';

/// `POST /teams/icon/confirm` 요청 본문.
@Freezed(fromJson: false, toJson: true)
abstract class ConfirmTeamIconRequest with _$ConfirmTeamIconRequest {
  @JsonSerializable(createFactory: false)
  const factory ConfirmTeamIconRequest({
    /// presigned 발급 때 받은 값.
    required String objectKey,
  }) = _ConfirmTeamIconRequest;
}
