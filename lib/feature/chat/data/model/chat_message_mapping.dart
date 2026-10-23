import '../../../../core/utils/initial.dart';
import '../../../profile/domain/profile_entity.dart';
import '../../domain/chat_attachment.dart';
import '../../domain/chat_message.dart';
import '../../domain/enums/chat_avatar_color.dart';
import 'responses/message_response.dart';

/// 같은 사람이 늘 같은 색이 되도록 작성자 id 로 고르는 아바타 색.
const _avatarColors = [
  ChatAvatarColor.blue,
  ChatAvatarColor.green,
  ChatAvatarColor.amber,
  ChatAvatarColor.red,
];

/// 이름을 아직 모르는 작성자. 이름을 받아 오면 [chatAuthorOf] 로 바꾼다.
ProfileEntity unknownChatAuthor(int id) =>
    ProfileEntity(id: id, name: '알 수 없음', avatarInitial: '?');

/// 표시 이름으로 만든 작성자. 이름이 비어 있으면 [unknownChatAuthor].
ProfileEntity chatAuthorOf(int id, String name) => name.isEmpty
    ? unknownChatAuthor(id)
    : ProfileEntity(id: id, name: name, avatarInitial: initialOf(name));

/// 시스템 메시지(GitHub 연동 결과 등)의 작성자. 사람 이름을 찾지 않는다.
ProfileEntity systemChatAuthor(int id) =>
    ProfileEntity(id: id, name: '시스템', avatarInitial: '시');

/// 서버 메시지를 화면 메시지로. 시각은 기기 시간대로 [now] 기준 상대 표기한다.
ChatMessage chatMessageOf(
  MessageResponse message,
  ProfileEntity author, {
  DateTime? now,
}) => ChatMessage(
  id: message.id,
  author: author,
  avatarColor: chatAvatarColorOf(author.id),
  timestamp: chatTimestampOf(message.createdAt, now: now),
  text: message.content,
  attachments: [
    for (final attachment in message.attachments)
      ChatAttachment(
        name: attachment.name,
        size: attachment.size,
        mimeType: attachment.mimeType,
      ),
  ],
);

ChatAvatarColor chatAvatarColorOf(int authorId) =>
    _avatarColors[authorId % _avatarColors.length];

/// `오늘 14:20` / `어제 09:05` / `3월 2일 18:00` / `2025년 3월 2일 18:00`.
String chatTimestampOf(DateTime createdAt, {DateTime? now}) {
  final local = createdAt.toLocal();
  final today = now ?? DateTime.now();
  final time =
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
  final days = DateTime(
    today.year,
    today.month,
    today.day,
  ).difference(DateTime(local.year, local.month, local.day)).inDays;
  return switch (days) {
    0 => '오늘 $time',
    1 => '어제 $time',
    _ when local.year == today.year => '${local.month}월 ${local.day}일 $time',
    _ => '${local.year}년 ${local.month}월 ${local.day}일 $time',
  };
}
