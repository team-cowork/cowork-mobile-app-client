import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/profile/data/github_repository.dart';
import 'package:cowork_app/feature/profile/data/user_response.dart';
import 'package:cowork_app/feature/profile/domain/profile.dart';
import 'package:cowork_app/feature/profile/presentation/widgets/github_streak_card.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 정해진 본문(또는 상태 코드)을 돌려주고 나간 요청을 받아 적는 어댑터.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.body, [this.statusCode = 200]);

  final String body;
  final int statusCode;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

GithubRepository _repository(_StubAdapter adapter) => GithubRepository(
  Dio(BaseOptions(baseUrl: 'https://api.github.com'))
    ..httpClientAdapter = adapter,
);

/// [at] 에 커밋 [size] 개를 담은 PushEvent.
Map<String, dynamic> _push(String at, int size) => {
  'type': 'PushEvent',
  'created_at': at,
  'payload': {'size': size},
};

void main() {
  test('같은 날 PushEvent 의 커밋 수를 합친다', () async {
    final adapter = _StubAdapter(
      jsonEncode([
        _push('2026-08-10T01:00:00Z', 3),
        _push('2026-08-10T09:30:00Z', 2),
        _push('2026-08-11T04:00:00Z', 1),
        // push 가 아닌 이벤트는 커밋이 아니다.
        {'type': 'WatchEvent', 'created_at': '2026-08-10T05:00:00Z'},
      ]),
    );

    final commits = await _repository(adapter).commitsByDay('joon');

    final day = DateTime.parse('2026-08-10T01:00:00Z').toLocal();
    expect(commits[DateTime(day.year, day.month, day.day)], 5);
    expect(commits.values.reduce((a, b) => a + b), 6);
    expect(adapter.requests.single.path, '/users/joon/events/public');
  });

  test('조회가 실패해도 던지지 않는다', () async {
    // 아이디 오타로 404, rate limit 으로 403 이 정상적으로 난다. 스트릭 하나 때문에
    // 프로필 전체가 못 뜨면 안 된다.
    final commits = await _repository(
      _StubAdapter('{"message":"Not Found"}', 404),
    ).commitsByDay('없는사람');

    expect(commits, isEmpty);
  });

  test('GitHub ID 가 없으면 히트맵 대신 등록 안내를 준다', () {
    final streak = Profile.fromMe(
      UserResponse.fromJson(const {'name': '김준혁', 'github_id': null}),
    ).streak;

    expect(streak.notice, contains('DataGSM'));
    expect(streak.commitsByDay, isEmpty);
  });

  testWidgets('히트맵이 좁은 화면에서도 넘치지 않는다', (tester) async {
    // 셀이 열 너비를 따라가는 정사각형이라 폭·높이 계산이 서로를 물고 있다.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: GithubStreakCard(
              streak: GithubStreak(
                rangeLabel: '최근 13주',
                commitsByDay: {DateTime.now(): 12},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('GitHub 커밋 스트릭'), findsOneWidget);
  });

  test('GitHub ID 가 있으면 받은 커밋을 그대로 싣는다', () {
    final commits = {DateTime(2026, 8, 10): 4};
    final streak = Profile.fromMe(
      UserResponse.fromJson(const {'name': '김준혁', 'github_id': 'joon'}),
      commitsByDay: commits,
    ).streak;

    expect(streak.notice, isNull);
    expect(streak.rangeLabel, '최근 ${GithubStreak.weeks}주');
    expect(streak.commitsByDay, commits);
  });
}
