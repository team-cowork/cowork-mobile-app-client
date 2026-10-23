import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_lifecycle.dart';
import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/bloc_scaffold.dart';
import '../../../../network/chat_socket.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../data/repositories/channel_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../domain/chat_message.dart';
import '../blocs/channel_message/channel_message_bloc.dart';
import '../widgets/chat_message_row.dart';

class ChannelView extends StatelessWidget {
  const ChannelView({required this.channelId, super.key});

  final int channelId;

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<ChannelMessageBloc, ChannelConversation>(
      create: (context) => ChannelMessageBloc(
        channelId: channelId,
        channelRepository: context.read<ChannelRepository>(),
        messageRepository: context.read<MessageRepository>(),
        profileRepository: context.read<ProfileRepository>(),
        socket: context.read<ChatSocket>(),
        lifecycle: appLifecycleStates(),
      )..add(const ChannelMessageEvent.requested()),
      errorTitle: '채널을 불러오지 못했어요',
      onRetry: (context) => context.read<ChannelMessageBloc>().add(
        const ChannelMessageEvent.requested(),
      ),
      builder: (context, data) =>
          BlocListener<ChannelMessageBloc, ChannelMessageState>(
            listenWhen: (previous, current) =>
                current is AsyncSuccess<ChannelConversation> &&
                current.data.errorMessage != null,
            listener: (context, state) {
              final message = (state as AsyncSuccess<ChannelConversation>)
                  .data
                  .errorMessage!;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            },
            child: SafeArea(
              child: Column(
                children: [
                  _ChannelHeader(
                    name: data.name,
                    description: data.description,
                    onBack: () => context.pop(),
                    onMembersTap: () => context.push('/chat/channel/members'),
                    onMoreTap: () => context.push('/chat/channel/settings'),
                  ),
                  Expanded(child: _MessageList(data: data)),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.s12,
                      AppSpacing.s8,
                      AppSpacing.s12,
                      AppSpacing.s24,
                    ),
                    child: _MessageComposer(),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

/// 최신 메시지가 아래에 붙는 대화 목록. 위 끝 근처까지 올리면 이전 메시지를 부른다.
class _MessageList extends StatelessWidget {
  const _MessageList({required this.data});

  final ChannelConversation data;

  /// 위 끝에서 이만큼 남으면 미리 이전 메시지를 부른다.
  static const _loadOlderExtent = 400.0;

  @override
  Widget build(BuildContext context) {
    final messages = data.messages;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (data.hasOlder &&
            !data.loadingOlder &&
            notification.metrics.extentAfter < _loadOlderExtent) {
          context.read<ChannelMessageBloc>().add(
            const ChannelMessageEvent.olderRequested(),
          );
        }
        return false;
      },
      child: ListView.separated(
        reverse: true,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s16,
        ),
        itemCount: messages.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s18),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
          child: _messageRow(context, messages[messages.length - 1 - index]),
        ),
      ),
    );
  }

  Widget _messageRow(BuildContext context, ChatMessage message) =>
      ChatMessageRow(
        message: message,
        onTap: () => context.push('/chat/channel/thread'),
        onLongPress: message.editable
            ? () => _showMessageActions(context, message)
            : null,
      );

  /// 내 메시지를 길게 눌렀을 때. 고치거나 지울지 고르게 한다.
  static Future<void> _showMessageActions(
    BuildContext context,
    ChatMessage message,
  ) async {
    final bloc = context.read<ChannelMessageBloc>();
    final action = await _MessageActionSheet.show(context);
    if (!context.mounted || action == null) return;

    switch (action) {
      case _MessageAction.edit:
        final text = await _EditMessageSheet.show(context, message.text);
        if (text != null) {
          bloc.add(ChannelMessageEvent.edited(message.id, text));
        }
      case _MessageAction.delete:
        final confirmed = await CoworkDialog.show(
          context,
          title: '메시지를 삭제할까요?',
          message: '삭제한 메시지는 되돌릴 수 없어요.',
          confirmLabel: '삭제',
          cancelLabel: '취소',
          confirmColor: CoworkButtonColor.danger,
        );
        if (confirmed ?? false) {
          bloc.add(ChannelMessageEvent.deleted(message.id));
        }
    }
  }
}

