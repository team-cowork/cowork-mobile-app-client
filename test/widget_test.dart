import 'package:cowork_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HomePage());

    // Verify app builds successfully
    expect(find.byType(HomePage), findsOneWidget);
  });
}
