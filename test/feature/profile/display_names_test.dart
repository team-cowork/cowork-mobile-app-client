import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/profile/data/model/responses/user_display_name_response.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// `/users/batch` 요청을 적어 두고, 받은 id 마다 사용자 하나씩 돌려주는 서버.
class _BatchServer implements HttpClientAdapter {
  final calls = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final uri = options.uri;
    calls.add('${options.method} ${uri.path}?${uri.query}');
    final ids = uri.queryParameters['ids']!.split(',');
    return ResponseBody.fromString(
      jsonEncode({
        'data': {
          'users': [
            for (final id in ids) {'id': int.parse(id), 'name': '사용자$id'},
          ],
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('작성자 이름은 중복을 빼고 100명씩 나눠 읽는다', () async {
    final server = _BatchServer();
    final repository = ProfileRepository.withDio(
      Dio(
        BaseOptions(
          baseUrl: 'https://example.test/api/user',
          responseType: ResponseType.plain,
        ),
      )..httpClientAdapter = server,
    );

    final users = await repository.fetchDisplayNames([
      for (var id = 1; id <= 150; id++) id,
      1,
      2,
    ]);

    expect(users, hasLength(150));
    expect(server.calls, hasLength(2));
    expect(
      server.calls.last,
      startsWith('GET /api/user/users/batch?ids=101%2C'),
    );
  });

  group('표시 이름', () {
    test('이름이 있으면 이름을 쓴다', () {
      const user = UserDisplayNameResponse(id: 1, name: '서연', nickname: '별명');

      expect(user.displayName, '서연');
    });

    test('이름이 비어 있으면 닉네임을 쓴다', () {
      const user = UserDisplayNameResponse(id: 1, nickname: '별명');

      expect(user.displayName, '별명');
    });

    test('이름도 닉네임도 없으면 빈 문자열이다', () {
      expect(const UserDisplayNameResponse(id: 1).displayName, '');
    });
  });
}
