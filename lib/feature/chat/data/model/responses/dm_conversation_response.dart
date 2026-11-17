import 'package:freezed_annotation/freezed_annotation.dart';

import 'dm_last_message_response.dart';

part 'dm_conversation_response.freezed.dart';
part 'dm_conversation_response.g.dart';

/// `GET /chat/dms` 응답의 대화 하나. 상대 이름·사진은 id 만 와서 따로 채운다.
@freezed
abstract class DmConversationResponse with _$DmConversationResponse {
  const factory DmConversationResponse({
    /// 대화에 쓰는 DM 채널 id. 메시지는 채널 메시지 API 를 그대로 쓴다.
    required int channelId,

    /// 상대 사용자 id. 상대가 탈퇴하는 등 알 수 없으면 null.
    int? otherUserId,
    @Default(0) int unreadCount,

    /// 아직 메시지가 없으면 null.
    DmLastMessageResponse? lastMessage,
  }) = _DmConversationResponse;

  factory DmConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$DmConversationResponseFromJson(json);
}
