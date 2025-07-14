import 'package:flutter_test/flutter_test.dart';
import 'package:acquisitionpro/main.dart';

void main() {
  testWidgets('My app has a title', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const AcqAdvantageApp());

    // Check if the app contains expected elements
    expect(find.text('ACCOUNT LOGIN'), findsOneWidget);
  });
}
