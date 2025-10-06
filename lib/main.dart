import 'package:flutter/material.dart';
import 'screens/home_screen.dart';  // Make sure home_screen.dart exists in lib/screens/

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHOLO',
      theme: ThemeData(
        primarySwatch: Colors.blue,  // Customize theme as needed
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),  // Load HomeScreen as the starting screen
    );
  }
}
