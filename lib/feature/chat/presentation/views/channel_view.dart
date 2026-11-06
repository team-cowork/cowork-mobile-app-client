import 'dart:async';
import 'dart:math';

import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/chat_socket.dart';
import '../../../../core/utils/app_lifecycle.dart';
import '../../../../core/utils/async_state.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../../channel/data/repositories/channel_repository.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../domain/chat_message.dart';
import '../blocs/channel_message/channel_message_bloc.dart';
import '../widgets/chat_message_row.dart';

class ChannelView extends StatelessWidget {
  const ChannelView({required this.channelId, this.focusMessageId, super.key});

  final int channelId;

  /// 열 때 보여 줄 메시지(검색 결과에서 고른 것). 없으면 최근 메시지부터 연다.
  final String? focusMessageId;

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
        focusMessageId: focusMessageId,
      )..add(const ChannelMessageEvent.requested()),
      errorTitle: '채널을 불러오지 못했어요',
      onRetry: (context) => context.read<ChannelMessageBloc>().add(
        const ChannelMessageEvent.requested(),
      ),
      builder: (context, data) => MultiBlocListener(
        listeners: [
          BlocListener<ChannelMessageBloc, ChannelMessageState>(
            listenWhen: (previous, current) =>
                current is AsyncSuccess<ChannelConversation> &&
                current.data.errorMessage != null,
            listener: (context, state) => _notify(
              context,
              (state as AsyncSuccess<ChannelConversation>).data.errorMessage!,
            ),
          ),
          BlocListener<ChannelMessageBloc, ChannelMessageState>(
            listenWhen: (previous, current) =>
                current is AsyncSuccess<ChannelConversation> &&
                current.data.closedReason != null &&
                (previous is! AsyncSuccess<ChannelConversation> ||
                    previous.data.closedReason == null),
            listener: (context, state) => _close(
              context,
              (state as AsyncSuccess<ChannelConversation>).data.closedReason!,
            ),
          ),
        ],
        child: SafeArea(
          child: Column(
            children: [
              _ChannelHeader(
                name: data.name,
                description: data.description,
                onBack: () => context.pop(),
                onMembersTap: () =>
                    context.push('/chat/channel/$channelId/members'),
                onMoreTap: () =>
                    context.push('/chat/channel/$channelId/settings'),
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

  /// 실패·안내 사유를 스낵바로 한 번 알린다.
  static void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// 채널을 더 볼 수 없게 됐다. 사유를 알리고, 위에 열린 스레드·설정까지 걷어 채널
  /// 화면을 닫는다. 채널로 바로 들어와 돌아갈 곳이 없으면 홈으로 간다.
  static void _close(BuildContext context, String reason) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(reason)));
    final route = ModalRoute.of(context);
    final navigator = Navigator.of(context);
    navigator.popUntil((other) => other == route);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      context.go('/');
    }
  }
}

/// 최신 메시지가 아래에 붙는 대화 목록. 위 끝 근처까지 올리면 이전 메시지를, 과거
/// 위치에서 열었으면 아래 끝 근처까지 내릴 때 이후 메시지를 부른다.
///
/// 검색 결과로 열면 [ChannelConversation.focusMessageId] 메시지를 기준(`center`)으로
/// 배치한다. 목록이 화면에 보이는 줄만 만들어서, 멀리 있는 줄은 위치를 알 수 없기
/// 때문이다. 기준 메시지가 스크롤 0 에 오고, 그보다 최근 메시지는 아래로 이어 붙는다.
class _MessageList extends StatefulWidget {
  const _MessageList({required this.data});

  final ChannelConversation data;

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  /// 위·아래 끝에서 이만큼 남으면 미리 다음 메시지를 부른다.
  static const _loadMoreExtent = 400.0;

  /// 고른 메시지를 강조해 두는 시간.
  static const _highlightDuration = Duration(seconds: 2);

  final _controller = ScrollController();
  final _centerKey = UniqueKey();

  /// 이 메시지를 기준으로 배치한다. null 이면 최근 메시지가 아래 끝인 보통 목록이다.
  String? _centerId;

  /// 강조해 보이는 메시지.
  String? _highlightId;
  Timer? _highlightTimer;

  ChannelConversation get _data => widget.data;

