import 'dart:async';

import 'package:cowork_app/feature/channel/domain/enums/channel_type.dart';
import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:cowork_app/feature/chat/domain/chat_upload.dart';
import 'package:cowork_app/feature/chat/presentation/blocs/channel_message/channel_message_bloc.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../channel/chat_test_server.dart';
import 'channel_message_test_server.dart';

ChannelMessageBloc _bloc(
  FakeMessageGateway gateway,
  FakeChatSocket socket, {
  Stream<AppLifecycleState>? lifecycle,
  Duration confirmTimeout = const Duration(seconds: 10),
  Duration markReadRetryDelay = const Duration(seconds: 3),
  DateTime Function()? now,
  String? focusMessageId,
}) => ChannelMessageBloc(
  channelId: 10,
  focusMessageId: focusMessageId,
  channelRepository: ChannelRepository.withDio(messageDio(gateway, 'channel')),
  messageRepository: MessageRepository.withDio(
    chat: messageDio(gateway, 'chat'),
  ),
  fileRepository: chatFileRepositoryOf(gateway),
  profileRepository: ProfileRepository.withDio(messageDio(gateway, 'user')),
  socket: socket,
  lifecycle: lifecycle,
  confirmTimeout: confirmTimeout,
  markReadRetryDelay: markReadRetryDelay,
  now: now ?? DateTime.now,
);

/// 불러오기까지 마친 Bloc. 이후 요청만 보도록 불러오기 기록은 비운다.
Future<ChannelMessageBloc> _loaded(
  FakeMessageGateway gateway,
  FakeChatSocket socket, {
  Stream<AppLifecycleState>? lifecycle,
  Duration confirmTimeout = const Duration(seconds: 10),
}) async {
  final bloc = _bloc(
    gateway,
    socket,
    lifecycle: lifecycle,
    confirmTimeout: confirmTimeout,
  )..add(const ChannelMessageEvent.requested());
  await bloc.stream.firstWhere((s) => s is AsyncSuccess<ChannelConversation>);
  await pumpEventQueue();
  gateway.calls.clear();
  return bloc;
}

ChannelConversation _data(ChannelMessageBloc bloc) =>
    (bloc.state as AsyncSuccess<ChannelConversation>).data;

List<String> _texts(ChannelMessageBloc bloc) => [
  for (final message in _data(bloc).messages) message.text,
];

