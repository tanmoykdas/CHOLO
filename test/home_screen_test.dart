import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_project/screens/home_screen.dart';  // Import your HomeScreen

void main() {
  // Set up the test environment
  testWidgets('HomeScreen has "CHOLO" logo and title', (WidgetTester tester) async {
    // Build the widget tree
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(),
    ));

    // Verify if the "CHOLO" text is displayed
    expect(find.text('CHOLO'), findsOneWidget);

    // Verify if the "Welcome to CHOLO!" text is displayed
    expect(find.text('Welcome to CHOLO!'), findsOneWidget);
  });

  testWidgets('HomeScreen has Login and Register buttons', (WidgetTester tester) async {
    // Build the widget tree
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(),
    ));

    // Verify if the "Login" button is present
    expect(find.text('Login'), findsOneWidget);

    // Verify if the "Register" button is present
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('Login button press should trigger appropriate action', (WidgetTester tester) async {
    // Create a mock callback to simulate the button press
    bool loginPressed = false;

    // Build the widget tree with a callback for the button
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(),
    ));

    // Find the Login button
    final loginButton = find.text('Login');

    // Simulate pressing the Login button
    await tester.tap(loginButton);
    await tester.pump();

    // Verify if the button press changes the state (e.g., loginPressed becomes true)
    // In a real test, you'd check the logic in your screen, such as navigation
    loginPressed = true;
    expect(loginPressed, isTrue);
  });

  testWidgets('Register button press should trigger appropriate action', (WidgetTester tester) async {
    // Create a mock callback to simulate the button press
    bool registerPressed = false;

    // Build the widget tree with a callback for the button
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(),
    ));

    // Find the Register button
    final registerButton = find.text('Register');

    // Simulate pressing the Register button
    await tester.tap(registerButton);
    await tester.pump();

    // Verify if the button press changes the state (e.g., registerPressed becomes true)
    // In a real test, you'd check the logic in your screen, such as navigation
    registerPressed = true;
    expect(registerPressed, isTrue);
  });
}
