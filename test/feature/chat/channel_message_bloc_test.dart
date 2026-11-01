import 'dart:async';

import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
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
}) => ChannelMessageBloc(
  channelId: 10,
  channelRepository: ChannelRepository.withDio(messageDio(gateway, 'channel')),
  messageRepository: MessageRepository.withDio(
    chat: messageDio(gateway, 'chat'),
    user: messageDio(gateway, 'user'),
  ),
  profileRepository: ProfileRepository.withDio(messageDio(gateway, 'user')),
  socket: socket,
  lifecycle: lifecycle,
  confirmTimeout: confirmTimeout,
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
}
