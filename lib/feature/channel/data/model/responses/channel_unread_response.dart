import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel_unread_response.freezed.dart';
part 'channel_unread_response.g.dart';

/// 채널 하나의 안 읽은 메시지 수.
///
/// `GET /chat/teams/{teamId}/unread` 응답 원소이자 소켓 `channel:unread:updated`
/// payload 다.
///
/// 소켓 payload 도 읽으므로 타입이 맞지 않으면 [CheckedFromJsonException] 을 던지도록
/// `checked` 로 만든다. 받는 쪽이 이 예외만 골라 그 이벤트를 버린다.
@freezed
abstract class ChannelUnreadResponse with _$ChannelUnreadResponse {
  @JsonSerializable(checked: true)
  const factory ChannelUnreadResponse({
    required int channelId,
    required int unreadCount,
  }) = _ChannelUnreadResponse;

  factory ChannelUnreadResponse.fromJson(Map<String, dynamic> json) =>
      _$ChannelUnreadResponseFromJson(json);
}
