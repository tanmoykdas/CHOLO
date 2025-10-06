import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CHOLO - Home'),
        backgroundColor: Colors.black,  // Customize the app bar color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // App Name with Stylish Font
            Text(
              'CHOLO',  // The app name
              style: TextStyle(
                fontSize: 80,  // Larger font size for better visibility
                fontWeight: FontWeight.w900,  // Bold text
                fontFamily: 'Roboto',  // You can change the font family here
                color: Colors.black,  // Black color for the text
              ),
            ),
            const SizedBox(height: 8),
            // Welcome Text
            const Text(
              'Welcome to CHOLO!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 30),
            // Brief Description of the App
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'CHOLO is a ride-sharing app designed exclusively for university students. '
                    'Find affordable and safe transportation with ease.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            SizedBox(height: 40),
            // Login and Registration buttons with a more realistic design
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,  // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),  // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shadowColor: Colors.black.withOpacity(0.3),
                elevation: 8,
              ),
              child: Text(
                'Login',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => RegistrationScreen()));
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.greenAccent,  // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),  // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shadowColor: Colors.black.withOpacity(0.3),
                elevation: 8,
              ),
              child: Text(
                'Register',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
