import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../data/direct_message_store.dart';
import '../../domain/direct_message_preview.dart';
import '../../domain/dm_presence_entry.dart';

part 'dm_list_event.dart';

typedef DmListData = ({
  List<DmPresenceEntry> onlineStrip,
  List<DirectMessagePreview> pinned,
  List<DirectMessagePreview> recent,
});

typedef DmListState = AsyncState<DmListData>;

class DmListBloc extends Bloc<DmListEvent, DmListState> {
  DmListBloc() : super(const DmListState.initial()) {
    on<DmListRequested>(_onLoad);
  }

  void _onLoad(DmListRequested event, Emitter<DmListState> emit) {
    emit(const DmListState.loading());
    try {
      final store = DirectMessageStore.instance;
      emit(
        DmListState.success((
          onlineStrip: store.onlineStrip,
          pinned: store.pinned,
          recent: store.recent,
        )),
      );
    } catch (_) {
      emit(const DmListState.failure());
    }
  }
}
