import 'dart:typed_data';

import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../../data/repositories/message_repository.dart';

/// 이미지 첨부를 대화 안에서 바로 보여 준다.
///
/// 임시 주소는 60초 뒤 만료되므로 주소가 아니라 메시지·첨부 순번 기준으로 저장소가
/// 받아 둔 이미지를 쓴다. 이미 받은 이미지는 다시 받지 않고, 받지 못하면 눌러서 새 주소로
/// 다시 받는다. 받은 이미지를 누르면 [onTap] (크게 보기·다운로드)을 부른다.
class AttachmentImagePreview extends StatefulWidget {
  const AttachmentImagePreview({
    required this.repository,
    required this.channelId,
    required this.messageId,
    required this.attachmentIndex,
    required this.name,
    this.onTap,
    super.key,
  });

  final MessageRepository repository;
  final int channelId;
  final String messageId;
  final int attachmentIndex;

  /// 접근성 설명으로 쓰는 파일 이름.
  final String name;
  final VoidCallback? onTap;

  static const maxWidth = 280.0;
  static const maxHeight = 240.0;
  static const _placeholderHeight = 160.0;

  @override
  State<AttachmentImagePreview> createState() => _AttachmentImagePreviewState();
}

class _AttachmentImagePreviewState extends State<AttachmentImagePreview> {
  Uint8List? _bytes;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _bytes = widget.repository.cachedAttachmentImage(
      widget.channelId,
      widget.messageId,
      widget.attachmentIndex,
    );
    if (_bytes == null) _load();
  }

  Future<void> _load() async {
    if (_failed) setState(() => _failed = false);
    try {
      final bytes = await widget.repository.fetchAttachmentImage(
        widget.channelId,
        widget.messageId,
        widget.attachmentIndex,
      );
      if (mounted) setState(() => _bytes = bytes);
    } catch (e, s) {
      Logger.e('이미지 첨부 불러오기 실패', tag: 'Chat', error: e, stackTrace: s);
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes != null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AttachmentImagePreview.maxWidth,
            maxHeight: AttachmentImagePreview.maxHeight,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes,
              semanticLabel: widget.name,
              fit: BoxFit.contain,
              // 화면보다 훨씬 큰 원본을 그대로 풀지 않는다.
              cacheWidth: (AttachmentImagePreview.maxWidth * 3).toInt(),
              errorBuilder: (_, _, _) => _Placeholder(
                icon: Icons.broken_image_outlined,
                label: widget.name,
              ),
            ),
          ),
        ),
      );
    }
    if (_failed) {
      return GestureDetector(
        onTap: _load,
        child: const _Placeholder(
          icon: Icons.refresh,
          label: '이미지를 불러오지 못했어요. 눌러서 다시 시도',
        ),
      );
    }
    return const _Placeholder(loading: true);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.icon, this.label, this.loading = false});

  final IconData? icon;
  final String? label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: AttachmentImagePreview.maxWidth,
      height: AttachmentImagePreview._placeholderHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: loading
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.s8,
              children: [
                Icon(icon, color: colors.onSurfaceVariant),
                Text(
                  label ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppFont.labelXs.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}
