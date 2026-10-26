part of 'channel_members_bloc.dart';

typedef ChannelMembersData = ({
  String channelName,
  List<ChannelMember> members,
});

typedef ChannelMembersState = AsyncState<ChannelMembersData>;
