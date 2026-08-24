import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../data/channel_members_store.dart';
import '../../../domain/channel_member.dart';

part 'members_event.dart';
part 'members_state.dart';

class MembersBloc extends Bloc<MembersEvent, MembersState> {
  MembersBloc() : super(const MembersState.initial()) {
    on<MembersRequested>(_onLoad);
  }

  void _onLoad(MembersRequested event, Emitter<MembersState> emit) {
    emit(const MembersState.loading());
    try {
      final store = ChannelMembersStore.instance;
      emit(
        MembersState.success((
          channelName: store.channelName,
          members: store.members,
        )),
      );
    } catch (_) {
      emit(const MembersState.failure());
    }
  }
}
