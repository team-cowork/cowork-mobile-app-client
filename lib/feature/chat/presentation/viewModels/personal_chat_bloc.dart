import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../data/direct_message_store.dart';
import '../../domain/direct_message_preview.dart';
import '../../domain/dm_presence_entry.dart';

part 'personal_chat_event.dart';

typedef PersonalChatData = ({
  List<DmPresenceEntry> onlineStrip,
  List<DirectMessagePreview> pinned,
  List<DirectMessagePreview> recent,
});

typedef PersonalChatState = AsyncState<PersonalChatData>;

class PersonalChatBloc extends Bloc<PersonalChatEvent, PersonalChatState> {
  PersonalChatBloc() : super(const PersonalChatState.initial()) {
    on<PersonalChatRequested>(_onLoad);
  }

  void _onLoad(PersonalChatRequested event, Emitter<PersonalChatState> emit) {
    emit(const PersonalChatState.loading());
    try {
      final store = DirectMessageStore.instance;
      emit(
        PersonalChatState.success((
          onlineStrip: store.onlineStrip,
          pinned: store.pinned,
          recent: store.recent,
        )),
      );
    } catch (_) {
      emit(const PersonalChatState.failure());
    }
  }
}
