import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:cowork_app/feature/setting/data/preference_repository.dart';
import 'package:cowork_app/feature/setting/data/push_repository.dart';
import 'package:cowork_app/feature/setting/domain/enums/notification_level.dart';
import 'package:cowork_app/feature/setting/domain/enums/setting_toggle_enum.dart';
import 'package:cowork_app/feature/setting/presentation/blocs/settings/settings_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 요청을 `METHOD 경로` 로 받아 적고, 정해 둔 응답을 돌려주는 가짜 서버.
///
/// PUT 은 서버가 저장한 설정을 그대로 돌려주는 동작을 흉내 내 요청 본문을 되돌린다.
class _FakeServer implements HttpClientAdapter {
  _FakeServer({required String notificationLevel})
    : _preference = {
        'notification_level': notificationLevel,
        'theme': 'BLACK',
        'timezone': 'Asia/Seoul',
      };

  final Map<String, dynamic> _preference;

  /// 이 요청에는 500 을 돌려준다.
  String? failing;

  final calls = <String>[];
  final bodies = <String, Object?>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final call = '${options.method} ${options.path}';
    calls.add(call);
    final sent = requestStream == null
        ? null
        : utf8.decode((await requestStream.toList()).expand((c) => c).toList());
    if (sent != null && sent.isNotEmpty) bodies[call] = jsonDecode(sent);

    if (call == failing) return _json({'message': '서버 오류'}, 500);
    return switch (call) {
      'GET /users/me' => _json({'id': 7, 'name': '김코웍'}),
      'GET /preferences/account/7' => _json(_preference),
      'PUT /preferences/account/7' => ResponseBody.fromString(sent!, 200),
      _ => ResponseBody.fromString('', 204),
    };
  }

  static ResponseBody _json(Object body, [int status = 200]) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

class _FakeDevice implements PushDevice {
  _FakeDevice({this.granted = true});

  final bool granted;

  @override
  Future<bool> requestPermission() async => granted;

  @override
  Future<String> installationId() async => 'fid-1';

  @override
  String get platform => 'ANDROID';
}

Dio _dio(HttpClientAdapter adapter) => Dio(
  BaseOptions(
    baseUrl: 'https://example.test/api',
    contentType: Headers.jsonContentType,
    responseType: ResponseType.plain,
  ),
)..httpClientAdapter = adapter;

/// 불러오기까지 마친 Bloc. 이후 요청만 보도록 불러오기 기록은 비운다.
Future<SettingsBloc> _loaded(_FakeServer server, [PushDevice? device]) async {
  final bloc = SettingsBloc(
    profile: ProfileRepository.withDio(_dio(server)),
    preference: PreferenceRepository.withDio(_dio(server)),
    push: PushRepository.withDio(_dio(server), device ?? _FakeDevice()),
  )..add(const SettingsRequested());
  await bloc.stream.firstWhere((s) => s is AsyncSuccess<SettingsData>);
  server.calls.clear();
  return bloc;
}

/// 토글을 넣고 저장이 끝난 상태를 기다린다.
Future<SettingsData> _toggle(
  SettingsBloc bloc,
  SettingsToggle toggle,
  bool value,
) async {
  bloc.add(SettingsToggled(toggle, value));
  final done = await bloc.stream.firstWhere(
    (s) => s is AsyncSuccess<SettingsData> && !s.data.saving,
  );
  return (done as AsyncSuccess<SettingsData>).data;
}

SettingsData _data(SettingsBloc bloc) =>
    (bloc.state as AsyncSuccess<SettingsData>).data;

