part of 'personal_chat_bloc.dart';

typedef PersonalChatData = ({
  List<DmPresenceEntry> onlineStrip,
  List<DirectMessagePreview> pinned,
  List<DirectMessagePreview> recent,
});

typedef PersonalChatState = AsyncState<PersonalChatData>;
