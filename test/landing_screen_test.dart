import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cholo/main.dart';
import 'package:provider/provider.dart';
import 'package:cholo/core/providers/auth_provider.dart';
import 'package:cholo/core/providers/ride_provider.dart';

void main() {
  testWidgets('Landing shows CHOLO title', (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
      ],
      child: const MaterialApp(home: LandingScreen()),
    ));
    expect(find.text('CHOLO'), findsOneWidget);
  });
}
