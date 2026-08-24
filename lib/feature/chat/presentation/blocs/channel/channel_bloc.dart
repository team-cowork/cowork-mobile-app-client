import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../data/channel_conversation_store.dart';
import '../../../domain/chat_message.dart';

part 'channel_event.dart';
part 'channel_state.dart';

class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  ChannelBloc() : super(const ChannelState.initial()) {
    on<ChannelRequested>(_onLoad);
  }

  void _onLoad(ChannelRequested event, Emitter<ChannelState> emit) {
    emit(const ChannelState.loading());
    try {
      final store = ChannelConversationStore.instance;
      emit(
        ChannelState.success((
          name: store.channelName,
          description: store.channelDescription,
          messages: store.messages,
        )),
      );
    } catch (_) {
      emit(const ChannelState.failure());
    }
  }
}
