import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String name = "John Doe";  // Dummy data (you will replace this with actual data)
  final String email = "john.doe@example.com";  // Dummy data
  final String universityEmail = "john.doe@university.edu";  // Dummy data

  // Function to handle log out
  void _logout(BuildContext context) {
    // Implement logout functionality (e.g., Firebase auth sign out)
    print("User logged out");
    Navigator.pop(context);  // Navigate back to the previous screen (or login screen)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.black,  // Customize the app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Profile Picture (You can later add an image here)
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blueAccent,
                child: Text(
                  name[0],  // Display the first letter of the name
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Display user information
              Text(
                'Name: $name',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Email: $email',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'University Email: $universityEmail',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 40),
              // Edit Profile Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to the profile edit screen (to be created later)
                  print("Edit Profile Pressed");
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shadowColor: Colors.black.withOpacity(0.3),
                  elevation: 8,
                ),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 15),
              // Log Out Button
              ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shadowColor: Colors.black.withOpacity(0.3),
                  elevation: 8,
                ),
                child: Text(
                  'Log Out',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
