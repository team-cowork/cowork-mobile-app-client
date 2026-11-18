import '../../../../shared/domain/profile_entity.dart';
import '../../../../shared/utils/chat_author.dart';
import '../../domain/direct_message_preview.dart';
import '../../domain/enums/dm_presence.dart';
import 'responses/dm_conversation_response.dart';
import 'responses/dm_last_message_response.dart';

/// 서버 대화를 목록 한 줄로. [other] 는 대화 상대, [myId] 는 내 id 다.
///
/// 시각은 기기 시간대로 [now] 기준 목록용으로 줄여 적는다.
DirectMessagePreview directMessagePreviewOf(
  DmConversationResponse conversation,
  ProfileEntity other, {
  int? myId,
  DateTime? now,
}) {
  final last = conversation.lastMessage;
  return DirectMessagePreview(
    channelId: conversation.channelId,
    profile: other,
    avatarColor: chatAvatarColorOf(other.id),
    // 서버에 접속 상태가 없다. 모르는 값은 접속 안 함으로 둔다.
    presence: DmPresence.offline,
    lastMessage: last == null ? '아직 메시지가 없어요' : _previewOf(last, myId),
    timestamp: last == null ? '' : dmTimestampOf(last.createdAt, now: now),
    unreadCount: conversation.unreadCount,
  );
}

/// 마지막 메시지 미리보기. 내가 보냈으면 `나: ` 를 앞에 붙이고, 파일만 있으면 안내
/// 문구로 바꾼다.
String _previewOf(DmLastMessageResponse last, int? myId) {
  final text = last.content.isEmpty && last.type == 'FILE'
      ? '파일을 보냈어요'
      : last.content;
  final mine = last.authorId != null && last.authorId == myId;
  return mine ? '나: $text' : text;
}

const _weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];

/// 목록 오른쪽의 짧은 시각. `14:28` / `어제` / `화요일` / `3월 2일` / `2025년 3월 2일`.
///
/// 오늘은 시각, 어제는 `어제`, 그 전 일주일은 요일, 그보다 오래되면 날짜다.
String dmTimestampOf(DateTime createdAt, {DateTime? now}) {
  final local = createdAt.toLocal();
  final today = now ?? DateTime.now();
  final days = DateTime(
    today.year,
    today.month,
    today.day,
  ).difference(DateTime(local.year, local.month, local.day)).inDays;
  return switch (days) {
    <= 0 =>
      '${local.hour.toString().padLeft(2, '0')}:'
          '${local.minute.toString().padLeft(2, '0')}',
    1 => '어제',
    < 7 => _weekdays[local.weekday - 1],
    _ when local.year == today.year => '${local.month}월 ${local.day}일',
    _ => '${local.year}년 ${local.month}월 ${local.day}일',
  };
}
