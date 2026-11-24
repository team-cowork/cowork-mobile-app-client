import '../domain/enums/chat_avatar_color.dart';
import '../domain/profile_entity.dart';
import 'initial.dart';

/// 같은 사람이 늘 같은 색이 되도록 작성자 id 로 고르는 아바타 색.
const _avatarColors = [
  ChatAvatarColor.blue,
  ChatAvatarColor.green,
  ChatAvatarColor.amber,
  ChatAvatarColor.red,
];

const _unknownAuthorName = '알 수 없음';

/// 이름을 아직 모르는 작성자. 이름을 받아 오면 [chatAuthorOf] 로 바꾼다.
ProfileEntity unknownChatAuthor(int id) =>
    ProfileEntity(id: id, name: _unknownAuthorName, avatarInitial: '?');

/// [author] 가 [unknownChatAuthor] 로 만든, 이름을 모르는 작성자인지.
bool isUnknownChatAuthor(ProfileEntity author) =>
    author.name == _unknownAuthorName && author.avatarInitial == '?';

/// 표시 이름으로 만든 작성자. 이름이 비어 있으면 [unknownChatAuthor].
ProfileEntity chatAuthorOf(int id, String name) => name.isEmpty
    ? unknownChatAuthor(id)
    : ProfileEntity(id: id, name: name, avatarInitial: initialOf(name));

/// 시스템 메시지(GitHub 연동 결과 등)의 작성자. 사람 이름을 찾지 않는다.
ProfileEntity systemChatAuthor(int id) =>
    ProfileEntity(id: id, name: '시스템', avatarInitial: '시');

/// 웹훅 메시지의 작성자. 웹훅에 붙은 이름·아바타를 그대로 쓴다.
ProfileEntity webhookChatAuthor(int id, String name, {String? avatarUrl}) =>
    ProfileEntity(
      id: id,
      name: name.isEmpty ? '웹훅' : name,
      avatarInitial: name.isEmpty ? '웹' : initialOf(name),
      avatarUrl: avatarUrl,
    );

ChatAvatarColor chatAvatarColorOf(int authorId) =>
    _avatarColors[authorId % _avatarColors.length];