  @override
  void initState() {
    super.initState();
    // 처음 받은 대화에 실린 알림(고른 메시지를 못 찾음)은 BlocListener 가 받지 못한다.
    // 리스너는 만들어진 뒤에 바뀐 상태만 듣고, 이 목록은 그 상태로 처음 만들어지기 때문이다.
    if (_data.errorMessage case final message?) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ChannelView._notify(context, message);
      });
    }
    final focus = _data.focusMessageId;
    if (focus == null || _indexOf(focus) == -1) return;
    _centerId = focus;
    _highlightId = focus;
    _highlightTimer = Timer(_highlightDuration, () {
      if (mounted) setState(() => _highlightId = null);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealFocus());
  }

  @override
  void didUpdateWidget(_MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final center = _centerId;
    // 보내려고 최근 대화로 옮겼거나 기준 메시지가 지워졌으면 보통 목록의 아래 끝으로.
    if (center != null &&
        (_data.focusMessageId == null || _indexOf(center) == -1)) {
      _showLatest();
    }
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  int _indexOf(String messageId) =>
      _data.messages.indexWhere((message) => message.id == messageId);

  /// 기준 메시지가 화면 아래쪽 1/3 높이에 오도록 최근 쪽으로 조금 내린다. 최근 메시지가
  /// 적으면 아래 끝에서 멈춘다.
  void _revealFocus() {
    if (!mounted || !_controller.hasClients) return;
    final position = _controller.position;
    _controller.jumpTo(
      max(position.minScrollExtent, -position.viewportDimension / 3),
    );
  }

  /// 기준 배치를 풀고 최근 메시지가 아래 끝인 보통 목록으로 돌아간다. 보통 목록은
  /// 스크롤 0 이 아래 끝이다. 다음 배치에 바로 쓰이도록 알림 없이 위치만 고친다.
  void _showLatest() {
    _centerId = null;
    if (_controller.hasClients) _controller.position.correctPixels(0);
  }

  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    final bloc = context.read<ChannelMessageBloc>();
    if (_data.hasOlder &&
        !_data.loadingOlder &&
        metrics.extentAfter < _loadMoreExtent) {
      bloc.add(const ChannelMessageEvent.olderRequested());
    }
    if (_data.hasNewer &&
        !_data.loadingNewer &&
        metrics.extentBefore < _loadMoreExtent) {
      bloc.add(const ChannelMessageEvent.newerRequested());
    }
    // 최근 메시지까지 다 읽고 아래 끝에 닿으면 보통 목록으로 바꾼다. 기준 배치에서는
    // 새 메시지가 화면 아래 밖에 붙어, 아래 끝을 보고 있어도 보이지 않기 때문이다.
    // 아래 끝에서는 두 배치가 같은 모습이라 바꿔도 화면이 움직이지 않는다.
    if (_centerId != null &&
        !_data.hasNewer &&
        notification is ScrollEndNotification &&
        metrics.pixels <= metrics.minScrollExtent) {
      setState(_showLatest);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final messages = _data.messages;
    final center = _centerId == null ? -1 : _indexOf(_centerId!);
    const edge = SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16));
    const horizontal = EdgeInsets.symmetric(horizontal: AppSpacing.s12);
    const gap = SizedBox(height: AppSpacing.s18);

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: CustomScrollView(
        controller: _controller,
        reverse: true,
        center: center == -1 ? null : _centerKey,
        slivers: center == -1
            ? [
                edge,
                SliverPadding(
                  padding: horizontal,
                  sliver: SliverList.separated(
                    itemCount: messages.length,
                    separatorBuilder: (_, _) => gap,
                    itemBuilder: (context, index) =>
                        _row(context, messages[messages.length - 1 - index]),
                  ),
                ),
                edge,
              ]
            : [
                edge,
                // 기준보다 최근 메시지. 기준 바로 아래부터 아래로 이어진다.
                SliverPadding(
                  padding: horizontal,
                  sliver: SliverList.builder(
                    itemCount: messages.length - 1 - center,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.s18),
                      child: _row(context, messages[center + 1 + index]),
                    ),
                  ),
                ),
                // 기준 메시지와 그 이전 메시지. 기준부터 위로 이어진다.
                SliverPadding(
                  key: _centerKey,
                  padding: horizontal,
                  sliver: SliverList.separated(
                    itemCount: center + 1,
                    separatorBuilder: (_, _) => gap,
                    itemBuilder: (context, index) =>
                        _row(context, messages[center - index]),
                  ),
                ),
                edge,
              ],
      ),
    );
  }

  Widget _row(BuildContext context, ChatMessage message) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: message.id == _highlightId
            ? AppColors.amber400.withValues(alpha: 0.16)
            : AppColors.amber400.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ChatMessageRow(
        message: message,
        onTap: () => context.push(
          '/chat/channel/${context.read<ChannelMessageBloc>().channelId}/thread',
        ),
        onLongPress: message.editable
            ? () => _showMessageActions(context, message)
            : null,
      ),
    ),
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
