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
  _StubAdapter({required String? profileImageUrl, this.saveStatus = 200})
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

  /// 저장(조회가 아닌 요청)에 돌려줄 상태 코드. 실패 경로를 태울 때 바꾼다.
  final int saveStatus;

  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final failed = options.method != 'GET' && saveStatus != 200;
    return ResponseBody.fromString(
      failed ? jsonEncode({'message': '이미 사용 중인 사용자명이에요.'}) : body,
      failed ? saveStatus : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 편집 화면을 한 단계 밀어 넣고 연다. 저장 뒤 화면이 닫히는지 보려면 돌아갈
/// 화면(`열기` 버튼)이 있어야 한다.
Future<_StubAdapter> _openEditProfile(
  WidgetTester tester, {
  required String? profileImageUrl,
  int saveStatus = 200,
}) async {
  final adapter = _StubAdapter(
    profileImageUrl: profileImageUrl,
    saveStatus: saveStatus,
  );
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example.test/api',
      contentType: Headers.jsonContentType,
      responseType: ResponseType.plain,
    ),
  )..httpClientAdapter = adapter;

  await tester.pumpWidget(
    RepositoryProvider(
      create: (_) => ProfileRepository.withDio(dio),
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const EditProfileView()),
            ),
            child: const Text('열기'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('열기'));
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
      containsAllInOrder(['DELETE /users/me/profile-image', 'PATCH /users/me']),
      reason: '사진을 먼저 지우고 나머지 값을 저장한다',
    );
    expect(find.text('열기'), findsOneWidget, reason: '저장이 끝나야 화면이 닫힌다');
  });

  testWidgets('저장이 실패하면 화면을 닫지 않고 서버 사유를 띄운다', (tester) async {
    await _openEditProfile(tester, profileImageUrl: null, saveStatus: 400);

    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(find.text('프로필을 저장하지 못했어요'), findsOneWidget);
    expect(find.text('(400) 이미 사용 중인 사용자명이에요.'), findsOneWidget);
    expect(find.text('열기'), findsNothing, reason: '실패했는데 닫히면 저장된 줄 안다');

    // 다시 시도하면 폼으로 돌아오고, 고쳐 둔 입력이 살아 있어야 한다.
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('김준혁'), findsOneWidget);
  });
}
