import 'package:flutter_test/flutter_test.dart';
import 'package:your_project/services/auth_service.dart';  // Import your AuthService

void main() {
  // Initialize the AuthService instance
  final authService = AuthService();

  group('AuthService Tests', () {
    test('Login with correct credentials', () async {
      final email = 'test@example.com';
      final password = 'password123';

      final result = await authService.login(email, password);

      expect(result, 'Login Successful');
    });

    test('Login with incorrect credentials', () async {
      final email = 'wrong@example.com';
      final password = 'wrongpassword';

      final result = await authService.login(email, password);

      expect(result, 'Invalid email or password');
    });

    test('Register with valid details', () async {
      final email = 'newuser@example.com';
      final password = 'newpassword';
      final name = 'New User';

      final result = await authService.register(email, password, name);

      expect(result, 'Registration Successful');
    });

    test('Register with empty fields', () async {
      final email = '';
      final password = '';
      final name = '';

      final result = await authService.register(email, password, name);

      expect(result, 'Please fill in all fields');
    });

    test('Logout', () async {
      final result = await authService.signOut();

      expect(result, 'Logged out successfully');
    });
  });
}
