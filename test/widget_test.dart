import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:car_sell/main.dart';

void main() {
  testWidgets('App launch smoke test', (WidgetTester tester) async {
    // Build our app using MaterialApp wrapping SplashPage directly to avoid Firebase init in tests.
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));

    // Verify that the Splash screen title is rendered
    expect(find.text('Motexa'), findsOneWidget);
  });
}
