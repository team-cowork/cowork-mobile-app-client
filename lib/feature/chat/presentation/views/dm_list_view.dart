import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/chat_socket.dart';
import '../../../../core/utils/async_state.dart';
import '../../../../shared/utils/chat_author.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../data/repositories/dm_repository.dart';
import '../../domain/direct_message_preview.dart';
import '../blocs/personal_chat/personal_chat_bloc.dart';
import '../widgets/dm_list_header.dart';
import '../widgets/dm_list_tile.dart';

class DmListView extends StatelessWidget {
  const DmListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<PersonalChatBloc, PersonalChatData>(
      create: (context) => PersonalChatBloc(
        dmRepository: context.read<DmRepository>(),
        profileRepository: context.read<ProfileRepository>(),
        socket: context.read<ChatSocket>(),
      )..add(const PersonalChatEvent.requested()),
      errorTitle: 'DM 목록을 불러오지 못했어요',
      onRetry: (context) => context.read<PersonalChatBloc>().add(
        const PersonalChatEvent.requested(),
      ),
      builder: (context, data) =>
          BlocListener<PersonalChatBloc, PersonalChatState>(
            listenWhen: (previous, current) =>
                current is AsyncSuccess<PersonalChatData> &&
                current.data.errorMessage != null,
            listener: (context, state) {
              final message =
                  (state as AsyncSuccess<PersonalChatData>).data.errorMessage!;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            },
            child: SafeArea(
              child: Column(
                children: [
                  const DmListHeader(),
                  Expanded(
                    child: data.conversations.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.s16),
                              child: CoworkEmptyState(
                                icon: Icons.chat_bubble_outline,
                                title: '아직 대화가 없어요',
                                description: '동료에게 첫 메시지를 보내 보세요.',
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s8,
                            ),
                            children: [
                              for (final preview in data.conversations)
                                DmListTile(
                                  preview: preview,
                                  onTap: () => _open(context, preview),
                                  onLongPress: () =>
                                      _confirmHide(context, preview),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// 대화 화면으로 가고, 돌아오면 읽은 만큼 줄어든 읽지 않은 수를 다시 읽는다.
  static Future<void> _open(
    BuildContext context,
    DirectMessagePreview preview,
  ) async {
    final bloc = context.read<PersonalChatBloc>();
    await context.push(
      Uri(
        path: '/chat/channel/${preview.channelId}',
        queryParameters: {
          'dm': '1',
          // 이름을 못 읽은 상대의 '알 수 없음' 이 대화 화면 머리에 굳지 않게 뺀다.
          if (!isUnknownChatAuthor(preview.profile))
            'dmName': preview.profile.name,
        },
      ).toString(),
    );
    if (!bloc.isClosed) bloc.add(const PersonalChatEvent.refreshed());
  }

  static Future<void> _confirmHide(
    BuildContext context,
    DirectMessagePreview preview,
  ) async {
    final bloc = context.read<PersonalChatBloc>();
    final confirmed = await CoworkDialog.show(
      context,
      title: '${preview.profile.name}님과의 대화를 숨길까요?',
      message: '상대가 새 메시지를 보내면 다시 나타나요.',
      confirmLabel: '숨기기',
      cancelLabel: '취소',
      confirmColor: CoworkButtonColor.danger,
    );
    if (confirmed == true && !bloc.isClosed) {
      bloc.add(PersonalChatEvent.hidden(preview.channelId));
    }
  }
}
