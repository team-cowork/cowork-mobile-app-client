import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/chat/presentation/blocs/personal_chat/personal_chat_bloc.dart';
import 'package:cowork_app/feature/profile/data/profile_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../channel/chat_test_server.dart';
import 'dm_test_server.dart';

FakeDmGateway _gateway() => FakeDmGateway(
  conversations: [
    dmJson(11, 2, content: '첫 대화', unreadCount: 2),
    dmJson(12, 3, content: '내가 보냄', authorId: 1),
  ],
);

PersonalChatBloc _bloc(
  FakeDmGateway gateway,
  FakeChatSocket socket, {
  Duration retryDelay = const Duration(seconds: 3),
}) => PersonalChatBloc(
  dmRepository: dmRepositoryOf(gateway),
  messageRepository: dmMessageRepositoryOf(gateway),
  socket: socket,
  retryDelay: retryDelay,
);

/// 불러오기까지 마친 Bloc. 이후 요청만 보도록 불러오기 기록은 비운다.
Future<PersonalChatBloc> _loaded(
  FakeDmGateway gateway,
  FakeChatSocket socket, {
  Duration retryDelay = const Duration(seconds: 3),
}) async {
  final bloc = _bloc(gateway, socket, retryDelay: retryDelay)
    ..add(const PersonalChatEvent.requested());
  await bloc.stream.firstWhere((s) => s is AsyncSuccess<PersonalChatData>);
  await pumpEventQueue();
  gateway.calls.clear();
  return bloc;
}

PersonalChatData _data(PersonalChatBloc bloc) =>
    (bloc.state as AsyncSuccess<PersonalChatData>).data;

List<String> _names(PersonalChatBloc bloc) => [
  for (final conversation in _data(bloc).conversations)
    conversation.profile.name,
];

void main() {
  setUp(() => ProfileStore.instance.currentUserId = 1);
  tearDown(() => ProfileStore.instance.currentUserId = null);

  test('대화와 상대 이름을 서버 순서대로 불러오고 각 대화 방에 들어간다', () async {
    final gateway = _gateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    final conversations = _data(bloc).conversations;
    expect(_names(bloc), ['서연', '도윤']);
    expect(conversations.first.channelId, 11);
    expect(conversations.first.unreadCount, 2);
    expect(conversations.last.lastMessage, '나: 내가 보냄');
    expect(socket.joinedChannels, {11, 12});
  });

  test('이름을 못 읽어도 목록은 보여 준다', () async {
    final gateway = _gateway()..failing = 'GET /user/users/batch';
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);

    expect(_names(bloc), ['알 수 없음', '알 수 없음']);
  });

  test('불러오기가 실패하면 실패 상태가 된다', () async {
    final gateway = _gateway()..failing = 'GET /chat/chat/dms';
    final bloc = _bloc(gateway, FakeChatSocket())
      ..add(const PersonalChatEvent.requested());
    addTearDown(bloc.close);

    await bloc.stream.firstWhere((s) => s is AsyncFailure<PersonalChatData>);
  });

  test('대화 방에 새 메시지가 오면 목록을 다시 읽고 이미 아는 이름은 다시 묻지 않는다', () async {
    final gateway = _gateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);
    gateway.conversations
      ..clear()
      ..addAll([
        dmJson(12, 3, content: '새 메시지', authorId: 3, unreadCount: 1),
        dmJson(11, 2, content: '첫 대화', unreadCount: 2),
      ]);

    socket.push('message', {'channelId': 12});
    await bloc.stream.firstWhere(
      (s) =>
          s is AsyncSuccess<PersonalChatData> &&
          s.data.conversations.first.channelId == 12,
    );

    expect(_data(bloc).conversations.first.lastMessage, '새 메시지');
    expect(_data(bloc).conversations.first.unreadCount, 1);
    expect(gateway.calls, ['GET /chat/chat/dms']);
  });

  test('목록에 없는 방의 메시지는 무시한다', () async {
    final gateway = _gateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    socket
      ..push('message', {'channelId': 99})
      ..push('message:edited', {'channelId': 11});
    await pumpEventQueue();

    expect(gateway.calls, isEmpty);
  });

  test('소켓이 끊김 복구 없이 다시 붙으면 목록을 다시 읽는다', () async {
    final gateway = _gateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    socket.reconnect();
    await pumpEventQueue();

    expect(gateway.calls, contains('GET /chat/chat/dms'));
  });

  test('다시 읽기가 실패해도 보던 목록은 그대로 둔다', () async {
    final gateway = _gateway();
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);
    gateway.failing = 'GET /chat/chat/dms';

    bloc.add(const PersonalChatEvent.refreshed());
    await pumpEventQueue();

    expect(_names(bloc), ['서연', '도윤']);
  });

  test('다시 읽기가 실패하면 이벤트를 기다리지 않고 스스로 다시 읽는다', () async {
    final gateway = _gateway();
    final bloc = await _loaded(
      gateway,
      FakeChatSocket(),
      retryDelay: const Duration(milliseconds: 10),
    );
    addTearDown(bloc.close);
    gateway.failing = 'GET /chat/chat/dms';

    bloc.add(const PersonalChatEvent.refreshed());
    await pumpEventQueue();
    gateway
      ..failing = null
      ..conversations.insert(0, dmJson(13, 4, content: '새 대화'));

    await bloc.stream.firstWhere(
      (s) =>
          s is AsyncSuccess<PersonalChatData> &&
          s.data.conversations.first.channelId == 13,
    );

    expect(_data(bloc).conversations, hasLength(3));
  });

  test('다시 읽기가 계속 실패하면 세 번까지만 다시 시도한다', () async {
    final gateway = _gateway();
    final bloc = await _loaded(
      gateway,
      FakeChatSocket(),
      retryDelay: const Duration(milliseconds: 5),
    );
    addTearDown(bloc.close);
    gateway.failing = 'GET /chat/chat/dms';

    bloc.add(const PersonalChatEvent.refreshed());
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // 처음 한 번과 다시 시도 세 번.
    expect(
      gateway.calls.where((call) => call == 'GET /chat/chat/dms'),
      hasLength(4),
    );
  });

  test('숨기면 목록에서 빠지고 서버에 DELETE 를 보낸다', () async {
    final gateway = _gateway();
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);

    bloc.add(const PersonalChatEvent.hidden(11));
    await pumpEventQueue();

    expect(_names(bloc), ['도윤']);
    expect(gateway.calls, ['DELETE /chat/chat/dms/11']);
  });

  test('숨기기가 실패하면 그 대화를 원래 자리에 되돌리고 사유를 싣는다', () async {
    final gateway = _gateway();
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);
    gateway.failing = 'DELETE /chat/chat/dms/11';

    bloc.add(const PersonalChatEvent.hidden(11));
    await bloc.stream.firstWhere(
      (s) => s is AsyncSuccess<PersonalChatData> && s.data.errorMessage != null,
    );

    expect(_names(bloc), ['서연', '도윤']);
    expect(_data(bloc).errorMessage, isNotNull);
  });

  test('닫으면 들어가 있던 대화 방에서 나간다', () async {
    final socket = FakeChatSocket();
    final bloc = await _loaded(_gateway(), socket);

    await bloc.close();

    expect(socket.joinedChannels, isEmpty);
  });
}
