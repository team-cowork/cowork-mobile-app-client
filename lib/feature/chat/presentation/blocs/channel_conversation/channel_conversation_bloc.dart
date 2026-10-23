import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../data/channel_conversation_store.dart';
import '../../../domain/chat_message.dart';

part 'channel_conversation_event.dart';
part 'channel_conversation_state.dart';

class ChannelConversationBloc
    extends Bloc<ChannelConversationEvent, ChannelConversationState> {
  ChannelConversationBloc() : super(const ChannelConversationState.initial()) {
    on<ChannelConversationRequested>(_onLoad);
  }

  void _onLoad(
    ChannelConversationRequested event,
    Emitter<ChannelConversationState> emit,
  ) {
    emit(const ChannelConversationState.loading());
    try {
      final store = ChannelConversationStore.instance;
      emit(
        ChannelConversationState.success((
          name: store.channelName,
          description: store.channelDescription,
          messages: store.messages,
        )),
      );
    } catch (_) {
      emit(const ChannelConversationState.failure());
    }
  }
}
