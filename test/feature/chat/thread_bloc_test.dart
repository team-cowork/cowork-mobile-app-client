import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:cowork_app/feature/chat/domain/message_thread.dart';
import 'package:cowork_app/feature/chat/presentation/blocs/thread/thread_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../channel/chat_test_server.dart';
import 'channel_message_test_server.dart';

/// 부모 메시지 `m1`(서연, "첫 번째") 의 스레드. 답글은 민재 → 도윤 순으로 최신순이다.
FakeMessageGateway _gateway() => FakeMessageGateway(
  replies: [
    messageJson('r2', 4, '두 번째 답글', parentMessageId: 'm1'),
    messageJson('r1', 2, '첫 번째 답글', parentMessageId: 'm1'),
  ],
);

ThreadBloc _bloc(
  FakeMessageGateway gateway,
  FakeChatSocket socket, {
  Duration confirmTimeout = const Duration(seconds: 10),
}) => ThreadBloc(
  channelId: 10,
  parentMessageId: 'm1',
  channelRepository: ChannelRepository.withDio(messageDio(gateway, 'channel')),
  messageRepository: MessageRepository.withDio(
    chat: messageDio(gateway, 'chat'),
    user: messageDio(gateway, 'user'),
  ),
  socket: socket,
  confirmTimeout: confirmTimeout,
);

/// 불러오기까지 마친 Bloc. 이후 요청만 보도록 불러오기 기록은 비운다.
Future<ThreadBloc> _loaded(
  FakeMessageGateway gateway,
  FakeChatSocket socket, {
  Duration confirmTimeout = const Duration(seconds: 10),
}) async {
  final bloc = _bloc(gateway, socket, confirmTimeout: confirmTimeout)
    ..add(const ThreadEvent.requested());
  await bloc.stream.firstWhere((s) => s is AsyncSuccess<ThreadConversation>);
  await pumpEventQueue();
  gateway.calls.clear();
  return bloc;
}

ThreadConversation _conversation(ThreadBloc bloc) =>
    (bloc.state as AsyncSuccess<ThreadConversation>).data;

MessageThread _data(ThreadBloc bloc) => _conversation(bloc).thread;

List<String> _replyTexts(ThreadBloc bloc) => [
  for (final reply in _data(bloc).replies) reply.text,
];

Map<String, dynamic> _reply(
  String id,
  int authorId,
  String content, {
  String? clientMessageId,
  String? parentMessageId = 'm1',
  int channelId = 10,
}) => messageJson(
  id,
  authorId,
  content,
  channelId: channelId,
  clientMessageId: clientMessageId,
  parentMessageId: parentMessageId,
);

