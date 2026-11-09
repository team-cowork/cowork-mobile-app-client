import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../data/channel_members_store.dart';
import '../../../domain/channel_member.dart';

part 'channel_members_event.dart';
part 'channel_members_state.dart';

class ChannelMembersBloc
    extends Bloc<ChannelMembersEvent, ChannelMembersState> {
  ChannelMembersBloc() : super(const ChannelMembersState.initial()) {
    on<ChannelMembersRequested>(_onLoad);
  }

  void _onLoad(
    ChannelMembersRequested event,
    Emitter<ChannelMembersState> emit,
  ) {
    emit(const ChannelMembersState.loading());
    try {
      final store = ChannelMembersStore.instance;
      emit(
        ChannelMembersState.success((
          channelName: store.channelName,
          members: store.members,
        )),
      );
    } catch (e, s) {
      Logger.e('채널 멤버 조회 실패', tag: 'ChannelMembers', error: e, stackTrace: s);
      emit(
        ChannelMembersState.failure(
          e is DioException ? dioErrorMessage(e) : null,
        ),
      );
    }
  }
}
