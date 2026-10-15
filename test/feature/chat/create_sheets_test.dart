import 'dart:async';

import 'package:cowork_app/feature/chat/presentation/views/chat_view.dart';
import 'package:cowork_app/feature/chat/presentation/widgets/create_sheets.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_test_server.dart';

void main() {
  // 기본 800x600 뷰에서는 시트 하단 CTA가 화면 밖이라 폰 크기로 맞춘다.
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(400, 900);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  Future<void> pumpChat(WidgetTester tester, FakeChatServer server) async {
    await tester.pumpWidget(
      chatTestApp(server, theme: AppTheme.dark(), home: const ChatView()),
    );
    await tester.pumpAndSettle();
  }

  /// 팀 이름 → 팀 메뉴 → `채널 만들기` 로 새 채널 시트를 연다.
  Future<void> tapCreateChannel(WidgetTester tester) async {
    await tester.tap(find.text('코워크'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('채널 만들기'));
    await tester.pumpAndSettle();
  }

  /// 새 채널 시트를 열고 이름을 넣는다.
  Future<void> openChannelSheet(WidgetTester tester, String name) async {
    await tapCreateChannel(tester);
    await tester.enterText(find.byType(TextFormField), name);
    await tester.pumpAndSettle();
  }

  final submit = find.widgetWithText(CoworkButton, '채널 만들기');
  final submitting = find.widgetWithText(CoworkButton, '채널 생성 중…');

  testWidgets('새 채널 시트에서 유형·공개 범위를 고르고 이름이 있어야 만들 수 있다', (tester) async {
    final server = FakeChatServer();
    await pumpChat(tester, server);

    await tapCreateChannel(tester);

    CoworkOptionCard typeOf(String label) =>
        tester.widget(find.widgetWithText(CoworkOptionCard, label));
    SelectableCard visibilityOf(String label) =>
        tester.widget(find.widgetWithText(SelectableCard, label));

    // 기본값은 일반 채팅 · 공개.
    expect(typeOf('일반 채팅').selected, isTrue);
    expect(visibilityOf('🌐 공개').selected, isTrue);

    await tester.tap(find.widgetWithText(CoworkOptionCard, '음성'));
    await tester.tap(find.widgetWithText(SelectableCard, '🔒 비공개'));
    await tester.pumpAndSettle();

    expect(typeOf('일반 채팅').selected, isFalse);
    expect(typeOf('음성').selected, isTrue);
    expect(visibilityOf('🌐 공개').selected, isFalse);
    expect(visibilityOf('🔒 비공개').selected, isTrue);

    // 이름이 비면 CTA 비활성.
    expect(tester.widget<CoworkButton>(submit).enabled, isFalse);

    await tester.enterText(find.byType(TextFormField), '배포-알림');
    await tester.pumpAndSettle();
    expect(tester.widget<CoworkButton>(submit).enabled, isTrue);

    await tester.tap(submit);
    await tester.pumpAndSettle();

    // 고른 값 그대로 지금 보고 있는 팀에 만들고, 시트를 닫은 뒤 목록 끝에 붙인다.
    expect(server.created.single, {
      'teamId': 1,
      'name': '배포-알림',
      'type': 'VOICE',
      'viewType': 'VOICE',
      'isPrivate': true,
    });
    expect(find.text('채널 만들기'), findsNothing);
    expect(find.text('배포-알림'), findsOneWidget);
    expect(find.text('#배포-알림 채널을 만들었어요.'), findsOneWidget);
  });

  testWidgets('만드는 동안은 버튼·입력·닫기가 잠기고, 응답이 오면 닫힌다', (tester) async {
    final gate = Completer<void>();
    final server = FakeChatServer()..createGate = gate.future;
    await pumpChat(tester, server);
    await openChannelSheet(tester, '새-채널');

    await tester.tap(submit);
    await tester.pump();

    expect(tester.widget<CoworkButton>(submitting).enabled, isFalse);
    expect(
      tester.widget<CoworkTextField>(find.byType(CoworkTextField)).enabled,
      isFalse,
    );
    expect(
      tester
          .widget<CoworkIconButton>(
            find.widgetWithIcon(CoworkIconButton, AppIcon.close),
          )
          .onPressed,
      isNull,
    );

    // 뒤로 가기와 바깥(배리어) 탭으로도 닫히지 않는다.
    await tester.binding.handlePopRoute();
    await tester.tapAt(const Offset(200, 10));
    // 닫히는 중이면 애니메이션이 끝날 때까지 돌려, 정말 남아 있는지 본다.
    await tester.pumpAndSettle();
    expect(submitting, findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();

    expect(submitting, findsNothing);
    expect(find.text('새-채널'), findsOneWidget);
  });

  testWidgets('생성이 실패하면 시트에 생성 실패와 사유를 보여주고 입력값을 남긴다', (tester) async {
    final server = FakeChatServer()
      ..failCreate = const ServerFailure(403, '팀 멤버만 접근할 수 있습니다.');
    await pumpChat(tester, server);
    await openChannelSheet(tester, '새-채널');

    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('채널을 만들지 못했어요'), findsOneWidget);
    expect(find.text('(403) 팀 멤버만 접근할 수 있습니다.'), findsOneWidget);
    expect(find.textContaining('팀 목록'), findsNothing);
    // 시트는 그대로 열려 있고, 다시 누를 수 있다.
    expect(find.text('새-채널'), findsOneWidget);
    expect(tester.widget<CoworkButton>(submit).enabled, isTrue);

    server.failCreate = null;
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('채널을 만들지 못했어요'), findsNothing);
    expect(find.text('채널 만들기'), findsNothing);
    expect(server.created, hasLength(1));
  });

  group('새 팀 시트', () {
    final teamName = find.widgetWithText(CoworkTextField, '팀 이름');
    final teamDescription = find.widgetWithText(CoworkTextField, '팀 설명');
    final createTeam = find.widgetWithText(CoworkButton, '팀 만들기');

    testWidgets('팀 목록 끝 + 로 팀을 만들면 그 팀으로 옮긴다', (tester) async {
      final server = FakeChatServer();
      await pumpChat(tester, server);

      await tester.tap(find.bySemanticsLabel('새 팀'));
      await tester.pumpAndSettle();

      // 이름이 비면 만들 수 없다.
      expect(tester.widget<CoworkButton>(createTeam).enabled, isFalse);

      await tester.enterText(teamName, '  백엔드팀  ');
      await tester.enterText(teamDescription, '서버 개발');
      await tester.pumpAndSettle();
      await tester.tap(createTeam);
      await tester.pumpAndSettle();

      expect(server.createdTeams.single, {
        'name': '백엔드팀',
        'description': '서버 개발',
      });
      // 새 팀은 채널이 없다. 전 팀의 채널이 남아 있으면 안 된다.
      expect(find.text('백엔드팀'), findsOneWidget);
      expect(find.text('일반'), findsNothing);
      expect(find.text('백엔드팀 팀을 만들었어요.'), findsOneWidget);
    });

    testWidgets('설명을 비우면 description 을 보내지 않는다', (tester) async {
      final server = FakeChatServer();
      await pumpChat(tester, server);

      await tester.tap(find.bySemanticsLabel('새 팀'));
      await tester.pumpAndSettle();
      await tester.enterText(teamName, '디자인');
      await tester.enterText(teamDescription, '   ');
      await tester.pumpAndSettle();
      await tester.tap(createTeam);
      await tester.pumpAndSettle();

      expect(server.createdTeams.single, {'name': '디자인'});
    });

    testWidgets('팀이 없는 빈 화면에서 팀을 만들면 바로 그 팀 홈이 된다', (tester) async {
      final server = FakeChatServer(teams: []);
      await pumpChat(tester, server);

      await tester.tap(createTeam);
      await tester.pumpAndSettle();
      await tester.enterText(teamName, '첫 팀');
      await tester.pumpAndSettle();
      await tester.tap(createTeam.last);
      await tester.pumpAndSettle();

      expect(find.text('아직 속한 팀이 없어요'), findsNothing);
      expect(find.text('첫 팀'), findsOneWidget);
      expect(find.bySemanticsLabel('새 팀'), findsOneWidget);
    });

    testWidgets('팀 생성이 실패하면 시트에 팀 생성 실패와 사유를 보여준다', (tester) async {
      final server = FakeChatServer()
        ..failCreateTeam = const ServerFailure.offline();
      await pumpChat(tester, server);

      await tester.tap(find.bySemanticsLabel('새 팀'));
      await tester.pumpAndSettle();
      await tester.enterText(teamName, '백엔드팀');
      await tester.pumpAndSettle();
      await tester.tap(createTeam);
      await tester.pumpAndSettle();

      expect(find.text('팀을 만들지 못했어요'), findsOneWidget);
      expect(find.text('네트워크에 연결할 수 없습니다.'), findsOneWidget);
      // 시트 뒤 홈의 `채널` 그룹 헤더는 빼고 시트 안만 본다.
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.textContaining('채널'),
        ),
        findsNothing,
      );
      // 홈은 원래 팀 그대로다.
      expect(find.text('코워크'), findsOneWidget);
    });
  });

  testWidgets('새 프로젝트 시트에서 템플릿을 고르고 이름이 있어야 만들 수 있다', (tester) async {
    await pumpChat(tester, FakeChatServer());

    await tester.tap(find.text('코워크'));
    await tester.pumpAndSettle();
    // 타이틀 탭은 팀 메뉴를 열고, 프로젝트 시트는 그 안에서 들어간다.
    await tester.tap(find.text('카테고리 만들기'));
    await tester.pumpAndSettle();

    SelectableCard templateOf(String label) =>
        tester.widget(find.widgetWithText(SelectableCard, label));

    // 기본 선택은 첫 템플릿, 탭하면 선택이 옮겨간다.
    expect(templateOf('개발 프로젝트').selected, isTrue);
    // 빈 프로젝트만 채널 칩 줄이 없다.
    expect(find.text('# 백엔드'), findsOneWidget);
    expect(find.text('채널 없이 시작'), findsOneWidget);

    await tester.tap(find.widgetWithText(SelectableCard, '운영 프로젝트'));
    await tester.pumpAndSettle();

    expect(templateOf('개발 프로젝트').selected, isFalse);
    expect(templateOf('운영 프로젝트').selected, isTrue);

    final button = find.widgetWithText(CoworkButton, '프로젝트 만들기');
    expect(tester.widget<CoworkButton>(button).enabled, isFalse);

    await tester.enterText(find.byType(TextFormField), '마케팅');
    await tester.pumpAndSettle();
    expect(tester.widget<CoworkButton>(button).enabled, isTrue);

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('프로젝트 만들기'), findsNothing);
  });
}
