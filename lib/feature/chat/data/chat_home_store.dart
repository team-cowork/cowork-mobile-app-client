import '../domain/channel.dart';
import '../domain/enums/channel_type.dart';

/// 홈(채팅 목록) 화면의 목(mock) 데이터 저장소.
///
/// 백엔드 연동 전까지 정적 시드 데이터를 반환한다.
/// 실제 API 연동 시 이 싱글턴을 리포지토리로 교체한다.
class ChatHomeStore {
  ChatHomeStore._();

  static final ChatHomeStore instance = ChatHomeStore._();

  String get workspaceName => '코워크';

  List<ChannelGroup> get channelGroups => const [
    ChannelGroup(
      name: '디자인',
      channels: [
        Channel(id: 'chat', name: '채팅', type: ChannelType.chat),
        Channel(id: 'webhook', name: '깃허브 웹훅', type: ChannelType.webhook),
        Channel(id: 'file', name: '파일', type: ChannelType.file),
        Channel(
          id: 'account-share',
          name: '계정 공유',
          type: ChannelType.accountShare,
        ),
        Channel(id: 'meeting-note', name: '회의록', type: ChannelType.meetingNote),
        Channel(id: 'voice', name: '음성', type: ChannelType.voice),
      ],
    ),
  ];
}
