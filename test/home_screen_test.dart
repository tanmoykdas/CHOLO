import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cholo/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen has "CHOLO" logo and title', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));
    expect(find.text('CHOLO'), findsOneWidget);
    expect(find.text('Welcome to CHOLO!'), findsOneWidget);
  });

  testWidgets('HomeScreen has Login and Register buttons', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('Login button press should trigger appropriate action', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));
    final loginButton = find.text('Login');
    await tester.tap(loginButton);
    await tester.pump();
    // Navigation test could be added when routes are mocked.
  });

  testWidgets('Register button press should trigger appropriate action', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));
    final registerButton = find.text('Register');
    await tester.tap(registerButton);
    await tester.pump();
  });
}
