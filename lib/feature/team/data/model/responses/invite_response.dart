import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/enums/invite_duration.dart';

part 'invite_response.freezed.dart';
part 'invite_response.g.dart';

/// 초대 코드 하나. `POST /teams/{teamId}/invites` 응답이자 `GET` 목록의 원소다.
@freezed
abstract class InviteResponse with _$InviteResponse {
  const factory InviteResponse({
    /// 없으면 보여 줄 것도 무효화할 것도 없으므로 필수다. 없으면 fromJson 이 던진다.
    required String inviteCode,

    /// 모르는 기간이면 null.
    @JsonKey(fromJson: InviteDuration.fromValue) InviteDuration? duration,

    /// 만료 시각. 기간이 `never` 면 null.
    @JsonKey(fromJson: _serverTimeOf) DateTime? expiresAt,

    /// 만료됐거나 무효화된 코드. 목록에는 이런 코드도 섞여 온다.
    @Default(false) bool expired,

    /// 목록을 최신순으로 늘어놓는 데 쓴다.
    @JsonKey(fromJson: _serverTimeOf) DateTime? createdAt,
  }) = _InviteResponse;

  factory InviteResponse.fromJson(Map<String, dynamic> json) =>
      _$InviteResponseFromJson(json);
}

/// team 서비스는 시각을 오프셋 없이(`2026-11-17T08:00:00`) UTC 로 준다. 그대로 읽으면
/// Dart 가 기기 시간으로 봐 9시간 어긋나므로, 오프셋이 없으면 UTC 로 읽은 뒤 기기
/// 시간으로 바꾼다. 못 읽으면 null.
DateTime? _serverTimeOf(String? raw) {
  final parsed = DateTime.tryParse(raw ?? '');
  if (parsed == null) return null;
  if (parsed.isUtc) return parsed.toLocal();
  return DateTime.tryParse('${raw}Z')?.toLocal() ?? parsed;
}
