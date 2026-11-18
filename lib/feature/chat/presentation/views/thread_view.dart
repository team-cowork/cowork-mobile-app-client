import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/chat_socket.dart';
import '../../../../core/utils/async_state.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../../channel/data/repositories/channel_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../domain/chat_attachment.dart';
import '../../domain/chat_message.dart';
import '../../domain/message_thread.dart';
import '../blocs/thread/thread_bloc.dart';
import '../utils/attachment_opener.dart';
import '../widgets/attachment_image_preview.dart';
import '../widgets/chat_message_row.dart';

class ThreadView extends StatefulWidget {
  const ThreadView({
    required this.channelId,
    required this.parentMessageId,
    this.openUrl = launchExternally,
    super.key,
  });

  final int channelId;

  /// 스레드의 부모(맨 위) 메시지 id.
  final String parentMessageId;

  /// 첨부파일 주소를 여는 방법. 테스트에서 바꾼다.
  final UrlOpener openUrl;

  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  late final _attachmentOpener = AttachmentOpener(
    repository: context.read<MessageRepository>(),
    open: widget.openUrl,
  );

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAttachment(ChatMessage message, int index) async {
    final failure = await _attachmentOpener.open(
      widget.channelId,
      message.id,
      index,
    );
    if (failure != null && mounted) _notify(failure);
  }

  /// 이름 바꾸기·보관 메뉴. 보관은 이름을 붙여 만든 스레드만 할 수 있다.
  Future<void> _showMenu(BuildContext context, MessageThread thread) async {
    final bloc = context.read<ThreadBloc>();
    final action = await showModalBottomSheet<_ThreadAction>(
      context: context,
      backgroundColor: AppColors.neutral800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('이름 바꾸기'),
              onTap: () => Navigator.of(sheetContext).pop(_ThreadAction.rename),
            ),
            if (thread.name != null)
              ListTile(
                title: Text(thread.isArchived ? '보관 풀기' : '스레드 보관'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_ThreadAction.archive),
              ),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    switch (action) {
      case _ThreadAction.rename:
        final name = await _RenameThreadSheet.show(context, thread.name ?? '');
        if (name != null) bloc.add(ThreadEvent.renamed(name));
      case _ThreadAction.archive:
        bloc.add(ThreadEvent.archivedChanged(!thread.isArchived));
    }
  }

  Widget _image(ChatMessage message, int index, ChatAttachment attachment) =>
      AttachmentImagePreview(
        key: ValueKey('${message.id}/$index'),
        repository: context.read<MessageRepository>(),
        channelId: widget.channelId,
        messageId: message.id,
        attachmentIndex: index,
        name: attachment.name,
        onTap: () => _openAttachment(message, index),
      );

  @override
  Widget build(BuildContext context) {
    final channelId = widget.channelId;
    final parentMessageId = widget.parentMessageId;
    return BlocScaffold<ThreadBloc, ThreadConversation>(
      create: (context) => ThreadBloc(
        channelId: channelId,
        parentMessageId: parentMessageId,
        channelRepository: context.read<ChannelRepository>(),
        messageRepository: context.read<MessageRepository>(),
        socket: context.read<ChatSocket>(),
      )..add(const ThreadEvent.requested()),
      errorTitle: '스레드를 불러오지 못했어요',
      onRetry: (context) =>
          context.read<ThreadBloc>().add(const ThreadEvent.requested()),
      builder: (context, conversation) => BlocListener<ThreadBloc, ThreadState>(
        listenWhen: (previous, current) =>
            current is AsyncSuccess<ThreadConversation> &&
            current.data.errorMessage != null,
        listener: (context, state) {
          _notify(
            (state as AsyncSuccess<ThreadConversation>).data.errorMessage!,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              _ThreadHeader(
                channelName: conversation.thread.channelName,
                name: conversation.thread.name,
                isArchived: conversation.thread.isArchived,
                onBack: () => context.pop(),
                onMore: () => _showMenu(context, conversation.thread),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                      ),
                      child: ChatMessageRow(
                        message: conversation.thread.rootMessage,
                        onAttachmentTap: (index) => _openAttachment(
                          conversation.thread.rootMessage,
                          index,
                        ),
                        imageBuilder: (index, attachment) => _image(
                          conversation.thread.rootMessage,
                          index,
                          attachment,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s16,
                        AppSpacing.s16,
                        AppSpacing.s16,
                        AppSpacing.s12,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '답글 ${conversation.thread.replies.length}개',
                            style: AppFont.labelXs.copyWith(
                              color: AppColors.neutral300,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s10),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: context.colors.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                      ),
                      child: Column(
                        spacing: AppSpacing.s18,
                        children: [
                          for (final reply in conversation.thread.replies)
                            ChatMessageRow(
                              message: reply,
                              avatarSize: 32,
                              onAttachmentTap: (index) =>
                                  _openAttachment(reply, index),
                              imageBuilder: (index, attachment) =>
                                  _image(reply, index, attachment),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.s12,
                  AppSpacing.s8,
                  AppSpacing.s12,
                  AppSpacing.s24,
                ),
                child: _ReplyComposer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 답글 입력창. 보내면 비운다.
class _ReplyComposer extends StatefulWidget {
  const _ReplyComposer();

  @override
  State<_ReplyComposer> createState() => _ReplyComposerState();
}

class _ReplyComposerState extends State<_ReplyComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<ThreadBloc>().add(ThreadEvent.replySent(text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CoworkMessageComposer(
      hintText: '스레드에 답글 남기기',
      showAttachButton: false,
      controller: _controller,
      onSubmitted: (_) => _send(),
      onSend: _send,
    );
  }
}

enum _ThreadAction { rename, archive }

/// 스레드 이름을 적는 시트. 적은 이름을 돌려주고, 취소하면 null.
class _RenameThreadSheet extends StatefulWidget {
  const _RenameThreadSheet({required this.initialName});

  final String initialName;

  static Future<String?> show(BuildContext context, String initialName) =>
      showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.neutral800,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _RenameThreadSheet(initialName: initialName),
      );

  @override
  State<_RenameThreadSheet> createState() => _RenameThreadSheetState();
}

class _RenameThreadSheetState extends State<_RenameThreadSheet> {
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s16,
          AppSpacing.s20,
          AppSpacing.s24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s16,
          children: [
            Text(
              '스레드 이름',
              style: AppFont.labelM.copyWith(color: AppColors.darkOnSurface),
            ),
            CoworkTextField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, _) => CoworkButton(
                label: '저장',
                size: CoworkButtonSize.large,
                enabled: value.text.trim().isNotEmpty,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadHeader extends StatelessWidget {
  const _ThreadHeader({
    required this.channelName,
    required this.isArchived,
    this.name,
    this.onBack,
    this.onMore,
  });

  final String channelName;

  /// 스레드에 붙인 이름. 없으면 `스레드` 로 보인다.
  final String? name;
  final bool isArchived;
  final VoidCallback? onBack;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: SizedBox(
              width: 32,
              height: 44,
              child: Center(child: AppIcon.chevronBack()),
            ),
          ),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? '스레드',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.labelS.copyWith(
                    color: AppColors.darkOnSurface,
                  ),
                ),
                Text(
                  '# $channelName',
                  style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
                ),
              ],
            ),
          ),
          if (isArchived) const CoworkBadge(label: '보관됨'),
          Semantics(
            button: true,
            label: '더보기',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onMore,
              child: SizedBox(
                width: 32,
                height: 44,
                child: Center(child: AppIcon.more()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
