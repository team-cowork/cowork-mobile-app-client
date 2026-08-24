// 프로필 화면을 서버 없이 띄워 보는 하네스.
//
//   fvm flutter run -t tool/preview_profile.dart -d <에뮬레이터>
//
// 실제 앱은 DataGSM OAuth 를 통과해야 프로필까지 갈 수 있다. 여기서는 dio 어댑터만
// 스텁으로 갈아 끼우고 화면·위젯은 앱과 똑같은 것을 쓴다. 저장은 일부러 400 을
// 돌려주므로 편집 → 저장으로 실패 화면까지 볼 수 있다.
//
// lib/ 밖이라 앱 번들에는 안 들어가지만 analyze 대상이라, 화면 API 가 바뀌면 여기서
// 먼저 깨진다. 다른 화면을 볼 일이 생기면 이 파일을 복사해 쓰면 된다.
import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/profile/data/github_repository.dart';
import 'package:cowork_app/feature/profile/data/profile_repository.dart';
import 'package:cowork_app/feature/profile/presentation/views/my_profile_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 경로별로 정해진 응답을 돌려주는 어댑터.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.responses);

  /// `메서드 경로` 조각 → (상태 코드, 본문). 먼저 걸리는 키가 이긴다.
  final Map<String, (int, String)> responses;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final target = '${options.method} ${options.path}';
    final key = responses.keys.firstWhere(target.contains, orElse: () => '');
    final (status, body) = responses[key] ?? (404, '{"message":"stub 없음"}');
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 최근 90일치 PushEvent. 색 4단계가 모두 보이도록 커밋 수를 흩어 놓는다.
String _events() {
  final today = DateTime.now();
  const sizes = [0, 1, 0, 4, 0, 2, 12, 0, 7, 3, 0, 0, 1, 9];
  return jsonEncode([
    for (var ago = 0; ago < 90; ago++)
      if (sizes[ago % sizes.length] > 0)
        {
          'type': 'PushEvent',
          'created_at': today
              .subtract(Duration(days: ago))
              .toUtc()
              .toIso8601String(),
          'payload': {'size': sizes[ago % sizes.length]},
        },
  ]);
}

Dio _dio(String baseUrl, Map<String, (int, String)> responses) => Dio(
  BaseOptions(
    baseUrl: baseUrl,
    contentType: Headers.jsonContentType,
    responseType: ResponseType.plain,
  ),
)..httpClientAdapter = _StubAdapter(responses);

void main() {
  final me = jsonEncode({
    'id': 7,
    'name': '김준혁',
    'nickname': 'joon_hyeok0204',
    'status': 'ONLINE',
    'status_message': 'PR 리뷰 환영',
    'description': '실서비스 트러블슈팅을 좋아합니다.',
    'specialty': '프론트엔드 개발자',
    'student_number': 'GSM 3학년 1반',
    'major': '소프트웨어개발과',
    'github_id': 'joon',
    'profile_image_url': null,
    'roles': ['OWNER', '프론트엔드'],
  });

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => ProfileRepository.withDio(
            _dio('https://example.test/api', {
              // 저장은 일부러 실패시킨다. 편집 → 저장 → 에러 상태를 보려고.
              'PATCH /users/me': (400, '{"message":"이미 사용 중인 사용자명이에요."}'),
              'GET /users/me': (200, me),
            }),
          ),
        ),
        RepositoryProvider(
          create: (_) => GithubRepository(
            Dio(BaseOptions(baseUrl: 'https://api.github.com'))
              ..httpClientAdapter = _StubAdapter({
                'events/public': (200, _events()),
              }),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const MyProfileView(),
      ),
    ),
  );
}
