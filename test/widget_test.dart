import 'package:flutter_test/flutter_test.dart';
import 'package:acquisitionpro/main.dart'; // make sure this import points to your main app file

void main() {
  testWidgets('My app has a title', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const AcquisitionProApp()); // replace with your actual app class name

    // Check if the app contains any widgets or text you expect.
    // For example, if your app has a title somewhere, you can look for it:
    expect(find.text('Some title or text in your app'), findsOneWidget);
  });
}