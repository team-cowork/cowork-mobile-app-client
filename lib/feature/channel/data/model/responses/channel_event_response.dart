import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel_event_response.freezed.dart';
part 'channel_event_response.g.dart';

/// 소켓 `channel:*` / `team:access:revoked` 이벤트 payload.
///
/// REST 응답과 달리 채널 id 를 `id` 가 아니라 `channelId` 로 보낸다. 이벤트마다 오는
/// 필드가 달라(삭제는 `channelId`·`teamId`, 팀 탈퇴는 `teamId` 만) 모두 nullable 이다.
///
/// 타입이 맞지 않으면 [CheckedFromJsonException] 을 던지도록 `checked` 로 만든다.
/// 서버가 보낸 이벤트 하나가 잘못됐다고 소켓 스트림이 오류로 끊기면 안 되기 때문에
/// 받는 쪽이 이 예외만 골라 무시한다.
@freezed
abstract class ChannelEventResponse with _$ChannelEventResponse {
  @JsonSerializable(checked: true)
  const factory ChannelEventResponse({
    int? channelId,
    int? teamId,
    String? name,

    /// 화면 종류. (예: TEXT, WEBHOOK, MEETING_NOTE)
    String? viewType,
  }) = _ChannelEventResponse;

  factory ChannelEventResponse.fromJson(Map<String, dynamic> json) =>
      _$ChannelEventResponseFromJson(json);
}
