import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/ride_offering_screen.dart';
import 'screens/ride_search_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHOLO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: HomeScreen(),
      routes: {
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegistrationScreen(),
        '/offer': (_) => RideOfferingScreen(),
        '/search': (_) => RideSearchScreen(),
        '/profile': (_) => ProfileScreen(),
      },
    );
  }
}
