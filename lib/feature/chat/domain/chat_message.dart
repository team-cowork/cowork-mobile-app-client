import 'package:equatable/equatable.dart';

import '../../../shared/domain/enums/chat_avatar_color.dart';
import '../../../shared/domain/profile_entity.dart';
import 'chat_attachment.dart';
import 'chat_upload.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.avatarColor,
    required this.timestamp,
    required this.text,
    this.attachments = const [],
    this.editable = false,
    this.upload,
  });

  final String id;
  final ProfileEntity author;
  final ChatAvatarColor avatarColor;
  final String timestamp;
  final String text;

  /// 붙은 파일. 파일만 보낸 메시지는 [text] 가 비어 있을 수 있다.
  final List<ChatAttachment> attachments;

  /// 수정·삭제할 수 있는 메시지인지.
  final bool editable;

  /// 내가 보내는 중이거나 보내지 못한 파일 메시지면 그 상태. 저장된 메시지는 null.
  final ChatUpload? upload;

  @override
  List<Object?> get props => [
    id,
    author,
    avatarColor,
    timestamp,
    text,
    attachments,
    editable,
    upload,
  ];
}
