part of 'members_bloc.dart';

typedef ChannelMembersData = ({
  String channelName,
  List<ChannelMember> members,
});

typedef MembersState = AsyncState<ChannelMembersData>;
