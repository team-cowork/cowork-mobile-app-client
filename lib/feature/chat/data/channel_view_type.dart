import '../domain/enums/channel_type.dart';

/// 앱의 [ChannelType] 과 서버 채널 `viewType` 의 짝.
///
/// 서버는 채널을 `type`(TEXT/VOICE/DM) 과 `viewType`(화면 종류) 두 값으로 나누는데,
/// 앱이 구분하는 건 화면 종류라 `viewType` 하나와 짝을 짓는다. `type` 은 음성만
/// VOICE 고 나머지는 TEXT 다. 웹 클라이언트와 같은 규칙이다.
const _viewTypes = {
  ChannelType.chat: 'TEXT',
  ChannelType.webhook: 'WEBHOOK',
  ChannelType.file: 'FILE_SHARE',
  ChannelType.accountShare: 'ACCOUNT_SHARE',
  ChannelType.meetingNote: 'MEETING_NOTE',
  ChannelType.voice: 'VOICE',
};

/// 생성 요청에 실을 서버 `viewType`.
String viewTypeOf(ChannelType type) => _viewTypes[type]!;

/// 생성 요청에 실을 서버 `type`.
String serverTypeOf(ChannelType type) =>
    type == ChannelType.voice ? 'VOICE' : 'TEXT';

/// 서버 `viewType` 을 앱 채널 종류로. 앱이 모르는 값은 일반 채팅으로 본다.
///
/// 서버에 화면 종류가 새로 생겨도 목록에서 채널이 사라지지 않게 하려는 것이다.
ChannelType channelTypeOf(String? viewType) =>
    _viewTypes.entries
        .where((entry) => entry.value == viewType)
        .firstOrNull
        ?.key ??
    ChannelType.chat;
