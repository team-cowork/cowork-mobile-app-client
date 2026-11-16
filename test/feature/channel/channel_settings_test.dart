import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/channel/data/model/requests/update_channel_request.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/channel/domain/channel_notification.dart';
import 'package:cowork_app/feature/channel/presentation/blocs/channel_settings/channel_settings_bloc.dart';
import 'package:cowork_app/feature/channel/presentation/views/channel_settings_view.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:cowork_app/feature/profile/data/profile_store.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:cowork_app/feature/setting/data/preference_repository.dart';
import 'package:cowork_app/feature/setting/domain/enums/notification_level.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../chat/channel_message_test_server.dart';

const _notificationPath =
    '/preference/preferences/account/1/channels/10/notification';

ChannelRepository _channels(FakeMessageGateway gateway) =>
    ChannelRepository.withDio(messageDio(gateway, 'channel'));

PreferenceRepository _preferences(FakeMessageGateway gateway) =>
    PreferenceRepository.withDio(messageDio(gateway, 'preference'));

ProfileRepository _profiles(FakeMessageGateway gateway) =>
    ProfileRepository.withDio(messageDio(gateway, 'user'));

MessageRepository _messages(FakeMessageGateway gateway) =>
    MessageRepository.withDio(
      chat: messageDio(gateway, 'chat'),
      user: messageDio(gateway, 'user'),
    );

ChannelSettingsBloc _bloc(FakeMessageGateway gateway) => ChannelSettingsBloc(
  channelId: 10,
  channelRepository: _channels(gateway),
  preferenceRepository: _preferences(gateway),
  profileRepository: _profiles(gateway),
  messageRepository: _messages(gateway),
);

/// 불러오기까지 마친 Bloc. 이후 요청만 보도록 불러오기 기록은 비운다.
Future<ChannelSettingsBloc> _loaded(FakeMessageGateway gateway) async {
  final bloc = _bloc(gateway)..add(const ChannelSettingsEvent.requested());
  await bloc.stream.firstWhere((s) => s is AsyncSuccess<ChannelSettingsData>);
  await pumpEventQueue();
  gateway.calls.clear();
  return bloc;
}

ChannelSettingsData _data(ChannelSettingsBloc bloc) =>
    (bloc.state as AsyncSuccess<ChannelSettingsData>).data;

