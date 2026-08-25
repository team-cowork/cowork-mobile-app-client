import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../data/chat_home_store.dart';
import '../../../domain/channel.dart';
import '../../../domain/workspace_shortcut.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// 홈(채팅 목록) 화면 상태를 관리하는 Bloc.
///
/// 현재는 목(mock) 데이터를 반환한다. 실제 API 연동 시 [_onLoad] 내부만 교체하면 된다.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatState.initial()) {
    on<ChatRequested>(_onLoad);
  }

  void _onLoad(ChatRequested event, Emitter<ChatState> emit) {
    emit(const ChatState.loading());
    try {
      final store = ChatHomeStore.instance;
      emit(
        ChatState.success((
          workspaceName: store.workspaceName,
          workspaceShortcuts: store.workspaceShortcuts,
          channelGroups: store.channelGroups,
        )),
      );
    } catch (_) {
      emit(const ChatState.failure());
    }
  }
}