void main() {
  test('부모 메시지와 답글을 오래된 순으로 작성자 이름과 함께 보여 준다', () async {
    final gateway = _gateway();
    final socket = FakeChatSocket();
    final bloc = _bloc(gateway, socket)..add(const ThreadEvent.requested());
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s is AsyncSuccess<ThreadConversation>);
    await pumpEventQueue();

    final thread = _data(bloc);
    expect(thread.channelName, '백엔드');
    expect(thread.rootMessage.text, '첫 번째');
    expect(thread.rootMessage.author.name, '서연');
    expect(_replyTexts(bloc), ['첫 번째 답글', '두 번째 답글']);
    expect([for (final r in thread.replies) r.author.name], ['도윤', '민재']);
    expect(socket.joinedChannels, {10});
    expect(
      gateway.calls,
      containsAll([
        'GET /channel/channels/10',
        'GET /chat/chat/channels/10/messages?around=m1',
        'GET /chat/chat/channels/10/messages?parentMessageId=m1',
      ]),
    );
  });

  test('답글이 없어도 부모 메시지는 보여 준다', () async {
    final bloc = await _loaded(FakeMessageGateway(), FakeChatSocket());
    addTearDown(bloc.close);

    expect(_data(bloc).rootMessage.text, '첫 번째');
    expect(_data(bloc).replies, isEmpty);
  });

  test('답글은 부모 메시지 id 와 함께 보내고, 소켓으로 저장돼 오면 한 번만 보여 준다', () async {
    final gateway = _gateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    bloc.add(const ThreadEvent.replySent('  새 답글  '));
    await pumpEventQueue();

    final sent = gateway.bodies['POST /chat/chat/channels/10/messages']!;
    expect(sent['content'], '새 답글');
    expect(sent['parentMessageId'], 'm1');
    // 서버가 큐에 넣고 돌아오므로 소켓으로 올 때까지는 목록에 없다.
    expect(_replyTexts(bloc), ['첫 번째 답글', '두 번째 답글']);

    socket.push(
      'message',
      _reply(
        'r3',
        1,
        '새 답글',
        clientMessageId: sent['clientMessageId'] as String,
      ),
    );
    await pumpEventQueue();

    expect(_replyTexts(bloc), ['첫 번째 답글', '두 번째 답글', '새 답글']);
    expect(_data(bloc).replies.last.id, 'r3');
    expect(_data(bloc).replies.last.author.name, '나');
  });

  test('같은 답글이 소켓으로 두 번 와도 한 번만 남긴다', () async {
    final socket = FakeChatSocket();
    final bloc = await _loaded(_gateway(), socket);
    addTearDown(bloc.close);

    socket
      ..push('message', _reply('r3', 2, '중복'))
      ..push('message', _reply('r3', 2, '중복'));
    await pumpEventQueue();

    expect(_replyTexts(bloc).where((t) => t == '중복'), hasLength(1));
  });

  test('전송이 실패하면 사유를 싣고 목록은 그대로 둔다', () async {
    final gateway = _gateway();
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);
    gateway.failing = 'POST /chat/chat/channels/10/messages';

    bloc.add(const ThreadEvent.replySent('실패할 답글'));
    await pumpEventQueue();

    expect(_conversation(bloc).errorMessage, isNotNull);
    expect(_replyTexts(bloc), ['첫 번째 답글', '두 번째 답글']);
  });

  test('공백뿐인 답글은 보내지 않는다', () async {
    final gateway = _gateway();
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);

    bloc.add(const ThreadEvent.replySent('   '));
    await pumpEventQueue();

    expect(gateway.calls, isEmpty);
  });

  test('모르는 사람의 새 답글은 이름을 받아 와 바꾼다', () async {
    final gateway = _gateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    socket.push('message', _reply('r3', 1, '새 답글'));
    await pumpEventQueue();

    expect(_data(bloc).replies.last.author.name, '나');
    expect(gateway.calls, contains('GET /user/users/batch?ids=1'));
  });

  test('다른 스레드·다른 채널·최상위 메시지는 넣지 않는다', () async {
    final socket = FakeChatSocket();
    final bloc = await _loaded(_gateway(), socket);
    addTearDown(bloc.close);

    socket
      ..push('message', _reply('x1', 2, '다른 스레드', parentMessageId: 'm2'))
      ..push('message', _reply('x2', 2, '다른 채널', channelId: 11))
      ..push('message', _reply('x3', 2, '최상위', parentMessageId: null));
    await pumpEventQueue();

    expect(_replyTexts(bloc), ['첫 번째 답글', '두 번째 답글']);
  });

  test('답글과 부모 메시지의 수정, 답글의 삭제를 반영한다', () async {
    final socket = FakeChatSocket();
    final bloc = await _loaded(_gateway(), socket);
    addTearDown(bloc.close);

    socket
      ..push('message:edited', {'messageId': 'r1', 'content': '고친 답글'})
      ..push('message:edited', {'messageId': 'm1', 'content': '고친 부모'})
      ..push('message:deleted', {'messageId': 'r2'});
    await pumpEventQueue();

    expect(_replyTexts(bloc), ['고친 답글']);
    expect(_data(bloc).rootMessage.text, '고친 부모');
  });

  test('부모 메시지가 지워지면 실패 상태가 된다', () async {
    final socket = FakeChatSocket();
    final bloc = await _loaded(_gateway(), socket);
    addTearDown(bloc.close);

    socket.push('message:deleted', {'messageId': 'm1'});
    await pumpEventQueue();

    expect(
      bloc.state,
      const AsyncFailure<ThreadConversation>('원본 메시지가 삭제됐어요.'),
    );
  });

  test('보낸 답글이 소켓으로 오지 않으면 다시 읽고, 없으면 알린다', () async {
    final gateway = _gateway();
    final bloc = await _loaded(
      gateway,
      FakeChatSocket(),
      confirmTimeout: const Duration(milliseconds: 10),
    );
    addTearDown(bloc.close);

    bloc.add(const ThreadEvent.replySent('사라진 답글'));
    await bloc.stream.firstWhere(
      (s) =>
          s is AsyncSuccess<ThreadConversation> && s.data.errorMessage != null,
    );

    expect(
      gateway.calls.last,
      'GET /chat/chat/channels/10/messages?parentMessageId=m1',
    );
    expect(_replyTexts(bloc), ['첫 번째 답글', '두 번째 답글']);
  });

  test('보낸 답글이 소켓 대신 다시 읽은 목록에 있으면 알리지 않는다', () async {
    final gateway = _gateway();
    final bloc = await _loaded(
      gateway,
      FakeChatSocket(),
      confirmTimeout: const Duration(milliseconds: 50),
    );
    addTearDown(bloc.close);

    bloc.add(const ThreadEvent.replySent('늦게 온 답글'));
    await pumpEventQueue();
    final id =
        gateway.bodies['POST /chat/chat/channels/10/messages']!['clientMessageId']
            as String;
    gateway.replies.insert(0, _reply('r3', 1, '늦게 온 답글', clientMessageId: id));

    await bloc.stream.firstWhere(
      (s) =>
          s is AsyncSuccess<ThreadConversation> &&
          s.data.thread.replies.any((r) => r.text == '늦게 온 답글'),
    );

    expect(_conversation(bloc).errorMessage, isNull);
  });

  test('소켓이 끊김 복구 없이 다시 붙으면 답글을 다시 읽는다', () async {
    final gateway = _gateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);
    gateway.replies.insert(0, _reply('r3', 2, '끊긴 사이 온 답글'));

    socket.reconnect();
    await bloc.stream.firstWhere(
      (s) =>
          s is AsyncSuccess<ThreadConversation> &&
          s.data.thread.replies.any((r) => r.text == '끊긴 사이 온 답글'),
    );

    expect(_replyTexts(bloc), ['첫 번째 답글', '두 번째 답글', '끊긴 사이 온 답글']);
  });

  test('불러오기가 실패하면 실패 상태가 된다', () async {
    final gateway = _gateway()..failing = 'GET /channel/channels/10';
    final bloc = _bloc(gateway, FakeChatSocket())
      ..add(const ThreadEvent.requested());
    addTearDown(bloc.close);

    await bloc.stream.firstWhere((s) => s is AsyncFailure<ThreadConversation>);
  });

  test('닫으면 채널 방에서 나간다', () async {
    final socket = FakeChatSocket();
    final bloc = await _loaded(_gateway(), socket);

    await bloc.close();

    expect(socket.joinedChannels, isEmpty);
  });
}
