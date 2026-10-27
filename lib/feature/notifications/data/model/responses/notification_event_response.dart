import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_event_response.freezed.dart';
part 'notification_event_response.g.dart';

/// SSE 알림 스트림의 알림 하나.
///
/// 이동할 채널·팀이 없으면 서버가 0 을 보낸다. DM 메시지는 [teamId] 가 0 이다.
/// 형식이 틀린 이벤트 하나 때문에 스트림이 끊기지 않게 `checked` 로 만들어
/// [CheckedFromJsonException] 만 골라 버린다.
@freezed
abstract class NotificationEventResponse with _$NotificationEventResponse {
  @JsonSerializable(checked: true)
  const factory NotificationEventResponse({
    /// `CHAT_MESSAGE` / `MEMBER_INVITED` / `MEMBER_REMOVED` /
    /// `PROJECT_TASK_ASSIGNED` / `GITHUB_COMMENT_CREATED` 등.
    @Default('') String type,
    @Default('') String title,
    @Default('') String body,
    @Default(0) int channelId,
    @Default(0) int teamId,
  }) = _NotificationEventResponse;

  factory NotificationEventResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationEventResponseFromJson(json);
}
