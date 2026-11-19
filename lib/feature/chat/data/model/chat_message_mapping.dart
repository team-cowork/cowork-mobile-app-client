import '../../../../shared/domain/profile_entity.dart';
import '../../../../shared/utils/chat_author.dart';
import '../../domain/chat_attachment.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_upload.dart';
import 'responses/message_response.dart';

/// 서버 메시지를 화면 메시지로. 시각은 기기 시간대로 [now] 기준 상대 표기한다.
///
/// [editable] 은 수정·삭제할 수 있는 메시지인지, [upload] 는 보내는 중인 파일 메시지의
/// 전송 상태로, 부르는 쪽이 정한다.
ChatMessage chatMessageOf(
  MessageResponse message,
  ProfileEntity author, {
  DateTime? now,
  bool editable = false,
  ChatUpload? upload,
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
  editable: editable,
  upload: upload,
);

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
