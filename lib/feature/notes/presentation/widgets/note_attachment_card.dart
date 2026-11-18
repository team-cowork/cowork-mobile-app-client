import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import '../../domain/note_attachment.dart';

/// 회의록 첨부 카드. 편집·상세 화면이 같이 쓴다.
///
/// 서버가 크기·형식을 주지 않으므로 이름의 확장자로 아이콘과 부제(예: PDF)를 정한다.
class NoteAttachmentCard extends StatelessWidget {
  const NoteAttachmentCard({super.key, required this.attachment, this.onTap});

  final NoteAttachment attachment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = attachment.name;
    final dot = name.lastIndexOf('.');
    final extension = dot > 0 && dot < name.length - 1
        ? name.substring(dot + 1).toUpperCase()
        : '';
    return CoworkAttachmentCard(
      filename: name,
      subtitle: extension.isEmpty ? '파일' : extension,
      icon: _iconOf(lookupMimeType(name) ?? ''),
      onTap: onTap,
    );
  }

  static IconData _iconOf(String contentType) =>
      switch (contentType.split('/').first) {
        'image' => Icons.image_outlined,
        'video' => Icons.videocam_outlined,
        'audio' => Icons.audiotrack_outlined,
        _ => Icons.insert_drive_file_outlined,
      };
}