void main() {
  test('읽음 요청이 실패하면 새 메시지를 기다리지 않고 다시 보낸다', () async {
    final gateway = FakeMessageGateway()
      ..failing = 'POST /chat/chat/channels/10/read';
    final bloc = _bloc(
      gateway,
      FakeChatSocket(),
      markReadRetryDelay: const Duration(milliseconds: 300),
    )..add(const ChannelMessageEvent.requested());
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s is AsyncSuccess<ChannelConversation>);
    await pumpEventQueue();
    expect(
      gateway.calls.where((c) => c == 'POST /chat/chat/channels/10/read'),
      hasLength(1),
    );

    gateway.failing = null;
    await Future<void>.delayed(const Duration(milliseconds: 600));

    expect(
      gateway.calls.where((c) => c == 'POST /chat/chat/channels/10/read'),
      hasLength(2),
    );
  });

  test('읽음이 한 번 성공하면 재시도 횟수를 처음으로 돌린다', () async {
    const read = 'POST /chat/chat/channels/10/read';
    final gateway = FakeMessageGateway()..failing = read;
    final socket = FakeChatSocket();
    final bloc = _bloc(
      gateway,
      socket,
      markReadRetryDelay: const Duration(milliseconds: 5),
    )..add(const ChannelMessageEvent.requested());
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s is AsyncSuccess<ChannelConversation>);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // 처음 한 번과 다시 보내기 세 번을 다 썼다.
    expect(gateway.calls.where((c) => c == read), hasLength(4));

    gateway.failing = null;
    socket.push('message', messageJson('m3', 2, '새 메시지'));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(gateway.calls.where((c) => c == read), hasLength(5));

    gateway.failing = read;
    socket.push('message', messageJson('m4', 2, '또 새 메시지'));
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // 성공하면서 횟수가 돌아와, 이번에도 처음 한 번과 다시 보내기 세 번을 쓴다.
    expect(gateway.calls.where((c) => c == read), hasLength(9));
  });

  test('읽음 요청이 계속 실패하면 세 번까지만 다시 보낸다', () async {
    final gateway = FakeMessageGateway()
      ..failing = 'POST /chat/chat/channels/10/read';
    final bloc = _bloc(
      gateway,
      FakeChatSocket(),
      markReadRetryDelay: const Duration(milliseconds: 5),
    )..add(const ChannelMessageEvent.requested());
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s is AsyncSuccess<ChannelConversation>);
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // 처음 한 번과 다시 보내기 세 번.
    expect(
      gateway.calls.where((c) => c == 'POST /chat/chat/channels/10/read'),
      hasLength(4),
    );
  });

  test('채널 머리와 메시지를 오래된 순으로 작성자 이름과 함께 보여 준다', () async {
    final gateway = FakeMessageGateway();
    final socket = FakeChatSocket();
    final bloc = _bloc(gateway, socket)
      ..add(const ChannelMessageEvent.requested());
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s is AsyncSuccess<ChannelConversation>);
    await pumpEventQueue();

    final data = _data(bloc);
    expect(data.name, '백엔드');
    expect(data.description, 'API 논의');
    expect(_texts(bloc), ['첫 번째', '두 번째']);
    expect([for (final m in data.messages) m.author.name], ['서연', '도윤']);
    expect(data.hasOlder, isFalse);
    expect(socket.joinedChannels, {10});
    expect(gateway.calls, contains('GET /user/users/batch?ids=2%2C3'));
    expect(gateway.bodies['POST /chat/chat/channels/10/read'], {
      'lastReadMessageId': 'm2',
    });
  });

  test('보낸 메시지를 먼저 보여 주고 소켓으로 저장되면 한 번만 남긴다', () async {
    final gateway = FakeMessageGateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    bloc.add(const ChannelMessageEvent.sent('  안녕하세요  '));
    await pumpEventQueue();

    expect(_texts(bloc), ['첫 번째', '두 번째', '안녕하세요']);
    expect(_data(bloc).messages.last.author.name, '나');
    final sent = gateway.bodies['POST /chat/chat/channels/10/messages']!;
    expect(sent['content'], '안녕하세요');

    socket.push(
      'message',
      messageJson(
        'm3',
        1,
        '안녕하세요',
        clientMessageId: sent['clientMessageId'] as String,
      ),
    );
    await pumpEventQueue();

    expect(_texts(bloc), ['첫 번째', '두 번째', '안녕하세요']);
    expect(_data(bloc).messages.last.id, 'm3');
  });

  test('보낸 메시지가 저장되면 그사이 온 다른 사람 메시지와 서버 시각 순서로 맞춘다', () async {
    final gateway = FakeMessageGateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    bloc.add(const ChannelMessageEvent.sent('내 글'));
    await pumpEventQueue();
    final sent = gateway.bodies['POST /chat/chat/channels/10/messages']!;
    // 서버에서는 다른 사람 메시지(05:00:02)가 내 글(05:00:05)보다 먼저 저장됐다.
    socket.push(
      'message',
      messageJson('m3', 2, '먼저 저장된 글', createdAt: '2026-10-23T05:00:02.000Z'),
    );
    await pumpEventQueue();
    expect(_texts(bloc), ['첫 번째', '두 번째', '내 글', '먼저 저장된 글']);

    socket.push(
      'message',
      messageJson(
        'm4',
        1,
        '내 글',
        clientMessageId: sent['clientMessageId'] as String,
        createdAt: '2026-10-23T05:00:05.000Z',
      ),
    );
    await pumpEventQueue();

    expect(_texts(bloc), ['첫 번째', '두 번째', '먼저 저장된 글', '내 글']);
    expect(_data(bloc).messages.last.id, 'm4');
  });

  test('보낸 메시지가 저장돼도 아직 확인 안 된 다른 보낸 메시지는 맨 뒤에 둔다', () async {
    final gateway = FakeMessageGateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    bloc.add(const ChannelMessageEvent.sent('글1'));
    await pumpEventQueue();
    final first =
        gateway.bodies['POST /chat/chat/channels/10/messages']!['clientMessageId']
            as String;
    bloc.add(const ChannelMessageEvent.sent('글2'));
    await pumpEventQueue();
    // 서버에서는 다른 사람 메시지가 글1보다 먼저 저장됐다.
    socket.push(
      'message',
      messageJson('m3', 2, '먼저 저장된 글', createdAt: '2026-10-23T05:00:02.000Z'),
    );
    await pumpEventQueue();
    expect(_texts(bloc), ['첫 번째', '두 번째', '글1', '글2', '먼저 저장된 글']);

    socket.push(
      'message',
      messageJson(
        'm4',
        1,
        '글1',
        clientMessageId: first,
        createdAt: '2026-10-23T05:00:05.000Z',
      ),
    );
    await pumpEventQueue();

    expect(_texts(bloc), ['첫 번째', '두 번째', '먼저 저장된 글', '글1', '글2']);
  });

  test('시각이 같아도 서버 목록처럼 id 순서로 자리를 정한다', () async {
    final gateway = FakeMessageGateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    bloc.add(const ChannelMessageEvent.sent('내 글'));
    await pumpEventQueue();
    final sent = gateway.bodies['POST /chat/chat/channels/10/messages']!;
    socket.push(
      'message',
      messageJson('m5', 2, '나중 id', createdAt: '2026-10-23T05:00:05.000Z'),
    );
    await pumpEventQueue();

    socket.push(
      'message',
      messageJson(
        'm4',
        1,
        '내 글',
        clientMessageId: sent['clientMessageId'] as String,
        createdAt: '2026-10-23T05:00:05.000Z',
      ),
    );
    await pumpEventQueue();

    expect(_texts(bloc), ['첫 번째', '두 번째', '내 글', '나중 id']);
  });

  test('자정이 지나면 오늘·어제 표기를 다시 만든다', () async {
    final start = DateTime(2026, 10, 23, 23, 59, 59, 900);
    final elapsed = Stopwatch()..start();
    final gateway = FakeMessageGateway(
      messages: [
        messageJson(
          'm1',
          2,
          '낮에 쓴 글',
          createdAt: DateTime(2026, 10, 23, 12).toUtc().toIso8601String(),
        ),
      ],
    );
    final bloc = _bloc(
      gateway,
      FakeChatSocket(),
      now: () => start.add(elapsed.elapsed),
    )..add(const ChannelMessageEvent.requested());
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s is AsyncSuccess<ChannelConversation>);
    expect(_data(bloc).messages.single.timestamp, startsWith('오늘'));

    await bloc.stream.firstWhere(
      (s) =>
          s is AsyncSuccess<ChannelConversation> &&
          s.data.messages.single.timestamp.startsWith('어제'),
    );

    expect(_data(bloc).messages.single.timestamp, startsWith('어제'));
  });

  test('전송이 실패하면 보낸 메시지를 빼고 사유를 싣는다', () async {
    final gateway = FakeMessageGateway()
      ..failing = 'POST /chat/chat/channels/10/messages';
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);

    bloc.add(const ChannelMessageEvent.sent('실패할 메시지'));
    await pumpEventQueue();

    expect(_texts(bloc), ['첫 번째', '두 번째']);
    expect(_data(bloc).errorMessage, isNotNull);
  });

  test('모르는 사람의 새 메시지는 이름을 받아 와 바꾼다', () async {
    final gateway = FakeMessageGateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    socket.push('message', messageJson('m3', 4, '새 메시지'));
    await pumpEventQueue();

    expect(_texts(bloc).last, '새 메시지');
    expect(_data(bloc).messages.last.author.name, '민재');
    expect(gateway.calls, contains('GET /user/users/batch?ids=4'));
  });

  test('다른 채널 메시지와 스레드 답글은 넣지 않는다', () async {
    final socket = FakeChatSocket();
    final bloc = await _loaded(FakeMessageGateway(), socket);
    addTearDown(bloc.close);

    socket
      ..push('message', messageJson('x1', 2, '다른 채널', channelId: 11))
      ..push('message', {
        ...messageJson('x2', 2, '답글'),
        'parentMessageId': 'm1',
      });
    await pumpEventQueue();

    expect(_texts(bloc), ['첫 번째', '두 번째']);
  });

  test('수정·삭제 이벤트를 반영한다', () async {
    final socket = FakeChatSocket();
    final bloc = await _loaded(FakeMessageGateway(), socket);
    addTearDown(bloc.close);

    socket
      ..push('message:edited', {'messageId': 'm1', 'content': '고친 내용'})
      ..push('message:deleted', {'messageId': 'm2'});
    await pumpEventQueue();

    expect(_texts(bloc), ['고친 내용']);
  });

  test('한 페이지가 꽉 차면 가장 오래된 메시지 이전을 이어 붙인다', () async {
    final gateway = FakeMessageGateway(
      messages: [for (var i = 150; i > 0; i--) messageJson('m$i', 2, '메시지 $i')],
    );
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);
    expect(_data(bloc).hasOlder, isTrue);
    expect(_texts(bloc).first, '메시지 51');

    bloc.add(const ChannelMessageEvent.olderRequested());
    await bloc.stream.firstWhere(
      (s) => s is AsyncSuccess<ChannelConversation> && !s.data.loadingOlder,
    );

    expect(
      gateway.calls,
      contains('GET /chat/chat/channels/10/messages?before=m51'),
    );
    expect(_data(bloc).messages, hasLength(150));
    expect(_texts(bloc).first, '메시지 1');
    expect(_data(bloc).hasOlder, isFalse);
  });

  test('이전 메시지를 읽는 중에 또 요청해도 한 번만 읽는다', () async {
    final gateway = FakeMessageGateway(
      messages: [for (var i = 150; i > 0; i--) messageJson('m$i', 2, '메시지 $i')],
    );
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);

    bloc
      ..add(const ChannelMessageEvent.olderRequested())
      ..add(const ChannelMessageEvent.olderRequested());
    await bloc.stream.firstWhere(
      (s) => s is AsyncSuccess<ChannelConversation> && !s.data.loadingOlder,
    );
    await pumpEventQueue();

    expect(gateway.calls.where((c) => c.contains('before=')), [
      'GET /chat/chat/channels/10/messages?before=m51',
    ]);
  });

  test('닫으면 채널 방에서 나간다', () async {
    final socket = FakeChatSocket();
    final bloc = await _loaded(FakeMessageGateway(), socket);

    await bloc.close();

    expect(socket.joinedChannels, isEmpty);
  });

  test('불러오기가 실패하면 실패 상태가 된다', () async {
    final gateway = FakeMessageGateway()
      ..failing = 'GET /chat/chat/channels/10/messages';
    final bloc = _bloc(gateway, FakeChatSocket())
      ..add(const ChannelMessageEvent.requested());
    addTearDown(bloc.close);

    await bloc.stream.firstWhere((s) => s is AsyncFailure<ChannelConversation>);
  });

  test('보낸 메시지가 소켓으로 오지 않으면 다시 읽고, 없으면 빼고 알린다', () async {
    final gateway = FakeMessageGateway();
    final bloc = await _loaded(
      gateway,
      FakeChatSocket(),
      confirmTimeout: const Duration(milliseconds: 10),
    );
    addTearDown(bloc.close);

    bloc.add(const ChannelMessageEvent.sent('사라진 메시지'));
    await bloc.stream.firstWhere(
      (s) =>
          s is AsyncSuccess<ChannelConversation> && s.data.errorMessage != null,
    );

    expect(gateway.calls.last, 'GET /chat/chat/channels/10/messages');
    expect(_texts(bloc), ['첫 번째', '두 번째']);
  });

  test('보낸 메시지가 소켓 대신 다시 읽은 목록에 있으면 그대로 둔다', () async {
    final gateway = FakeMessageGateway();
    final bloc = await _loaded(
      gateway,
      FakeChatSocket(),
      confirmTimeout: const Duration(milliseconds: 10),
    );
    addTearDown(bloc.close);

    bloc.add(const ChannelMessageEvent.sent('저장된 메시지'));
    await pumpEventQueue();
    final sent = gateway.bodies['POST /chat/chat/channels/10/messages']!;
    gateway.messages.insert(
      0,
      messageJson(
        'm3',
        1,
        '저장된 메시지',
        clientMessageId: sent['clientMessageId'] as String,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(_texts(bloc), ['첫 번째', '두 번째', '저장된 메시지']);
    expect(_data(bloc).messages.last.id, 'm3');
    expect(_data(bloc).errorMessage, isNull);
  });

  test('소켓이 복구 없이 다시 붙으면 최근 메시지를 다시 읽어 맞춘다', () async {
    final gateway = FakeMessageGateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    gateway.messages
      ..removeWhere((m) => m['_id'] == 'm1')
      ..insert(0, messageJson('m3', 2, '끊긴 동안 온 메시지'));
    socket.reconnect();
    await pumpEventQueue();

    expect(_texts(bloc), ['두 번째', '끊긴 동안 온 메시지']);
    expect(gateway.bodies['POST /chat/chat/channels/10/read'], {
      'lastReadMessageId': 'm3',
    });
  });

  test('백그라운드에서 받은 메시지는 돌아왔을 때 읽음으로 알린다', () async {
    final gateway = FakeMessageGateway();
    final socket = FakeChatSocket();
    final lifecycle = StreamController<AppLifecycleState>();
    addTearDown(lifecycle.close);
    final bloc = await _loaded(gateway, socket, lifecycle: lifecycle.stream);
    addTearDown(bloc.close);

    lifecycle.add(AppLifecycleState.paused);
    await pumpEventQueue();
    socket.push('message', messageJson('m3', 2, '자리 비운 사이'));
    await pumpEventQueue();
    expect(gateway.calls, isNot(contains('POST /chat/chat/channels/10/read')));

    lifecycle.add(AppLifecycleState.resumed);
    await pumpEventQueue();
    expect(gateway.bodies['POST /chat/chat/channels/10/read'], {
      'lastReadMessageId': 'm3',
    });
  });

  test('시스템 메시지는 이름을 찾지 않고 시스템으로 보인다', () async {
    final gateway = FakeMessageGateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    socket.push('message', messageJson('m3', 0, '이슈를 만들었어요', type: 'SYSTEM'));
    await pumpEventQueue();

    expect(_data(bloc).messages.last.author.name, '시스템');
    expect(gateway.calls, isNot(contains(startsWith('GET /user/users/batch'))));
  });

  test('작성자 id 없이 온 웹훅 메시지는 웹훅 이름으로 보이고 사람 이름을 찾지 않는다', () async {
    final gateway = FakeMessageGateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    socket.push('message', {
      ...messageJson('m3', 0, 'main 에 커밋 3개를 푸시했어요'),
      'authorId': null,
      'webhook': {'id': 2, 'name': 'github-webhook', 'avatarUrl': null},
    });
    await pumpEventQueue();

    final message = _data(bloc).messages.last;
    expect(message.text, 'main 에 커밋 3개를 푸시했어요');
    expect(message.author.name, 'github-webhook');
    expect(message.editable, isFalse);
    expect(gateway.calls, isNot(contains(startsWith('GET /user/users/batch'))));
  });

  test('메시지를 보여 주지 않는 종류의 채널은 열거나 새 메시지가 와도 읽음으로 알리지 않는다', () async {
    const read = 'POST /chat/chat/channels/10/read';
    final gateway = FakeMessageGateway();
    gateway.channel['viewType'] = 'FILE_SHARE';
    final socket = FakeChatSocket();
    final bloc = _bloc(gateway, socket)
      ..add(const ChannelMessageEvent.requested());
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s is AsyncSuccess<ChannelConversation>);
    await pumpEventQueue();

    expect(_data(bloc).type, ChannelType.file);
    expect(gateway.calls, isNot(contains(read)));

    socket.push('message', messageJson('m3', 2, '파일을 올렸어요'));
    await pumpEventQueue();

    expect(gateway.calls, isNot(contains(read)));
  });

  test('웹훅 채널은 열면 읽음으로 알린다', () async {
    const read = 'POST /chat/chat/channels/10/read';
    final gateway = FakeMessageGateway();
    gateway.channel['viewType'] = 'WEBHOOK';
    final bloc = _bloc(gateway, FakeChatSocket())
      ..add(const ChannelMessageEvent.requested());
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s is AsyncSuccess<ChannelConversation>);
    await pumpEventQueue();

    expect(gateway.calls, contains(read));
  });

  test('다시 읽는 사이 소켓으로 온 더 최근 메시지는 잃지 않는다', () async {
    final gateway = FakeMessageGateway();
    final socket = FakeChatSocket();
    final bloc = await _loaded(gateway, socket);
    addTearDown(bloc.close);

    final gate = Completer<void>();
    gateway.listGate = gate.future;
    socket.reconnect();
    await pumpEventQueue();
    socket.push(
      'message',
      messageJson(
        'm3',
        2,
        '읽는 사이 온 메시지',
        createdAt: '2026-10-23T05:01:00.000Z',
      ),
    );
    await pumpEventQueue();
    gate.complete();
    await pumpEventQueue();

    expect(_texts(bloc), ['첫 번째', '두 번째', '읽는 사이 온 메시지']);
  });

  test('내가 쓴 저장된 메시지만 고칠 수 있다', () async {
    final gateway = FakeMessageGateway(
      messages: [messageJson('m2', 1, '내 메시지'), messageJson('m1', 2, '남의 메시지')],
    );
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);

    bloc.add(const ChannelMessageEvent.sent('보내는 중'));
    await pumpEventQueue();

    expect(
      [for (final m in _data(bloc).messages) m.editable],
      [false, true, false],
    );
  });

  test('내 메시지를 고치면 서버가 받아들인 뒤 바꿔 보인다', () async {
    final gateway = FakeMessageGateway(messages: [messageJson('m1', 1, '오타')]);
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);

    bloc.add(const ChannelMessageEvent.edited('m1', ' 고친 내용 '));
    await pumpEventQueue();

    expect(gateway.bodies['PATCH /chat/chat/channels/10/messages/m1'], {
      'content': '고친 내용',
    });
    expect(_texts(bloc), ['고친 내용']);
  });

  test('수정이 실패하면 그대로 두고 사유를 싣는다', () async {
    final gateway = FakeMessageGateway(messages: [messageJson('m1', 1, '오타')])
      ..failing = 'PATCH /chat/chat/channels/10/messages/m1';
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);

    bloc.add(const ChannelMessageEvent.edited('m1', '고친 내용'));
    await pumpEventQueue();

    expect(_texts(bloc), ['오타']);
    expect(_data(bloc).errorMessage, isNotNull);
  });

  test('내 메시지를 지우면 서버가 받아들인 뒤 뺀다', () async {
    final gateway = FakeMessageGateway(
      messages: [
        messageJson('m2', 1, '지울 메시지'),
        messageJson('m1', 2, '남길 메시지'),
      ],
    );
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);

    bloc.add(const ChannelMessageEvent.deleted('m2'));
    await pumpEventQueue();

    expect(gateway.calls, ['DELETE /chat/chat/channels/10/messages/m2']);
    expect(_texts(bloc), ['남길 메시지']);
  });

  test('삭제가 실패하면 그대로 두고 사유를 싣는다', () async {
    final gateway = FakeMessageGateway(
      messages: [messageJson('m1', 1, '지울 메시지')],
    )..failing = 'DELETE /chat/chat/channels/10/messages/m1';
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);

    bloc.add(const ChannelMessageEvent.deleted('m1'));
    await pumpEventQueue();

    expect(_texts(bloc), ['지울 메시지']);
    expect(_data(bloc).errorMessage, isNotNull);
  });

  test('파일 메시지는 첨부파일을 함께 싣는다', () async {
    final gateway = FakeMessageGateway(
      messages: [
        {
          ...messageJson('m1', 2, '', type: 'FILE'),
          'attachments': [
            {
              'name': '기획서.pdf',
              'objectKey': 'k',
              'size': 2048,
              'mimeType': 'application/pdf',
            },
          ],
        },
      ],
    );
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);

    final message = _data(bloc).messages.single;
    expect(message.text, isEmpty);
    expect(message.attachments.single.name, '기획서.pdf');
    expect(message.attachments.single.size, 2048);
  });

  test('같은 사유로 연달아 실패해도 매번 알린다', () async {
    final gateway = FakeMessageGateway(
      messages: [messageJson('m1', 1, '지울 메시지')],
    )..failing = 'DELETE /chat/chat/channels/10/messages/m1';
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);
    final errors = <String>[];
    final subscription = bloc.stream.listen((state) {
      if (state case AsyncSuccess(:final data) when data.errorMessage != null) {
        errors.add(data.errorMessage!);
      }
    });
    addTearDown(subscription.cancel);

    bloc.add(const ChannelMessageEvent.deleted('m1'));
    await pumpEventQueue();
    bloc.add(const ChannelMessageEvent.deleted('m1'));
    await pumpEventQueue();

    expect(errors, hasLength(2));
  });

  test('내 정보 조회가 실패해도 대화는 보여 주고, 보낼 때 다시 읽는다', () async {
    final gateway = FakeMessageGateway(
      messages: [messageJson('m2', 1, '내 메시지'), messageJson('m1', 2, '남의 메시지')],
    )..failing = 'GET /user/users/me';
    final bloc = await _loaded(gateway, FakeChatSocket());
    addTearDown(bloc.close);

    expect(_texts(bloc), ['남의 메시지', '내 메시지']);
    expect(_data(bloc).messages.last.author.name, '나');
    expect([for (final m in _data(bloc).messages) m.editable], [false, false]);

    bloc.add(const ChannelMessageEvent.sent('아직 못 보냄'));
    await pumpEventQueue();
    expect(gateway.calls, contains('GET /user/users/me'));
    expect(_data(bloc).errorMessage, isNotNull);
    expect(_texts(bloc), ['남의 메시지', '내 메시지']);

    gateway.failing = null;
    bloc.add(const ChannelMessageEvent.sent('이제 보냄'));
    await pumpEventQueue();
    expect(
      gateway.bodies['POST /chat/chat/channels/10/messages']?['content'],
      '이제 보냄',
    );
    expect(_texts(bloc), ['남의 메시지', '내 메시지', '이제 보냄']);
    expect(_data(bloc).messages[1].editable, isTrue);
  });

  group('채널을 더 볼 수 없게 되면', () {
    Future<String?> closedReasonAfter(
      String name,
      Map<String, dynamic> data,
    ) async {
      final socket = FakeChatSocket();
      final bloc = await _loaded(FakeMessageGateway(), socket);
      addTearDown(bloc.close);

      socket.push(name, data);
      await pumpEventQueue();

      return _data(bloc).closedReason;
    }

    test('보고 있는 채널이 지워지면 닫힘 사유를 싣는다', () async {
      expect(
        await closedReasonAfter('channel:deleted', {
          'channelId': 10,
          'teamId': 1,
        }),
        '채널이 삭제됐어요.',
      );
    });

    test('보고 있는 채널 권한이 사라지면 닫힘 사유를 싣는다', () async {
      expect(
        await closedReasonAfter('channel:access:revoked', {'channelId': 10}),
        '이 채널에 더 이상 접근할 수 없어요.',
      );
    });

    test('이 채널의 팀에서 빠지면 닫힘 사유를 싣는다', () async {
      expect(
        await closedReasonAfter('team:access:revoked', {'teamId': 1}),
        '팀에서 빠져서 이 채널을 볼 수 없어요.',
      );
    });

    test('다른 채널·팀 이야기면 그대로 둔다', () async {
      expect(
        await closedReasonAfter('channel:deleted', {
          'channelId': 11,
          'teamId': 1,
        }),
        isNull,
      );
      expect(
        await closedReasonAfter('team:access:revoked', {'teamId': 2}),
        isNull,
      );
    });

    test('불러오는 중에 온 것도 다 불러온 뒤 반영한다', () async {
      final socket = FakeChatSocket();
      final gateway = FakeMessageGateway();
      final gate = Completer<void>();
      gateway.listGate = gate.future;
      final bloc = _bloc(gateway, socket)
        ..add(const ChannelMessageEvent.requested());
      addTearDown(bloc.close);
      await pumpEventQueue();

      socket.push('channel:access:revoked', {'channelId': 10});
      await pumpEventQueue();
      gate.complete();
      await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelConversation>,
      );

      expect(_data(bloc).closedReason, '이 채널에 더 이상 접근할 수 없어요.');
    });

    test('닫힌 뒤에 온 메시지는 반영하지 않는다', () async {
      final socket = FakeChatSocket();
      final bloc = await _loaded(FakeMessageGateway(), socket);
      addTearDown(bloc.close);

      socket
        ..push('channel:deleted', {'channelId': 10, 'teamId': 1})
        ..push('message', messageJson('m3', 2, '늦게 온 메시지'));
      await pumpEventQueue();

      expect(_texts(bloc), ['첫 번째', '두 번째']);
    });
  });

  group('검색한 메시지로 열면', () {
    /// m1(가장 오래됨) ~ m200(가장 최근). 서버처럼 최신순이다.
    FakeMessageGateway twoHundred() => FakeMessageGateway(
      messages: [for (var i = 200; i > 0; i--) messageJson('m$i', 2, '메시지 $i')],
    );

    Future<ChannelMessageBloc> focused(
      FakeMessageGateway gateway,
      FakeChatSocket socket,
      String messageId,
    ) async {
      final bloc = _bloc(gateway, socket, focusMessageId: messageId)
        ..add(const ChannelMessageEvent.requested());
      await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelConversation>,
      );
      await pumpEventQueue();
      return bloc;
    }

    Future<void> loadNewer(ChannelMessageBloc bloc) async {
      bloc.add(const ChannelMessageEvent.newerRequested());
      await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelConversation> && !s.data.loadingNewer,
      );
      await pumpEventQueue();
    }

    test('그 메시지 앞뒤를 읽고, 최근 메시지가 남았으니 읽음은 알리지 않는다', () async {
      final gateway = twoHundred();
      final bloc = await focused(gateway, FakeChatSocket(), 'm100');
      addTearDown(bloc.close);

      final data = _data(bloc);
      expect(
        gateway.calls,
        contains('GET /chat/chat/channels/10/messages?around=m100'),
      );
      expect(data.focusMessageId, 'm100');
      expect(_texts(bloc).first, '메시지 51');
      expect(_texts(bloc).last, '메시지 150');
      expect(data.hasOlder, isTrue);
      expect(data.hasNewer, isTrue);
      expect(
        gateway.calls,
        isNot(contains('POST /chat/chat/channels/10/read')),
      );
    });

    test('최근 쪽을 읽는 중에 또 요청해도 한 번만 읽는다', () async {
      final gateway = twoHundred();
      final bloc = await focused(gateway, FakeChatSocket(), 'm100');
      addTearDown(bloc.close);
      gateway.calls.clear();

      bloc
        ..add(const ChannelMessageEvent.newerRequested())
        ..add(const ChannelMessageEvent.newerRequested());
      await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelConversation> && !s.data.loadingNewer,
      );
      await pumpEventQueue();

      expect(gateway.calls.where((c) => c.contains('after=')), hasLength(1));
    });

    test('보내려고 최근 대화로 옮기는 동안에는 이후 메시지를 따로 읽지 않는다', () async {
      final gateway = twoHundred();
      final bloc = await focused(gateway, FakeChatSocket(), 'm100');
      addTearDown(bloc.close);
      gateway.calls.clear();

      bloc
        ..add(const ChannelMessageEvent.sent('안녕'))
        ..add(const ChannelMessageEvent.newerRequested());
      await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelConversation> && !s.data.hasNewer,
      );
      await pumpEventQueue();

      expect(gateway.calls.where((c) => c.contains('after=')), isEmpty);
    });

    test('최근 메시지 근처면 이후 메시지가 없다고 본다', () async {
      final bloc = await focused(twoHundred(), FakeChatSocket(), 'm190');
      addTearDown(bloc.close);

      expect(_data(bloc).hasNewer, isFalse);
      expect(_texts(bloc).last, '메시지 200');
    });

    test('이후 메시지를 이어 붙이고, 최근까지 오면 읽음을 알린다', () async {
      final gateway = twoHundred();
      final bloc = await focused(gateway, FakeChatSocket(), 'm30');
      addTearDown(bloc.close);
      expect(_texts(bloc).last, '메시지 80');

      await loadNewer(bloc);
      expect(
        gateway.calls,
        contains('GET /chat/chat/channels/10/messages?after=m80'),
      );
      expect(_texts(bloc).last, '메시지 180');
      expect(_data(bloc).hasNewer, isTrue);
      expect(
        gateway.calls,
        isNot(contains('POST /chat/chat/channels/10/read')),
      );

      await loadNewer(bloc);
      expect(_texts(bloc).last, '메시지 200');
      expect(_data(bloc).hasNewer, isFalse);
      expect(gateway.bodies['POST /chat/chat/channels/10/read'], {
        'lastReadMessageId': 'm200',
      });
    });

    test('과거 위치를 보는 중 소켓으로 온 새 메시지는 붙이지 않는다', () async {
      final socket = FakeChatSocket();
      final bloc = await focused(twoHundred(), socket, 'm100');
      addTearDown(bloc.close);

      socket.push('message', messageJson('m201', 2, '방금 온 메시지'));
      await pumpEventQueue();

      expect(_texts(bloc), isNot(contains('방금 온 메시지')));
      expect(_texts(bloc).last, '메시지 150');
    });

    test('이후 메시지를 읽는 사이 소켓으로 온 메시지도 최근까지 오면 붙인다', () async {
      final gateway = twoHundred();
      final socket = FakeChatSocket();
      final bloc = await focused(gateway, socket, 'm140');
      addTearDown(bloc.close);
      final gate = Completer<void>();
      gateway.listGate = gate.future;

      bloc.add(const ChannelMessageEvent.newerRequested());
      await pumpEventQueue();
      socket.push('message', messageJson('m201', 2, '방금 온 메시지'));
      await pumpEventQueue();
      gate.complete();
      await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelConversation> && !s.data.loadingNewer,
      );

      expect(_data(bloc).hasNewer, isFalse);
      expect(_texts(bloc).sublist(_texts(bloc).length - 2), [
        '메시지 200',
        '방금 온 메시지',
      ]);
    });

    test('이후 메시지를 읽는 사이 재연결되면 최근까지 온 뒤 끊긴 동안 온 메시지를 맞춘다', () async {
      final gateway = twoHundred();
      final socket = FakeChatSocket();
      final bloc = await focused(gateway, socket, 'm140');
      addTearDown(bloc.close);
      final gate = Completer<void>();
      gateway.cursorGates['after'] = gate.future;

      bloc.add(const ChannelMessageEvent.newerRequested());
      await pumpEventQueue();
      // 서버는 이미 m191~m200 으로 응답을 만들었다. 그 뒤 소켓이 끊긴 사이 저장된
      // 메시지라 소켓으로는 오지 않는다.
      gateway.messages.insert(0, messageJson('m201', 2, '끊긴 동안 온 메시지'));
      socket.reconnect();
      await pumpEventQueue();
      gate.complete();
      await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelConversation> && !s.data.loadingNewer,
      );

      expect(_data(bloc).hasNewer, isFalse);
      expect(_texts(bloc).sublist(_texts(bloc).length - 2), [
        '메시지 200',
        '끊긴 동안 온 메시지',
      ]);
    });

    test('보내면 최근 대화로 옮긴 뒤 보낸다', () async {
      final gateway = twoHundred();
      final bloc = await focused(gateway, FakeChatSocket(), 'm100');
      addTearDown(bloc.close);
      gateway.calls.clear();

      bloc.add(const ChannelMessageEvent.sent('답장'));
      await pumpEventQueue();

      final data = _data(bloc);
      expect(gateway.calls, contains('GET /chat/chat/channels/10/messages'));
      expect(data.focusMessageId, isNull);
      expect(data.hasNewer, isFalse);
      expect(_texts(bloc).sublist(_texts(bloc).length - 2), ['메시지 200', '답장']);
      expect(
        gateway.bodies['POST /chat/chat/channels/10/messages']!['content'],
        '답장',
      );
    });

    test('옮겨서 보내면 보내기가 실패해도 최근 메시지까지 읽었다고 알린다', () async {
      final gateway = twoHundred()
        ..failing = 'POST /chat/chat/channels/10/messages';
      final bloc = await focused(gateway, FakeChatSocket(), 'm100');
      addTearDown(bloc.close);

      bloc.add(const ChannelMessageEvent.sent('답장'));
      await pumpEventQueue();

      expect(_texts(bloc).last, '메시지 200');
      expect(gateway.bodies['POST /chat/chat/channels/10/read'], {
        'lastReadMessageId': 'm200',
      });
    });

    test('옮기는 사이 또 보내면 최근 대화는 한 번만 읽고 보낸 순서대로 붙인다', () async {
      final gateway = twoHundred();
      final bloc = await focused(gateway, FakeChatSocket(), 'm100');
      addTearDown(bloc.close);
      gateway.calls.clear();
      final gate = Completer<void>();
      gateway.listGate = gate.future;

      bloc
        ..add(const ChannelMessageEvent.sent('하나'))
        ..add(const ChannelMessageEvent.sent('둘'));
      await pumpEventQueue();
      gate.complete();
      await pumpEventQueue();

      expect(
        gateway.calls.where(
          (call) => call == 'GET /chat/chat/channels/10/messages',
        ),
        hasLength(1),
      );
      expect(_texts(bloc).sublist(_texts(bloc).length - 3), [
        '메시지 200',
        '하나',
        '둘',
      ]);
      expect(_data(bloc).loadingNewer, isFalse);
    });

    test('이후 메시지를 읽는 사이 보내면 늦게 온 이후 메시지는 버린다', () async {
      final gateway = twoHundred();
      final socket = FakeChatSocket();
      final bloc = await focused(gateway, socket, 'm30');
      addTearDown(bloc.close);
      final gate = Completer<void>();
      gateway.cursorGates['after'] = gate.future;

      bloc.add(const ChannelMessageEvent.newerRequested());
      await pumpEventQueue();
      bloc.add(const ChannelMessageEvent.sent('답장'));
      await pumpEventQueue();
      gate.complete();
      await pumpEventQueue();

      // after=m80 응답(m81~m180)이 최근 목록 뒤에 붙지 않는다.
      expect(_texts(bloc), isNot(contains('메시지 81')));
      expect(_texts(bloc).sublist(_texts(bloc).length - 2), ['메시지 200', '답장']);
      expect(_data(bloc).hasNewer, isFalse);
      expect(_data(bloc).loadingNewer, isFalse);

      // 최근 대화로 왔으니 소켓으로 온 새 메시지는 바로 붙는다.
      socket.push('message', messageJson('m201', 2, '방금 온 메시지'));
      await pumpEventQueue();
      expect(_texts(bloc).last, '방금 온 메시지');
    });

    test('이전 메시지를 읽는 사이 보내면 늦게 온 이전 메시지는 버린다', () async {
      final gateway = twoHundred();
      final bloc = await focused(gateway, FakeChatSocket(), 'm100');
      addTearDown(bloc.close);
      final gate = Completer<void>();
      gateway.cursorGates['before'] = gate.future;

      bloc.add(const ChannelMessageEvent.olderRequested());
      await pumpEventQueue();
      bloc.add(const ChannelMessageEvent.sent('답장'));
      await pumpEventQueue();
      gate.complete();
      await pumpEventQueue();

      // before=m51 응답(m1~m50)이 최근 목록(m101~) 위에 붙지 않는다.
      expect(_texts(bloc).first, '메시지 101');
      expect(_data(bloc).loadingOlder, isFalse);

      // 다음 이전 메시지 요청은 새 목록의 가장 오래된 메시지 기준이다.
      gateway.calls.clear();
      bloc.add(const ChannelMessageEvent.olderRequested());
      await pumpEventQueue();
      expect(
        gateway.calls,
        contains('GET /chat/chat/channels/10/messages?before=m101'),
      );
    });

    test('서버가 around 를 무시하면 받은 최근 메시지로 열고 알린다', () async {
      final gateway = twoHundred()..ignoredCursors = {'around'};
      final bloc = await focused(gateway, FakeChatSocket(), 'm10');
      addTearDown(bloc.close);

      final data = _data(bloc);
      expect(data.focusMessageId, isNull);
      expect(data.hasNewer, isFalse);
      expect(data.hasOlder, isTrue);
      expect(_texts(bloc).last, '메시지 200');
      expect(data.errorMessage, '메시지를 찾을 수 없어 최근 대화를 보여 드려요.');
      expect(gateway.bodies['POST /chat/chat/channels/10/read'], {
        'lastReadMessageId': 'm200',
      });
    });

    test('after 응답에 새 메시지가 없으면 더 부르지 않는다', () async {
      final gateway = twoHundred()..ignoredCursors = {'after'};
      final bloc = await focused(gateway, FakeChatSocket(), 'm100');
      addTearDown(bloc.close);

      // after 를 무시하니 최근 100개(m101~m200)가 온다. 처음엔 새 메시지가 붙는다.
      await loadNewer(bloc);
      expect(_texts(bloc).last, '메시지 200');
      // 다음 응답은 전부 이미 가진 메시지다. 여기서 멈춰야 한다.
      await loadNewer(bloc);
      expect(_data(bloc).hasNewer, isFalse);

      gateway.calls.clear();
      bloc.add(const ChannelMessageEvent.newerRequested());
      await pumpEventQueue();
      expect(gateway.calls, isEmpty);
    });

    test('그 메시지가 지워졌으면 최근 대화로 열고 알린다', () async {
      final gateway = twoHundred();
      final bloc = await focused(gateway, FakeChatSocket(), 'gone');
      addTearDown(bloc.close);

      final data = _data(bloc);
      expect(data.focusMessageId, isNull);
      expect(data.hasNewer, isFalse);
      expect(_texts(bloc).last, '메시지 200');
      expect(data.errorMessage, '메시지를 찾을 수 없어 최근 대화를 보여 드려요.');
    });
  });

  group('파일 보내기', () {
    const presign = 'POST /chat/chat/channels/10/files/presigned-url';
    const confirm = 'POST /chat/chat/channels/10/files/confirm';
    const send = 'POST /chat/chat/channels/10/messages';

    /// 업로드 주소 → PUT → 확인을 파일마다 거쳐 요청이 길게 이어지므로, 이벤트 큐를
    /// 기본(20번)보다 넉넉히 비운다.
    Future<void> settle() => pumpEventQueue(times: 200);

    /// 읽음 요청을 뺀 요청 기록.
    List<String> fileCalls(FakeMessageGateway gateway) => [
      for (final call in gateway.calls)
        if (!call.endsWith('/read')) call,
    ];

    test('먼저 보여 준 뒤 올리고 FILE 메시지로 보내며, 저장되면 서버 메시지로 바꾼다', () async {
      final gateway = FakeMessageGateway();
      final socket = FakeChatSocket();
      final bloc = await _loaded(gateway, socket);
      addTearDown(bloc.close);

      bloc.add(
        ChannelMessageEvent.sent(
          '',
          files: [
            uploadFileOf('자료.pdf', [1, 2, 3, 4]),
            uploadFileOf('사진.png'),
          ],
        ),
      );
      await settle();

      expect(fileCalls(gateway), [
        presign,
        'PUT /upload/tmp-1',
        confirm,
        presign,
        'PUT /upload/tmp-2',
        confirm,
        send,
      ]);
      expect(gateway.uploads['/upload/tmp-1'], [1, 2, 3, 4]);
      final pending = _data(bloc).messages.last;
      expect(pending.upload, const ChatUpload(progress: 1));
      expect(pending.attachments.map((a) => a.name), ['자료.pdf', '사진.png']);
      expect(pending.attachments.first.mimeType, 'application/pdf');
      expect(gateway.bodies[send], {
        'content': '',
        'clientMessageId': pending.id,
        'type': 'FILE',
        'attachments': [
          {'objectKey': 'chat-files/1'},
          {'objectKey': 'chat-files/2'},
        ],
      });

      socket.push('message', {
        ...messageJson('m9', 1, '', type: 'FILE', clientMessageId: pending.id),
        'attachments': [
          {'name': '자료.pdf', 'size': 4, 'mimeType': 'application/pdf'},
          {'name': '사진.png', 'size': 3, 'mimeType': 'image/png'},
        ],
      });
      await settle();

      final saved = _data(bloc).messages.last;
      expect(saved.id, 'm9');
      expect(saved.upload, isNull);
      expect(saved.attachments, hasLength(2));
    });

    test('올리다 실패하면 실패로 남기고, 다시 보내면 올린 파일은 건너뛰고 같은 id 로 보낸다', () async {
      final gateway = FakeMessageGateway()
        ..failingOnce.add('PUT /upload/tmp-2');
      final bloc = await _loaded(gateway, FakeChatSocket());
      addTearDown(bloc.close);

      bloc.add(
        ChannelMessageEvent.sent(
          '',
          files: [uploadFileOf('a.pdf'), uploadFileOf('b.pdf')],
        ),
      );
      await settle();

      final failed = _data(bloc).messages.last;
      expect(failed.upload?.failed, isTrue);
      expect(_data(bloc).errorMessage, isNotNull);
      expect(fileCalls(gateway), isNot(contains(send)));

      gateway.calls.clear();
      bloc.add(ChannelMessageEvent.retried(failed.id));
      await settle();

      // 첫 파일(tmp-1)은 이미 확정돼 다시 올리지 않는다.
      expect(fileCalls(gateway), [presign, 'PUT /upload/tmp-3', confirm, send]);
      expect(gateway.bodies[send], {
        'content': '',
        'clientMessageId': failed.id,
        'type': 'FILE',
        'attachments': [
          {'objectKey': 'chat-files/1'},
          {'objectKey': 'chat-files/3'},
        ],
      });
      expect(_data(bloc).messages.last.upload?.failed, isFalse);
    });

    test('글과 파일은 한 메시지로 보내고, 전송만 실패했으면 다시 보낼 때 파일은 다시 올리지 않는다', () async {
      final gateway = FakeMessageGateway()..failingOnce.add(send);
      final bloc = await _loaded(gateway, FakeChatSocket());
      addTearDown(bloc.close);

      bloc.add(
        ChannelMessageEvent.sent('  회의 자료예요 ', files: [uploadFileOf('a.pdf')]),
      );
      await settle();
      final failed = _data(bloc).messages.last;
      expect(failed.text, '회의 자료예요');
      expect(failed.upload?.failed, isTrue);

      gateway.calls.clear();
      bloc.add(ChannelMessageEvent.retried(failed.id));
      await settle();

      expect(fileCalls(gateway), [send]);
      expect(gateway.bodies[send], {
        'content': '회의 자료예요',
        'clientMessageId': failed.id,
        'type': 'FILE',
        'attachments': [
          {'objectKey': 'chat-files/1'},
        ],
      });
    });

    test('실패한 파일 메시지를 지우면 대화에서 빠진다', () async {
      final gateway = FakeMessageGateway()..failing = 'PUT /upload/tmp-1';
      final bloc = await _loaded(gateway, FakeChatSocket());
      addTearDown(bloc.close);

      bloc.add(ChannelMessageEvent.sent('', files: [uploadFileOf('a.pdf')]));
      await settle();
      bloc.add(ChannelMessageEvent.discarded(_data(bloc).messages.last.id));
      await settle();

      expect(_texts(bloc), ['첫 번째', '두 번째']);
    });

    test('보내는 중인 메시지는 지우거나 겹쳐 보내지 않는다', () async {
      final gate = Completer<void>();
      final gateway = FakeMessageGateway()..uploadGate = gate.future;
      final bloc = await _loaded(gateway, FakeChatSocket());
      addTearDown(bloc.close);

      bloc.add(ChannelMessageEvent.sent('', files: [uploadFileOf('a.pdf')]));
      await settle();
      final sending = _data(bloc).messages.last;
      expect(sending.upload?.failed, isFalse);

      bloc
        ..add(ChannelMessageEvent.discarded(sending.id))
        ..add(ChannelMessageEvent.retried(sending.id));
      await settle();
      gate.complete();
      await settle();

      expect(_data(bloc).messages.last.id, sending.id);
      expect(fileCalls(gateway).where((c) => c == presign), hasLength(1));
      expect(fileCalls(gateway).where((c) => c == send), hasLength(1));
    });

    test('대화에 올리면 accepted 가 true, 보내기 전에 멈추면 false 다', () async {
      final gateway = FakeMessageGateway()..failing = 'GET /user/users/me';
      final bloc = await _loaded(gateway, FakeChatSocket());
      addTearDown(bloc.close);

      // 내 정보를 못 읽으면 올리지도 보내지도 않고 false.
      final stopped = Completer<bool>();
      bloc.add(
        ChannelMessageEvent.sent(
          '자료',
          files: [uploadFileOf('a.pdf')],
          accepted: stopped,
        ),
      );
      expect(await stopped.future, isFalse);
      await settle();
      expect(fileCalls(gateway).where((c) => c.contains('/files/')), isEmpty);
      expect(_texts(bloc), ['첫 번째', '두 번째']);

      gateway.failing = null;
      final sentFiles = Completer<bool>();
      final sentText = Completer<bool>();
      bloc
        ..add(
          ChannelMessageEvent.sent(
            '',
            files: [uploadFileOf('a.pdf')],
            accepted: sentFiles,
          ),
        )
        ..add(ChannelMessageEvent.sent('글', accepted: sentText));

      expect(await sentFiles.future, isTrue);
      expect(await sentText.future, isTrue);
      await settle();
    });

    test('한 번에 10개보다 많으면 올리지 않고 알린다', () async {
      final gateway = FakeMessageGateway();
      final bloc = await _loaded(gateway, FakeChatSocket());
      addTearDown(bloc.close);

      bloc.add(
        ChannelMessageEvent.sent(
          '',
          files: [
            for (var i = 0; i <= ChannelMessageBloc.maxAttachments; i++)
              uploadFileOf('$i.txt'),
          ],
        ),
      );
      await settle();

      expect(fileCalls(gateway), isEmpty);
      expect(_texts(bloc), ['첫 번째', '두 번째']);
      expect(_data(bloc).errorMessage, '파일은 한 번에 10개까지 보낼 수 있어요.');
    });

    test('저장 확인이 오지 않으면 파일 메시지는 빼지 않고 실패로 남긴다', () async {
      final gateway = FakeMessageGateway();
      final bloc = await _loaded(
        gateway,
        FakeChatSocket(),
        confirmTimeout: const Duration(milliseconds: 50),
      );
      addTearDown(bloc.close);

      bloc.add(ChannelMessageEvent.sent('', files: [uploadFileOf('a.pdf')]));
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<ChannelConversation> &&
            s.data.messages.last.upload?.failed == true,
      );

      expect(_data(bloc).messages.last.attachments.single.name, 'a.pdf');
      expect(_data(bloc).errorMessage, '파일이 전송되지 않았어요. 다시 보내 주세요.');
    });
  });
}
