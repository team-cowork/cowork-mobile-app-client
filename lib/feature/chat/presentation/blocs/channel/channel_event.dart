part of 'channel_bloc.dart';

sealed class ChannelEvent extends Equatable {
  const ChannelEvent();

  const factory ChannelEvent.requested() = ChannelRequested;

  @override
  List<Object?> get props => [];
}

final class ChannelRequested extends ChannelEvent {
  const ChannelRequested();
}
