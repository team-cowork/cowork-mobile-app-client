import 'dart:async';
import 'dart:math';

import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderSliver;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/chat_socket.dart';
import '../../../../core/utils/app_lifecycle.dart';
import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/domain/upload_file.dart';
import '../../../../shared/utils/external_url.dart';
import '../../../../shared/utils/file_picking.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../../channel/data/repositories/channel_repository.dart';
import '../../../channel/domain/enums/channel_type.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../data/repositories/chat_file_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../domain/chat_message.dart';
import '../blocs/channel_message/channel_message_bloc.dart';
import '../utils/attachment_opener.dart';
import '../widgets/attachment_image_preview.dart';
import '../widgets/chat_message_row.dart';

class ChannelView extends StatelessWidget {
  const ChannelView({
    required this.channelId,
    this.focusMessageId,
    this.dmName,
    this.isDirect = false,
    this.openUrl = launchExternally,
    this.pickFiles = pickUploadFiles,
    super.key,
  });

  final int channelId;

  /// DM 대화면 상대 이름. DM 채널 이름은 서버가 늘 `DM` 으로 정해, 머리에는 이 이름을
  /// 보이고 채널 멤버·설정 같은 채널 전용 버튼은 숨긴다. 이름을 모르면 null 이다.
  final String? dmName;

  /// DM 대화인지. [dmName] 이 있으면 DM 이고, 이름을 몰라도 DM 이면 true 로 넘긴다. 이때
  /// 머리에는 `다이렉트 메시지` 를 보인다.
  final bool isDirect;

  bool get _isDirect => isDirect || dmName != null;

  /// 첨부파일 주소를 여는 방법. 테스트에서 바꾼다.
  final UrlOpener openUrl;

  /// 보낼 파일을 고르는 방법. 테스트에서 기기 선택 창 대신 가짜 파일을 넣는다.
  final UploadFilesPicker pickFiles;

  /// 열 때 보여 줄 메시지(검색 결과에서 고른 것). 없으면 최근 메시지부터 연다.
  final String? focusMessageId;

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<ChannelMessageBloc, ChannelConversation>(
      create: (context) => ChannelMessageBloc(
        channelId: channelId,
        channelRepository: context.read<ChannelRepository>(),
        messageRepository: context.read<MessageRepository>(),
        fileRepository: context.read<ChatFileRepository>(),
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
                name: dmName ?? (_isDirect ? '다이렉트 메시지' : data.name),
                description: _isDirect ? '' : data.description,
                isDirect: _isDirect,
                onBack: () => context.pop(),
                onMembersTap: () =>
                    context.push('/chat/channel/$channelId/members'),
                onMoreTap: () =>
                    context.push('/chat/channel/$channelId/settings'),
              ),
              ...switch (data.type) {
                ChannelType.chat => [
                  Expanded(
                    child: _MessageList(data: data, openUrl: openUrl),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s12,
                      AppSpacing.s8,
                      AppSpacing.s12,
                      AppSpacing.s24,
                    ),
                    child: _MessageComposer(pickFiles: pickFiles),
                  ),
                ],
                // 웹훅 채널은 외부 서비스가 메시지를 올리는 곳이라 읽기만 한다.
                ChannelType.webhook => [
                  Expanded(
                    child: _MessageList(data: data, openUrl: openUrl),
                  ),
                ],
                // 종류를 모두 적어, 새 종류가 생기면 어디에 보일지 컴파일 단계에서 정하게 한다.
                ChannelType.file ||
                ChannelType.accountShare ||
                ChannelType.meetingNote ||
                ChannelType.voice => const [
                  Expanded(child: _UnsupportedChannel()),
                ],
              },
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

/// 앱에서 아직 열 수 없는 종류(파일·계정 공유·회의록·음성)의 채널 본문.
class _UnsupportedChannel extends StatelessWidget {
  const _UnsupportedChannel();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s16),
        child: CoworkEmptyState(
          icon: Icons.construction_outlined,
          title: '아직 앱에서 열 수 없는 채널이에요',
          description: '이 채널은 웹에서 열어 주세요',
        ),
      ),
    );
  }
}

