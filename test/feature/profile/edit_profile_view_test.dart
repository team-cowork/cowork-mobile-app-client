import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/profile/data/profile_repository.dart';
import 'package:cowork_app/feature/profile/data/profile_store.dart';
import 'package:cowork_app/feature/profile/presentation/views/edit_profile_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// 어떤 요청에든 같은 `/users/me` 응답을 돌려주고, 나간 요청을 받아 적는다.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({required String? profileImageUrl})
    : body = jsonEncode({
        'id': 7,
        'name': '김준혁',
        'status': 'ONLINE',
        'nickname': 'joon',
        'status_message': '',
        'description': '',
        'profile_image_url': profileImageUrl,
      });

  final String body;
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
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<_StubAdapter> _openEditProfile(
  WidgetTester tester, {
  required String? profileImageUrl,
}) async {
  final adapter = _StubAdapter(profileImageUrl: profileImageUrl);
  final dio =
      Dio(
          BaseOptions(
            baseUrl: 'https://example.test/api',
            contentType: Headers.jsonContentType,
            responseType: ResponseType.plain,
          ),
        )
        ..httpClientAdapter = adapter;

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: RepositoryProvider(
        create: (_) => ProfileRepository.withDio(dio),
        child: const EditProfileView(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return adapter;
}

void main() {
  // 전역 캐시라 테스트끼리 샌다. 사진을 고른 적 없는 상태에서 시작한다.
  setUp(() => ProfileStore.instance.localAvatarPath = null);

  testWidgets('사진이 없으면 삭제할 것도 없어 `사진 삭제` 가 뜨지 않는다', (tester) async {
    await _openEditProfile(tester, profileImageUrl: null);

    expect(find.text('사진 변경'), findsOneWidget);
    expect(find.text('사진 삭제'), findsNothing);
  });

  testWidgets('사진을 지우고 저장하면 삭제 요청이 나간다', (tester) async {
    final adapter = await _openEditProfile(
      tester,
      profileImageUrl: 'https://cdn.test/a.png',
    );

    await tester.tap(find.text('사진 삭제'));
    await tester.pumpAndSettle();

    // 지운 자리는 이니셜 폴백이 메우고, 더 지울 사진이 없으니 링크도 사라진다.
    expect(find.text('김'), findsOneWidget);
    expect(find.text('사진 삭제'), findsNothing);

    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(
      adapter.requests.map((r) => '${r.method} ${r.path}'),
      containsAllInOrder([
        'DELETE /users/me/profile-image',
        'PATCH /users/me',
      ]),
      reason: '사진을 먼저 지우고 나머지 값을 저장한다',
    );
  });
}
