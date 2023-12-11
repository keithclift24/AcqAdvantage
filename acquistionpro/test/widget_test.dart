import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acquisitionpro/src/main.dart'; // Correct the import path

void main() {
  testWidgets('AcquisitionProApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AcquisitionProApp());

    // Verify that the login page is shown.
    expect(find.text('Login to Acquisition Pro'), findsOneWidget);
    expect(find.text('Login Page Content Goes Here'), findsOneWidget);

    // Add more tests specific to your login page here.
    // For example, you might want to check for TextFields, Buttons, etc.
  });
}