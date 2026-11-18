import 'package:freezed_annotation/freezed_annotation.dart';

import '../invite_duration.dart';

part 'create_invite_request.freezed.dart';
part 'create_invite_request.g.dart';

/// `POST /teams/{teamId}/invites` 요청 본문.
@Freezed(fromJson: false, toJson: true)
abstract class CreateInviteRequest with _$CreateInviteRequest {
  const factory CreateInviteRequest({
    /// 서버에는 `1d` / `7d` / `30d` / `never` 문자열로 보낸다.
    @JsonKey(toJson: _durationValueOf) required InviteDuration duration,
  }) = _CreateInviteRequest;
}

String _durationValueOf(InviteDuration duration) => duration.value;