enum _MessageAction { edit, delete }

/// 내 메시지 메뉴. 고른 동작을 돌려주고, 그냥 닫으면 null.
class _MessageActionSheet extends StatelessWidget {
  const _MessageActionSheet();

  static Future<_MessageAction?> show(BuildContext context) =>
      showModalBottomSheet<_MessageAction>(
        context: context,
        backgroundColor: AppColors.neutral800,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const _MessageActionSheet(),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.s8,
          bottom: AppSpacing.s24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
              decoration: BoxDecoration(
                color: AppColors.neutral400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const _MessageActionRow(
              icon: Icons.edit_outlined,
              label: '메시지 수정',
              action: _MessageAction.edit,
            ),
            const _MessageActionRow(
              icon: Icons.delete_outline,
              label: '메시지 삭제',
              action: _MessageAction.delete,
              destructive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageActionRow extends StatelessWidget {
  const _MessageActionRow({
    required this.icon,
    required this.label,
    required this.action,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final _MessageAction action;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.red400 : AppColors.darkOnSurface;

    return InkWell(
      onTap: () => Navigator.of(context).pop(action),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
        child: Row(
          spacing: AppSpacing.s14,
          children: [
            Icon(icon, size: 20, color: color),
            Text(label, style: AppFont.labelS.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

/// 메시지 수정 시트. 고친 내용을 돌려주고, 취소하면 null.
class _EditMessageSheet extends StatefulWidget {
  const _EditMessageSheet({required this.initialText});

  final String initialText;

  static Future<String?> show(BuildContext context, String initialText) =>
      showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.neutral800,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _EditMessageSheet(initialText: initialText),
      );

  @override
  State<_EditMessageSheet> createState() => _EditMessageSheetState();
}

class _EditMessageSheetState extends State<_EditMessageSheet> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              '메시지 수정',
              style: AppFont.labelM.copyWith(color: AppColors.darkOnSurface),
            ),
            CoworkTextArea(controller: _controller, minLines: 3),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, _) => CoworkButton(
                label: '저장',
                size: CoworkButtonSize.large,
                enabled: value.text.trim().isNotEmpty,
                onPressed: () => Navigator.of(context).pop(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 입력창. 보내면 비운다.
class _MessageComposer extends StatefulWidget {
  const _MessageComposer();

  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<ChannelMessageBloc>().add(ChannelMessageEvent.sent(text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CoworkMessageComposer(
      hintText: '메시지를 입력하세요',
      controller: _controller,
      onSubmitted: (_) => _send(),
      onSend: _send,
    );
  }
}

class _ChannelHeader extends StatelessWidget {
  const _ChannelHeader({
    required this.name,
    required this.description,
    this.onBack,
    this.onMembersTap,
    // ignore: unused_element_parameter -- 더보기 동작 미연결. 배선되면 이 줄을 지운다.
    this.onMoreTap,
  });

  final String name;
  final String description;
  final VoidCallback? onBack;
  final VoidCallback? onMembersTap;
  final VoidCallback? onMoreTap;

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
          const SizedBox(width: AppSpacing.s6),
          AppIcon.hash(),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppFont.labelS.copyWith(
                    color: AppColors.darkOnSurface,
                  ),
                ),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
                ),
              ],
            ),
          ),
          GestureDetector(onTap: onMembersTap, child: AppIcon.users()),
          const SizedBox(width: AppSpacing.s16),
          GestureDetector(onTap: onMoreTap, child: AppIcon.more()),
        ],
      ),
    );
  }
}