void main() {
  setUp(() => ProfileStore.instance.currentUserId = 1);
  tearDown(() => ProfileStore.instance.currentUserId = null);

  group('저장소', () {
    test('채널 응답에서 공개 여부를 읽는다', () async {
      final gateway = FakeMessageGateway();
      gateway.channel['isPrivate'] = true;

      final channel = await _channels(gateway).fetchChannel(10);

      expect(channel.name, '백엔드');
      expect(channel.isPrivate, isTrue);
    });

    test('채널 수정은 바꾼 필드만 보낸다', () async {
      final gateway = FakeMessageGateway();

      await _channels(
        gateway,
      ).updateChannel(10, const UpdateChannelRequest(name: '새 이름'));

      expect(gateway.bodies['PATCH /channel/channels/10'], {'name': '새 이름'});
    });

    test('채널 알림 설정을 읽고, 정한 적 없으면 수준이 null 이다', () async {
      final gateway = FakeMessageGateway();

      final notification = await _preferences(
        gateway,
      ).fetchChannelNotification(1, 10);

      expect(notification.level, isNull);
      expect(notification.mutedUntil, isNull);
    });

    test('채널 알림 설정은 수준과 음소거 시각을 통째로 보낸다', () async {
      final gateway = FakeMessageGateway();
      final until = DateTime.utc(2030, 1, 2, 3);

      final saved = await _preferences(gateway).updateChannelNotification(
        1,
        10,
        ChannelNotification(
          level: NotificationLevel.mentions,
          mutedUntil: until,
        ),
      );

      expect(gateway.bodies['PUT $_notificationPath'], {
        'notification_level': 'MENTIONS',
        'muted_until': '2030-01-02T03:00:00.000Z',
      });
      expect(saved.level, NotificationLevel.mentions);
      expect(saved.mutedUntil, until);
    });

    test('수준을 정하지 않으면 DEFAULT 로 보낸다', () async {
      final gateway = FakeMessageGateway();

      await _preferences(
        gateway,
      ).updateChannelNotification(1, 10, const ChannelNotification());

      expect(gateway.bodies['PUT $_notificationPath'], {
        'notification_level': 'DEFAULT',
        'muted_until': null,
      });
    });
  });

  group('Bloc', () {
    test('채널 정보와 알림 설정, 멤버 수와 미리보기를 불러온다', () async {
      final gateway = FakeMessageGateway();
      gateway.channel['isPrivate'] = true;
      gateway.notification = {
        'notification_level': 'NONE',
        'muted_until': null,
      };
      final bloc = await _loaded(gateway);
      addTearDown(bloc.close);

      final settings = _data(bloc).settings;
      expect(settings.name, '백엔드');
      expect(settings.description, 'API 논의');
      expect(settings.isPrivate, isTrue);
      expect(settings.notification.level, NotificationLevel.none);
      expect(settings.memberCount, 3);
      expect(settings.memberPreview.map((m) => m.profile.name), [
        '나',
        '도윤',
        '서연',
      ]);
    });

    test('불러오기가 실패하면 실패 상태가 된다', () async {
      final gateway = FakeMessageGateway()..failing = 'GET $_notificationPath';
      final bloc = _bloc(gateway)..add(const ChannelSettingsEvent.requested());
      addTearDown(bloc.close);

      await bloc.stream.firstWhere(
        (s) => s is AsyncFailure<ChannelSettingsData>,
      );
    });

    test('이름을 바꾸면 바로 보이고 이름만 서버에 보낸다', () async {
      final gateway = FakeMessageGateway();
      final bloc = await _loaded(gateway);
      addTearDown(bloc.close);

      bloc.add(const ChannelSettingsEvent.nameChanged('  새 이름  '));
      await pumpEventQueue();

      expect(_data(bloc).settings.name, '새 이름');
      expect(gateway.bodies['PATCH /channel/channels/10'], {'name': '새 이름'});
    });

    test('빈 이름은 보내지 않는다', () async {
      final gateway = FakeMessageGateway();
      final bloc = await _loaded(gateway);
      addTearDown(bloc.close);

      bloc.add(const ChannelSettingsEvent.nameChanged('   '));
      await pumpEventQueue();

      expect(gateway.calls, isEmpty);
      expect(_data(bloc).settings.name, '백엔드');
    });

    test('설명은 비워서도 바꿀 수 있다', () async {
      final gateway = FakeMessageGateway();
      final bloc = await _loaded(gateway);
      addTearDown(bloc.close);

      bloc.add(const ChannelSettingsEvent.descriptionChanged(''));
      await pumpEventQueue();

      expect(_data(bloc).settings.description, '');
      expect(gateway.bodies['PATCH /channel/channels/10'], {'description': ''});
    });

    test('비공개 여부를 바꾸면 그 값만 보낸다', () async {
      final gateway = FakeMessageGateway();
      final bloc = await _loaded(gateway);
      addTearDown(bloc.close);

      bloc.add(const ChannelSettingsEvent.privateToggled(true));
      await pumpEventQueue();

      expect(_data(bloc).settings.isPrivate, isTrue);
      expect(gateway.bodies['PATCH /channel/channels/10'], {'isPrivate': true});
    });

    test('바꾸기가 실패하면 그 값만 되돌리고 사유를 싣는다', () async {
      final gateway = FakeMessageGateway();
      final bloc = await _loaded(gateway);
      addTearDown(bloc.close);
      gateway.failing = 'PATCH /channel/channels/10';

      bloc.add(const ChannelSettingsEvent.privateToggled(true));
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<ChannelSettingsData> &&
            s.data.errorMessage != null,
      );

      expect(_data(bloc).settings.isPrivate, isFalse);
      expect(_data(bloc).errorMessage, isNotNull);
    });

    test('알림 수준을 바꿔도 음소거 시각은 그대로 보낸다', () async {
      final gateway = FakeMessageGateway();
      gateway.notification = {
        'notification_level': 'ALL',
        'muted_until': '2030-01-02T03:00:00.000Z',
      };
      final bloc = await _loaded(gateway);
      addTearDown(bloc.close);

      bloc.add(
        const ChannelSettingsEvent.notificationLevelChanged(
          NotificationLevel.mentions,
        ),
      );
      await pumpEventQueue();

      expect(gateway.bodies['PUT $_notificationPath'], {
        'notification_level': 'MENTIONS',
        'muted_until': '2030-01-02T03:00:00.000Z',
      });
      expect(
        _data(bloc).settings.notification.level,
        NotificationLevel.mentions,
      );
    });

    test('음소거를 켜면 먼 시각을, 끄면 null 을 보낸다', () async {
      final gateway = FakeMessageGateway();
      final bloc = await _loaded(gateway);
      addTearDown(bloc.close);

      bloc.add(const ChannelSettingsEvent.muteToggled(true));
      await pumpEventQueue();

      expect(gateway.bodies['PUT $_notificationPath'], {
        'notification_level': 'DEFAULT',
        'muted_until': '9999-01-01T00:00:00.000Z',
      });
      expect(_data(bloc).settings.notification.isMuted(DateTime.now()), isTrue);

      bloc.add(const ChannelSettingsEvent.muteToggled(false));
      await pumpEventQueue();

      expect(gateway.bodies['PUT $_notificationPath']!['muted_until'], isNull);
      expect(
        _data(bloc).settings.notification.isMuted(DateTime.now()),
        isFalse,
      );
    });
  });

  group('화면', () {
    Future<void> pumpSettings(
      WidgetTester tester,
      FakeMessageGateway gateway,
    ) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<ChannelRepository>.value(
              value: _channels(gateway),
            ),
            RepositoryProvider<PreferenceRepository>.value(
              value: _preferences(gateway),
            ),
            RepositoryProvider<ProfileRepository>.value(
              value: _profiles(gateway),
            ),
            RepositoryProvider<MessageRepository>.value(
              value: _messages(gateway),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const ChannelSettingsView(channelId: 10),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('채널 정보와 알림 수준, 멤버 수를 보여 준다', (tester) async {
      await pumpSettings(tester, FakeMessageGateway());

      expect(find.text('# 백엔드'), findsOneWidget);
      expect(find.text('API 논의'), findsOneWidget);
      expect(find.text('기본'), findsOneWidget);
      expect(find.text('멤버 3명'), findsOneWidget);
      expect(find.text('채널 나가기'), findsNothing);
      expect(find.text('멤버 초대'), findsNothing);
    });

    testWidgets('채널 이름을 눌러 고치면 서버에 보내고 새 이름이 보인다', (tester) async {
      final gateway = FakeMessageGateway();
      await pumpSettings(tester, gateway);

      await tester.tap(find.text('채널 이름'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '새 이름');
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(gateway.bodies['PATCH /channel/channels/10'], {'name': '새 이름'});
      expect(find.text('# 새 이름'), findsOneWidget);
    });

    testWidgets('이름을 비우면 저장할 수 없다', (tester) async {
      final gateway = FakeMessageGateway();
      await pumpSettings(tester, gateway);

      await tester.tap(find.text('채널 이름'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '');
      await tester.pump();
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(gateway.calls, isNot(contains(startsWith('PATCH'))));
    });

    testWidgets('알림을 눌러 멘션만을 고르면 서버에 보내고 값이 바뀐다', (tester) async {
      final gateway = FakeMessageGateway();
      await pumpSettings(tester, gateway);

      await tester.tap(find.text('기본'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('멘션만'));
      await tester.pumpAndSettle();

      expect(
        gateway.bodies['PUT $_notificationPath']!['notification_level'],
        'MENTIONS',
      );
      expect(find.text('멘션만'), findsOneWidget);
    });

    testWidgets('바꾸기가 실패하면 되돌리고 사유를 알린다', (tester) async {
      final gateway = FakeMessageGateway();
      await pumpSettings(tester, gateway);
      gateway.failing = 'PATCH /channel/channels/10';

      await tester.tap(find.byType(CoworkSwitch).first);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('불러오지 못하면 에러 화면에서 다시 시도할 수 있다', (tester) async {
      final gateway = FakeMessageGateway()
        ..failing = 'GET /channel/channels/10';
      await pumpSettings(tester, gateway);

      expect(find.text('채널 설정을 불러오지 못했어요'), findsOneWidget);

      gateway.failing = null;
      await tester.tap(find.text('다시 시도'));
      await tester.pumpAndSettle();

      expect(find.text('# 백엔드'), findsOneWidget);
    });
  });
}
