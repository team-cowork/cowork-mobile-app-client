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
}
