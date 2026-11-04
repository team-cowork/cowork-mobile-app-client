import '../../../../shared/utils/initial.dart';
import '../../../channel/data/model/responses/channel_response.dart';
import '../../../profile/data/model/responses/user_response.dart';
import '../../domain/enums/avatar_color.dart';
import '../../domain/search_result.dart';
import 'responses/search_message_item_response.dart';
import 'responses/search_messages_response.dart';

/// 채널 검색 응답을 화면 결과로. 서버가 매칭 미리보기를 주지 않아 채널 설명을 쓴다.
SearchChannelResult searchChannelResultOf(ChannelResponse channel) =>
    SearchChannelResult(
      id: '${channel.id}',
      name: channel.name,
      description: channel.description ?? '',
    );

/// 사용자 검색 응답을 화면 결과로.
///
/// 이름이 비면 닉네임을 쓴다. 역할 줄에는 직군(`specialty`)을 보인다.
SearchPersonResult searchPersonResultOf(UserResponse user) {
  final name = _text(user.name) ?? _text(user.nickname) ?? '';
  return SearchPersonResult(
    id: '${user.id ?? ''}',
    name: name,
    role: _text(user.specialty) ?? '',
    initial: initialOf(name),
    avatarColor: _avatarColorOf(user.id ?? name.hashCode),
  );
}

/// 메시지 검색 응답 한 페이지를 화면 모델로.
SearchMessagePage searchMessagePageOf(SearchMessagesResponse response) =>
    SearchMessagePage(
      messages: [
        for (final item in response.messages) _searchMessageResultOf(item),
      ],
      nextCursor: response.nextCursor,
    );

SearchMessageResult _searchMessageResultOf(SearchMessageItemResponse item) =>
    SearchMessageResult(
      id: item.messageId,
      channelId: item.channelId,
      authorId: item.authorId,
      content: item.content,
      highlights: item.highlight,
      // 서버는 UTC 로 준다. 화면이 지역 시각으로 바꿔 쓴다.
      createdAt: DateTime.parse(item.createdAt),
    );

/// 같은 사람이 늘 같은 색이 되도록 id 로 고른다.
AvatarColor _avatarColorOf(int seed) =>
    AvatarColor.values[seed.abs() % AvatarColor.values.length];

/// 서버가 값 없음을 null 로도, 빈 문자열로도 주므로 둘 다 null 로 본다.
String? _text(String? value) =>
    value == null || value.trim().isEmpty ? null : value.trim();