/// 최신 메시지가 아래에 붙는 대화 목록. 위 끝 근처까지 올리면 이전 메시지를, 과거
/// 위치에서 열었으면 아래 끝 근처까지 내릴 때 이후 메시지를 부른다.
///
/// 검색 결과로 열면 [ChannelConversation.focusMessageId] 메시지를 기준(`center`)으로
/// 배치한다. 목록이 화면에 보이는 줄만 만들어서, 멀리 있는 줄은 위치를 알 수 없기
/// 때문이다. 기준 메시지가 스크롤 0 에 오고, 그보다 최근 메시지는 아래로 이어 붙는다.
class _MessageList extends StatefulWidget {
  const _MessageList({required this.data, required this.openUrl});

  final ChannelConversation data;
  final UrlOpener openUrl;

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  /// 위·아래 끝에서 이만큼 남으면 미리 다음 메시지를 부른다.
  static const _loadMoreExtent = 400.0;

  /// 고른 메시지를 강조해 두는 시간.
  static const _highlightDuration = Duration(seconds: 2);

  final _controller = ScrollController();

  /// 기준 메시지 묶음의 키. [_olderExtent] 가 그 높이를 읽는다.
  final _centerKey = GlobalKey();

  /// 이 메시지를 기준으로 배치한다. null 이면 최근 메시지가 아래 끝인 보통 목록이다.
  String? _centerId;