void main() {
  group('불러오기', () {
    for (final (level, push, mention) in [
      ('ALL', true, false),
      ('MENTIONS', true, true),
      ('NONE', false, false),
    ]) {
      test('$level 는 푸시 $push · 멘션만 $mention 으로 보인다', () async {
        final bloc = await _loaded(_FakeServer(notificationLevel: level));
        addTearDown(bloc.close);

        expect(_data(bloc).settings.pushNotification, push);
        expect(_data(bloc).settings.mentionOnly, mention);
      });
    }

    test('/users/me 의 id 로 계정 설정을 읽는다', () async {
      final server = _FakeServer(notificationLevel: 'ALL');
      final bloc = SettingsBloc(
        profile: ProfileRepository.withDio(_dio(server)),
        preference: PreferenceRepository.withDio(_dio(server)),
        push: PushRepository.withDio(_dio(server), _FakeDevice()),
      )..add(const SettingsRequested());
      addTearDown(bloc.close);
      await bloc.stream.firstWhere((s) => s is AsyncSuccess<SettingsData>);

      expect(server.calls, ['GET /users/me', 'GET /preferences/account/7']);
    });
  });

  test('푸시를 켜면 기기를 등록하고 MENTIONS 로 저장한다', () async {
    final server = _FakeServer(notificationLevel: 'NONE');
    final bloc = await _loaded(server);
    addTearDown(bloc.close);

    final data = await _toggle(bloc, SettingsToggle.pushNotification, true);

    expect(server.calls, [
      'POST /notifications/installations',
      'PUT /preferences/account/7',
    ]);
    expect(server.bodies['POST /notifications/installations'], {
      'fid': 'fid-1',
      'platform': 'ANDROID',
    });
    expect(data.settings.notificationLevel, NotificationLevel.mentions);
  });

  test('저장할 때 화면이 다루지 않는 필드도 그대로 보낸다', () async {
    final server = _FakeServer(notificationLevel: 'ALL');
    final bloc = await _loaded(server);
    addTearDown(bloc.close);

    await _toggle(bloc, SettingsToggle.mentionOnly, true);

    expect(server.bodies['PUT /preferences/account/7'], {
      'notification_level': 'MENTIONS',
      'theme': 'BLACK',
      'timezone': 'Asia/Seoul',
    });
  });

  test('푸시를 끄면 NONE 을 저장한 뒤 기기를 해제한다', () async {
    final server = _FakeServer(notificationLevel: 'ALL');
    final bloc = await _loaded(server);
    addTearDown(bloc.close);

    final data = await _toggle(bloc, SettingsToggle.pushNotification, false);

    expect(server.calls, [
      'PUT /preferences/account/7',
      'DELETE /notifications/installations/fid-1',
    ]);
    expect(data.settings.notificationLevel, NotificationLevel.none);
  });

  test('기기 해제가 실패해도 NONE 저장은 유지한다', () async {
    final server = _FakeServer(notificationLevel: 'ALL')
      ..failing = 'DELETE /notifications/installations/fid-1';
    final bloc = await _loaded(server);
    addTearDown(bloc.close);

    final data = await _toggle(bloc, SettingsToggle.pushNotification, false);

    expect(data.settings.pushNotification, isFalse);
    expect(data.saveError, isNull);
  });

  test('멘션만 받기는 기기 등록 없이 ALL / MENTIONS 만 바꾼다', () async {
    final server = _FakeServer(notificationLevel: 'MENTIONS');
    final bloc = await _loaded(server);
    addTearDown(bloc.close);

    final data = await _toggle(bloc, SettingsToggle.mentionOnly, false);

    expect(server.calls, ['PUT /preferences/account/7']);
    expect(data.settings.notificationLevel, NotificationLevel.all);
  });

  test('푸시가 꺼져 있으면 멘션만 받기 토글은 무시한다', () async {
    final server = _FakeServer(notificationLevel: 'NONE');
    final bloc = await _loaded(server);
    addTearDown(bloc.close);

    bloc.add(const SettingsToggled(SettingsToggle.mentionOnly, true));
    await pumpEventQueue();

    expect(server.calls, isEmpty);
    expect(_data(bloc).settings.notificationLevel, NotificationLevel.none);
  });

  test('저장이 실패하면 토글을 되돌리고 사유를 싣는다', () async {
    final server = _FakeServer(notificationLevel: 'ALL')
      ..failing = 'PUT /preferences/account/7';
    final bloc = await _loaded(server);
    addTearDown(bloc.close);

    final data = await _toggle(bloc, SettingsToggle.mentionOnly, true);

    expect(data.settings.notificationLevel, NotificationLevel.all);
    expect(data.saveError, isNotNull);
  });

  test('켜다가 수준 저장이 실패하면 등록한 기기도 해제하고 되돌린다', () async {
    final server = _FakeServer(notificationLevel: 'NONE')
      ..failing = 'PUT /preferences/account/7';
    final bloc = await _loaded(server);
    addTearDown(bloc.close);

    final data = await _toggle(bloc, SettingsToggle.pushNotification, true);

    expect(server.calls, [
      'POST /notifications/installations',
      'PUT /preferences/account/7',
      'DELETE /notifications/installations/fid-1',
    ]);
    expect(data.settings.pushNotification, isFalse);
    expect(data.saveError, isNotNull);
  });

  test('알림 권한을 거절하면 요청 없이 되돌린다', () async {
    final server = _FakeServer(notificationLevel: 'NONE');
    final bloc = await _loaded(server, _FakeDevice(granted: false));
    addTearDown(bloc.close);

    final data = await _toggle(bloc, SettingsToggle.pushNotification, true);

    expect(server.calls, isEmpty);
    expect(data.settings.pushNotification, isFalse);
    expect(data.saveError, contains('권한'));
  });

  test('커밋 스트릭 공개는 서버에 보내지 않는다', () async {
    final server = _FakeServer(notificationLevel: 'ALL');
    final bloc = await _loaded(server);
    addTearDown(bloc.close);

    final data = await _toggle(bloc, SettingsToggle.commitStreakPublic, false);

    expect(server.calls, isEmpty);
    expect(data.settings.commitStreakPublic, isFalse);
  });

  test('모르는 알림 수준은 ALL 로 본다', () {
    expect(NotificationLevel.fromValue('EVERYTHING'), NotificationLevel.all);
    expect(NotificationLevel.fromValue(null), NotificationLevel.all);
  });
}
