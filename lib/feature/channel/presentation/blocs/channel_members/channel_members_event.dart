part of 'channel_members_bloc.dart';

sealed class ChannelMembersEvent extends Equatable {
  const ChannelMembersEvent();

  const factory ChannelMembersEvent.requested() = ChannelMembersRequested;

  @override
  List<Object?> get props => [];
}

final class ChannelMembersRequested extends ChannelMembersEvent {
  const ChannelMembersRequested();
}
