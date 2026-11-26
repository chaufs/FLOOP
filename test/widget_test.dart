import 'package:flutter_test/flutter_test.dart';
import 'package:granadafinalproject/main.dart';

void main() {
  testWidgets('Floop smoke test', (WidgetTester tester) async {
    // Build Floop app and trigger a frame.
    await tester.pumpWidget(const FloopApp());
    await tester.pumpAndSettle();

    // Verify initial screen displays 'Your locations'
    expect(find.text('Your locations'), findsOneWidget);
  });
}
