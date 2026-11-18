import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/channel/presentation/blocs/channel_members/channel_members_bloc.dart';
import 'package:cowork_app/feature/channel/presentation/views/members_view.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:cowork_app/feature/channel/domain/channel_member.dart';
import 'package:cowork_app/feature/team/data/repositories/team_repository.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../chat/channel_message_test_server.dart';

ChannelRepository _channels(FakeMessageGateway gateway) =>
    ChannelRepository.withDio(messageDio(gateway, 'channel'));

MessageRepository _messages(FakeMessageGateway gateway) =>
    MessageRepository.withDio(
      chat: messageDio(gateway, 'chat'),
      user: messageDio(gateway, 'user'),
    );

TeamRepository _teams(FakeMessageGateway gateway) =>
    TeamRepository.withDio(messageDio(gateway, 'team'));

ChannelMembersBloc _bloc(FakeMessageGateway gateway) => ChannelMembersBloc(
  channelId: 10,
  channelRepository: _channels(gateway),
  messageRepository: _messages(gateway),
  teamRepository: _teams(gateway),
);

void main() {
  test('멤버 목록은 사용자 id 만 담아 읽는다', () async {
    final gateway = FakeMessageGateway();

    final members = await _channels(gateway).fetchMembers(10);

    expect(gateway.calls, ['GET /channel/channels/10/members']);
    expect(members.map((m) => m.userId), [1, 2, 3]);
  });

  group('Bloc', () {
    test('채널 이름과 멤버를 이름과 함께 불러온다', () async {
      final gateway = FakeMessageGateway();
      final bloc = _bloc(gateway)..add(const ChannelMembersEvent.requested());
      addTearDown(bloc.close);

      final state = await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelMembersData>,
      );

      final data = (state as AsyncSuccess<ChannelMembersData>).data;
      expect(data.channelName, '백엔드');
      expect([for (final m in data.members) m.profile.name], ['나', '도윤', '서연']);
      expect(data.members.first.profile.id, 1);
      expect(gateway.calls, contains('GET /user/users/batch?ids=1%2C2%2C3'));
    });

    test('닉네임이 있어도 이름이 있으면 이름을 쓰고, 이름이 비면 닉네임을 쓴다', () async {
      final gateway = FakeMessageGateway()
        ..users[2] = ''
        ..nicknames[1] = '별명'
        ..nicknames[2] = '도윤닉';
      final bloc = _bloc(gateway)..add(const ChannelMembersEvent.requested());
      addTearDown(bloc.close);

      final state = await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelMembersData>,
      );

      final data = (state as AsyncSuccess<ChannelMembersData>).data;
      expect(
        [for (final m in data.members) m.profile.name],
        ['나', '도윤닉', '서연'],
      );
    });

    test('팀 역할을 함께 읽고, 기본 역할은 뺀다', () async {
      final gateway = FakeMessageGateway();
      final bloc = _bloc(gateway)..add(const ChannelMembersEvent.requested());
      addTearDown(bloc.close);

      final state = await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelMembersData>,
      );

      final members = (state as AsyncSuccess<ChannelMembersData>).data.members;
      expect(members.map((m) => m.role), [
        ChannelMemberRole.owner,
        ChannelMemberRole.admin,
        ChannelMemberRole.member,
      ]);
      expect(members.first.roleNames, ['Backend']);
      expect(members[1].roleNames, isEmpty);
      expect(gateway.calls, contains('GET /team/teams/1/members'));
    });

    test('팀 역할을 못 읽어도 멤버 목록은 보여 준다', () async {
      final gateway = FakeMessageGateway()
        ..failing = 'GET /team/teams/1/members';
      final bloc = _bloc(gateway)..add(const ChannelMembersEvent.requested());
      addTearDown(bloc.close);

      final state = await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelMembersData>,
      );

      final members = (state as AsyncSuccess<ChannelMembersData>).data.members;
      expect(members, hasLength(3));
      expect(members.every((m) => m.role == ChannelMemberRole.member), isTrue);
    });

    test('이름을 못 읽어도 멤버 목록은 보여 준다', () async {
      final gateway = FakeMessageGateway()..failing = 'GET /user/users/batch';
      final bloc = _bloc(gateway)..add(const ChannelMembersEvent.requested());
      addTearDown(bloc.close);

      final state = await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelMembersData>,
      );

      final data = (state as AsyncSuccess<ChannelMembersData>).data;
      expect(data.members, hasLength(3));
      expect(data.members.every((m) => m.profile.name == '알 수 없음'), isTrue);
    });

    test('멤버를 못 읽으면 실패 상태가 된다', () async {
      final gateway = FakeMessageGateway()
        ..failing = 'GET /channel/channels/10/members';
      final bloc = _bloc(gateway)..add(const ChannelMembersEvent.requested());
      addTearDown(bloc.close);

      await bloc.stream.firstWhere(
        (s) => s is AsyncFailure<ChannelMembersData>,
      );
    });
  });

  group('화면', () {
    Future<void> pumpMembers(
      WidgetTester tester,
      FakeMessageGateway gateway,
    ) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<ChannelRepository>.value(
              value: _channels(gateway),
            ),
            RepositoryProvider<MessageRepository>.value(
              value: _messages(gateway),
            ),
            RepositoryProvider<TeamRepository>.value(value: _teams(gateway)),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const MembersView(channelId: 10),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('채널 이름과 멤버 수, 멤버 이름을 보여 준다', (tester) async {
      await pumpMembers(tester, FakeMessageGateway());

      expect(find.text('# 백엔드 · 3명'), findsOneWidget);
      // 이름 `나` 는 아바타 이니셜과 같아 두 번 보인다.
      expect(find.text('나'), findsNWidgets(2));
      expect(find.text('도윤'), findsOneWidget);
      expect(find.text('서연'), findsOneWidget);
    });

    testWidgets('소유자·관리자는 배지로, 커스텀 역할은 이름 아래에 보인다', (tester) async {
      await pumpMembers(tester, FakeMessageGateway());

      expect(find.text('소유자'), findsOneWidget);
      expect(find.text('관리자'), findsOneWidget);
      expect(find.text('Backend'), findsOneWidget);
    });

    testWidgets('불러오지 못하면 에러 화면에서 다시 시도할 수 있다', (tester) async {
      final gateway = FakeMessageGateway()
        ..failing = 'GET /channel/channels/10/members';
      await pumpMembers(tester, gateway);

      expect(find.text('멤버를 불러오지 못했어요'), findsOneWidget);

      gateway.failing = null;
      await tester.tap(find.text('다시 시도'));
      await tester.pumpAndSettle();

      expect(find.text('도윤'), findsOneWidget);
    });
  });
}