  /// 스크롤 0 의 위치. 화면 높이에 대한 비율이고 아래 끝이 0 이다. 기준 배치에서
  /// 오래된 쪽이 화면보다 짧을 때만 올린다([_revealFocus]).
  double _anchor = 0;

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
    if (center == null) return;
    // 보내려고 최근 대화로 옮겼으면 보통 목록의 아래 끝으로.
    if (_data.focusMessageId == null) {
      _showLatest();
      return;
    }
    // 기준 메시지가 지워졌으면 남은 이웃을 새 기준으로 삼아 보던 자리를 지킨다.
    if (_indexOf(center) == -1) {
      final neighbor = _survivingNeighbor(oldWidget.data.messages, center);
      if (neighbor == null) {
        _showLatest();
      } else {
        _centerId = neighbor;
      }
    }
  }

  /// [before] 에서 [removedId] 와 가장 가까운, 지금 목록에도 남은 메시지. 바로 이전
  /// 메시지를 먼저 찾는다. 기준선(스크롤 0)이 기준 메시지 바로 아래라, 이전 메시지를
  /// 기준으로 삼으면 그 아래 최근 메시지는 제자리에 있고 위쪽만 지운 줄만큼 내려온다.
  /// 보통 목록에서 메시지를 지울 때와 같은 모습이다.
  String? _survivingNeighbor(List<ChatMessage> before, String removedId) {
    final index = before.indexWhere((message) => message.id == removedId);
    if (index == -1) return null;
    for (var i = index - 1; i >= 0; i--) {
      if (_indexOf(before[i].id) != -1) return before[i].id;
    }
    for (var i = index + 1; i < before.length; i++) {
      if (_indexOf(before[i].id) != -1) return before[i].id;
    }
    return null;
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
  ///
  /// 채널 처음 근처를 열면 기준과 그 이전 메시지가 화면보다 짧다. 기준선이 화면 아래
  /// 끝이면 위로 올릴 수 있는 끝(스크롤 0)에서 그 위가 빈다. 그럴 땐 기준선을 그 길이만큼
  /// 올려, 스크롤 0 에서 채널 첫 메시지가 화면 위 끝에 오게 한다. 메시지가 모두 화면에
  /// 들어가면 보통 목록처럼 최근 메시지가 아래 끝에 오게 올린다. 어느 쪽이든 스크롤
  /// 범위가 보통 목록과 같아져 위·아래로 빈 곳이 생기지 않는다.
  void _revealFocus() {
    if (!mounted || !_controller.hasClients) return;
    final position = _controller.position;
    final viewport = position.viewportDimension;
    final older = _olderExtent();
    if (!_data.hasOlder && older != null && older < viewport) {
      // 기준선이 아래 끝(0)이면 최소 스크롤 위치가 -(최근 쪽 높이)다.
      final newer = -position.minScrollExtent;
      setState(() {
        _anchor = older + newer <= viewport
            ? newer / viewport
            : 1 - older / viewport;
      });
      return;
    }
    _controller.jumpTo(max(position.minScrollExtent, -viewport / 3));
  }

  /// 기준 메시지와 그 이전 메시지, 위 여백을 합친 높이. 화면에 다 그려지지 않았으면
  /// 목록이 추정한 값이다.
  double? _olderExtent() {
    final sliver = _centerKey.currentContext?.findRenderObject();
    if (sliver is! RenderSliver) return null;
    final extent = sliver.geometry?.scrollExtent;
    return extent == null ? null : extent + AppSpacing.s16;
  }

  /// 기준 배치를 풀고 최근 메시지가 아래 끝인 보통 목록으로 돌아간다. 보통 목록은
  /// 스크롤 0 이 아래 끝이다. 다음 배치에 바로 쓰이도록 알림 없이 위치만 고친다.
  void _showLatest() {
    _centerId = null;
    _anchor = 0;
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
        anchor: _anchor,
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

  Widget _row(BuildContext context, ChatMessage message) {
    // 보내는 중이거나 보내지 못한 파일 메시지는 서버에 없어 스레드·첨부를 열 수 없다.
    // 보내지 못했으면 눌러서 다시 보내거나 지운다.
    if (message.upload case final upload?) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
        child: ChatMessageRow(
          message: message,
          onTap: upload.failed
              ? () => _showFailedActions(context, message)
              : null,
        ),
      );
    }
    final row = ChatMessageRow(
      message: message,
      onTap: () => context.push(
        Uri(
          path:
              '/chat/channel/${context.read<ChannelMessageBloc>().channelId}/thread',
          queryParameters: {'parentMessageId': message.id},
        ).toString(),
      ),
      onLongPress: message.editable
          ? () => _showMessageActions(context, message)
          : null,
      onAttachmentTap: (index) => _openAttachment(context, message, index),
      imageBuilder: (index, attachment) => AttachmentImagePreview(
        key: ValueKey('${message.id}/$index'),
        repository: context.read<MessageRepository>(),
        channelId: context.read<ChannelMessageBloc>().channelId,
        messageId: message.id,
        attachmentIndex: index,
        name: attachment.name,
        onTap: () => _openAttachment(context, message, index),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      // 강조는 고른 메시지 한 줄에만 하므로 그 줄만 감싼다. 강조가 끝나도 감싼 채로
      // 두어야 배경이 서서히 사라진다.
      child: message.id == _data.focusMessageId
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                color: message.id == _highlightId
                    ? AppColors.amber400.withValues(alpha: 0.16)
                    : AppColors.amber400.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: row,
            )
          : row,
    );
  }

  late final _attachmentOpener = AttachmentOpener(
    repository: context.read<MessageRepository>(),
    open: widget.openUrl,
  );

  Future<void> _openAttachment(
    BuildContext rowContext,
    ChatMessage message,
    int index,
  ) async {
    final channelId = rowContext.read<ChannelMessageBloc>().channelId;
    final failure = await _attachmentOpener.open(channelId, message.id, index);
    // 줄이 스크롤 밖으로 나가 사라져도 안내는 목록 화면 기준으로 띄운다.
    if (failure != null && mounted) ChannelView._notify(context, failure);
  }

  /// 내 메시지를 길게 눌렀을 때. 고치거나 지울지 고르게 한다.
  static Future<void> _showMessageActions(
    BuildContext context,
    ChatMessage message,
  ) async {
    final bloc = context.read<ChannelMessageBloc>();
    final action = await _ActionSheet.show(context, const [
      _ActionItem(
        icon: Icons.edit_outlined,
        label: '메시지 수정',
        value: _MessageAction.edit,
      ),
      _ActionItem(
        icon: Icons.delete_outline,
        label: '메시지 삭제',
        value: _MessageAction.delete,
        destructive: true,
      ),
    ]);
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

  /// 보내지 못한 파일 메시지를 눌렀을 때. 다시 보낼지 지울지 고르게 한다.
  static Future<void> _showFailedActions(
    BuildContext context,
    ChatMessage message,
  ) async {
    final bloc = context.read<ChannelMessageBloc>();
    final action = await _ActionSheet.show(context, const [
      _ActionItem(
        icon: Icons.refresh,
        label: '다시 보내기',
        value: _FailedFileAction.retry,
      ),
      _ActionItem(
        icon: Icons.delete_outline,
        label: '삭제',
        value: _FailedFileAction.discard,
        destructive: true,
      ),
    ]);
    switch (action) {
      case _FailedFileAction.retry:
        bloc.add(ChannelMessageEvent.retried(message.id));
      case _FailedFileAction.discard:
        bloc.add(ChannelMessageEvent.discarded(message.id));
      case null:
        break;
    }
  }
}

