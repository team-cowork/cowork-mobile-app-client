import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildButton(CoworkButton button) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: button)),
    );
  }

  group('CoworkButton', () {
    testWidgets('matches Figma size tokens', (tester) async {
      await tester.pumpWidget(
        buildButton(
          const CoworkButton(label: '버튼', size: CoworkButtonSize.small),
        ),
      );
      expect(tester.getSize(find.byType(CoworkButton)).height, 36);

      await tester.pumpWidget(
        buildButton(
          const CoworkButton(label: '버튼', size: CoworkButtonSize.medium),
        ),
      );
      expect(tester.getSize(find.byType(CoworkButton)).height, 44);

      await tester.pumpWidget(
        buildButton(
          const CoworkButton(label: '버튼', size: CoworkButtonSize.large),
        ),
      );
      expect(tester.getSize(find.byType(CoworkButton)).height, 52);
    });

    testWidgets('uses semantic color tokens for fill brand button', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildButton(
          const CoworkButton(label: '버튼', color: CoworkButtonColor.brand),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(CoworkButton),
          matching: find.byType(Material),
        ),
      );
      final text = tester.widget<Text>(find.text('버튼'));

      expect(material.color, AppColors.lightColorScheme.primary);
      expect(text.style?.color, AppColors.lightColorScheme.onPrimary);
      expect(text.style?.fontSize, AppFont.labelS.fontSize);
      expect(text.style?.fontWeight, AppFont.labelS.fontWeight);
    });

    testWidgets('uses weak danger color tokens', (tester) async {
      await tester.pumpWidget(
        buildButton(
          const CoworkButton(
            label: '버튼',
            variant: CoworkButtonVariant.weak,
            color: CoworkButtonColor.danger,
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(CoworkButton),
          matching: find.byType(Material),
        ),
      );
      final text = tester.widget<Text>(find.text('버튼'));

      expect(material.color, AppColors.lightColorScheme.errorContainer);
      expect(text.style?.color, AppColors.lightColorScheme.onErrorContainer);
    });

    testWidgets('does not call callback when disabled', (tester) async {
      var pressed = 0;

      await tester.pumpWidget(
        buildButton(
          CoworkButton(label: '버튼', enabled: false, onPressed: () => pressed++),
        ),
      );

      await tester.tap(find.byType(CoworkButton));
      expect(pressed, 0);
    });
  });
}
