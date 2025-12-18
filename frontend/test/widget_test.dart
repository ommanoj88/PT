// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vibecheck/main.dart';

void main() {
  testWidgets('VibeCheck app starts and shows loading or login', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VibeCheckApp());

    // The app should show either loading indicator or VibeCheck text
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
