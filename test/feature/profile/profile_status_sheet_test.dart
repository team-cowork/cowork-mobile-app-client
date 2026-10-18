import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/profile/data/profile_repository.dart';
import 'package:cowork_app/feature/profile/data/user_response.dart';
import 'package:cowork_app/feature/profile/domain/profile.dart';
import 'package:cowork_app/feature/profile/presentation/widgets/profile_status_sheet.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// 상태 변경 요청을 받아 적고, [status] 코드로 응답한다.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({this.status = 200});

  final int status;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      status == 200
          ? jsonEncode({'id': 7, 'name': '김준혁'})
          : jsonEncode({'message': '상태는 30자까지예요.'}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 시트를 띄우고, 시트가 돌려준 값을 [results] 에 담는다.
Future<(_StubAdapter, List<bool?>)> _openSheet(
  WidgetTester tester, {
  required Map<String, dynamic> me,
  int status = 200,
}) async {
  final adapter = _StubAdapter(status: status);
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example.test/api',
      contentType: Headers.jsonContentType,
      responseType: ResponseType.plain,
    ),
  )..httpClientAdapter = adapter;
  final profile = Profile.fromMe(UserResponse.fromJson(me));
  final results = <bool?>[];

  await tester.pumpWidget(
    RepositoryProvider(
      create: (_) => ProfileRepository.withDio(dio),
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async =>
                  results.add(await ProfileStatusSheet.show(context, profile)),
              child: const Text('열기'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('열기'));
  await tester.pumpAndSettle();
  return (adapter, results);
}

bool _saveEnabled(WidgetTester tester) => tester
    .widget<CoworkButton>(find.widgetWithText(CoworkButton, '저장'))
    .enabled;

Finder get _messageField => find.descendant(
  of: find.widgetWithText(CoworkTextField, '상태 메시지'),
  matching: find.byType(EditableText),
);

void main() {
  testWidgets('고른 상태가 없으면 상태를 고르기 전까지 저장할 수 없다', (tester) async {
    final (adapter, results) = await _openSheet(
      tester,
      me: {'status': 'online', 'custom_status': null},
    );

    expect(
      _saveEnabled(tester),
      isFalse,
      reason: '서버가 custom_status 를 필수로 받는다',
    );

    await tester.tap(find.text('방해 금지'));
    await tester.pump();
    await tester.enterText(_messageField, '집중 중');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    final request = adapter.requests.single;
    expect('${request.method} ${request.path}', 'PATCH /users/me/status');
    expect(request.data, {
      'custom_status': 'DO_NOT_DISTURB',
      'message': '집중 중',
    });
    expect(results, [true], reason: '저장하면 닫히며 프로필을 다시 읽게 한다');
  });

  testWidgets('고른 상태와 메시지로 열리고, 메시지를 비우면 null 로 지운다', (tester) async {
    final (adapter, _) = await _openSheet(
      tester,
      me: {
        'status': 'online',
        'custom_status': 'ONLINE',
        'status_message': 'PR 리뷰 환영',
      },
    );

    expect(_saveEnabled(tester), isTrue);
    expect(find.text('PR 리뷰 환영'), findsOneWidget);

    await tester.enterText(_messageField, '');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(adapter.requests.single.data, {
      'custom_status': 'ONLINE',
      'message': null,
    });
  });

  testWidgets('저장이 실패하면 시트를 닫지 않고 서버 사유를 띄운다', (tester) async {
    final (_, results) = await _openSheet(
      tester,
      me: {'status': 'online', 'custom_status': 'ONLINE'},
      status: 400,
    );

    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(find.text('(400) 상태는 30자까지예요.'), findsOneWidget);
    expect(find.text('상태 설정'), findsOneWidget, reason: '실패했는데 닫히면 저장된 줄 안다');
    expect(results, isEmpty);
  });
}
