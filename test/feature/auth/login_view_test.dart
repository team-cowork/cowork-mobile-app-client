import 'package:cowork_app/feature/auth/presentation/views/login_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoginView renders title, subtitle and login button', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: LoginView(onDataGsmLogin: () => tapped = true),
      ),
    );

    expect(find.text('Cowork'), findsOneWidget);
    expect(find.text('팀 협업을 위한 올인원 워크스페이스'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('DataGSM으로 로그인'));
    expect(tapped, isTrue);
  });

  testWidgets('로그인 버튼의 아이콘+문구는 버튼 안에서 가운데 정렬된다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const LoginView()),
    );

    final button = tester.getRect(find.byType(InkWell));
    final content = tester
        .getRect(find.text('DataGSM으로 로그인'))
        .expandToInclude(
          tester.getRect(
            // 화면 위쪽 Cowork 로고와 구분해 버튼 안 DataGSM 아이콘만 잡는다.
            find.descendant(
              of: find.byType(InkWell),
              matching: find.byType(Image),
            ),
          ),
        );

    expect(content.center.dx, moreOrLessEquals(button.center.dx, epsilon: 1));
  });
}