enum _MessageAction { edit, delete }

enum _FailedFileAction { retry, discard }

enum _AttachSource { photo, file }

/// [_ActionSheet] 의 한 줄.
class _ActionItem<T> {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.value,
    this.destructive = false,
  });

  final IconData icon;
  final String label;

  /// 이 줄을 고르면 시트가 돌려줄 값.
  final T value;
  final bool destructive;
}

/// 아래에서 올라오는 메뉴. 고른 줄의 값을 돌려주고, 그냥 닫으면 null.
class _ActionSheet<T> extends StatelessWidget {
  const _ActionSheet({required this.items});

  final List<_ActionItem<T>> items;

  static Future<T?> show<T>(BuildContext context, List<_ActionItem<T>> items) =>
      showModalBottomSheet<T>(
        context: context,
        backgroundColor: AppColors.neutral800,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _ActionSheet<T>(items: items),
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
            for (final item in items) _ActionRow<T>(item: item),
          ],
        ),
      ),
    );
  }
}

class _ActionRow<T> extends StatelessWidget {
  const _ActionRow({required this.item});

  final _ActionItem<T> item;

  @override
  Widget build(BuildContext context) {
    final color = item.destructive ? AppColors.red400 : AppColors.darkOnSurface;

    return InkWell(
      onTap: () => Navigator.of(context).pop(item.value),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
        child: Row(
          spacing: AppSpacing.s14,
          children: [
            Icon(item.icon, size: 20, color: color),
            Text(item.label, style: AppFont.labelS.copyWith(color: color)),
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
            CoworkTextArea(
              controller: _controller,
              minLines: 3,
              autofocus: true,
            ),
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

/// 입력창. 고른 파일은 위에 모아 두었다가 글과 함께 한 메시지로 보낸다. 보내면 비운다.
class _MessageComposer extends StatefulWidget {
  const _MessageComposer({required this.pickFiles});

  final UploadFilesPicker pickFiles;

  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer> {
  final _controller = TextEditingController();

  /// 보낼 때 같이 보낼 파일. 아직 올리지 않았다.
  final _files = <UploadFile>[];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 보내자마자 입력창을 비운다. 보내기 전에 멈추면(사유는 Bloc 이 알린다) 글과 파일을
  /// 되돌려 다시 보낼 수 있게 한다.
  Future<void> _send() async {
    final text = _controller.text;
    final files = List.of(_files);
    if (text.trim().isEmpty && files.isEmpty) return;
    final accepted = Completer<bool>();
    context.read<ChannelMessageBloc>().add(
      ChannelMessageEvent.sent(text, files: files, accepted: accepted),
    );
    _controller.clear();
    setState(_files.clear);

    if (await accepted.future || !mounted) return;
    // 기다리는 사이 새로 쓴 글은 덮어쓰지 않는다.
    if (_controller.text.isEmpty) _controller.text = text;
    final room = ChannelMessageBloc.maxAttachments - _files.length;
    setState(() => _files.insertAll(0, files.take(room)));
  }

  /// 사진이나 파일을 골라 입력창 위에 모은다. 보내기를 눌러야 보낸다.
  Future<void> _attach() async {
    final source = await _ActionSheet.show(context, const [
      _ActionItem(
        icon: Icons.image_outlined,
        label: '사진',
        value: _AttachSource.photo,
      ),
      _ActionItem(
        icon: Icons.insert_drive_file_outlined,
        label: '파일',
        value: _AttachSource.file,
      ),
    ]);
    if (source == null) return;

    final List<UploadFile> files;
    try {
      files = await widget.pickFiles(images: source == _AttachSource.photo);
    } catch (e, s) {
      Logger.e('보낼 파일 선택 실패', tag: 'Chat', error: e, stackTrace: s);
      if (mounted) ChannelView._notify(context, '고른 파일을 읽지 못했어요.');
      return;
    }
    if (!mounted || files.isEmpty) return;

    // 한 메시지에 붙일 수 있는 만큼만 담는다. 넘치면 보낼 때가 아니라 지금 알린다.
    const max = ChannelMessageBloc.maxAttachments;
    final room = max - _files.length;
    setState(() => _files.addAll(files.take(room)));
    if (files.length > room) {
      ChannelView._notify(context, '파일은 한 번에 $max개까지 보낼 수 있어요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s8,
      children: [
        if (_files.isNotEmpty)
          _PickedFiles(
            files: _files,
            onRemove: (index) => setState(() => _files.removeAt(index)),
          ),
        CoworkMessageComposer(
          hintText: '메시지를 입력하세요',
          controller: _controller,
          onSubmitted: (_) => _send(),
          onSend: _send,
          onAttach: _attach,
        ),
      ],
    );
  }
}

/// 입력창 위에 보이는, 보낼 때 같이 보낼 파일들. 가로로 넘긴다.
class _PickedFiles extends StatelessWidget {
  const _PickedFiles({required this.files, required this.onRemove});

  final List<UploadFile> files;

  /// 그 파일을 뺀다. 몇 번째 파일인지 넘긴다.
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s8),
        itemBuilder: (context, index) => _PickedFileChip(
          file: files[index],
          onRemove: () => onRemove(index),
        ),
      ),
    );
  }
}

class _PickedFileChip extends StatelessWidget {
  const _PickedFileChip({required this.file, required this.onRemove});

  final UploadFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isImage = ChatFileRepository.contentTypeOf(
      file.name,
    ).startsWith('image/');

    return Container(
      padding: const EdgeInsets.only(left: AppSpacing.s12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.r14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.s8,
        children: [
          Icon(
            isImage ? Icons.image_outlined : Icons.insert_drive_file_outlined,
            size: 18,
            color: colors.onSurfaceVariant,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFont.labelS.copyWith(color: colors.onSurface),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: '${file.name} 빼기',
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close, size: 16, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ChannelHeader extends StatelessWidget {
  const _ChannelHeader({
    required this.name,
    required this.description,
    this.isDirect = false,
    this.onBack,
    this.onMembersTap,
    // ignore: unused_element_parameter -- 더보기 동작 미연결. 배선되면 이 줄을 지운다.
    this.onMoreTap,
  });

  final String name;
  final String description;

  /// DM 대화의 머리. 채널 아이콘·설명·멤버·설정 버튼을 그리지 않는다.
  final bool isDirect;
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
          if (!isDirect) ...[
            AppIcon.hash(),
            const SizedBox(width: AppSpacing.s10),
          ],
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
                if (!isDirect)
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.subtextS.copyWith(
                      color: AppColors.neutral300,
                    ),
                  ),
              ],
            ),
          ),
          if (!isDirect) ...[
            GestureDetector(onTap: onMembersTap, child: AppIcon.users()),
            const SizedBox(width: AppSpacing.s16),
            GestureDetector(onTap: onMoreTap, child: AppIcon.more()),
          ],
        ],
      ),
    );
  }
}
