import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/chat/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:cowork_app/feature/chat/presentation/blocs/channel_message/channel_message_bloc.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'channel_message_test_server.dart';
import 'chat_test_server.dart';

ChannelMessageBloc _bloc(FakeMessageGateway gateway, FakeChatSocket socket) =>
    ChannelMessageBloc(
      channelId: 10,
      channelRepository: ChannelRepository.withDio(
        messageDio(gateway, 'channel'),
      ),
      messageRepository: MessageRepository.withDio(
        chat: messageDio(gateway, 'chat'),
        user: messageDio(gateway, 'user'),
      ),
      profileRepository: ProfileRepository.withDio(messageDio(gateway, 'user')),
      socket: socket,
    );

/// 불러오기까지 마친 Bloc. 이후 요청만 보도록 불러오기 기록은 비운다.
Future<ChannelMessageBloc> _loaded(
  FakeMessageGateway gateway,
  FakeChatSocket socket,
) async {
  final bloc = _bloc(gateway, socket)
    ..add(const ChannelMessageEvent.requested());
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
}
