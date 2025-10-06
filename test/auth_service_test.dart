import 'package:flutter_test/flutter_test.dart';
import 'package:cholo/services/auth_service.dart';

void main() {
  final authService = AuthService();

  group('AuthService Tests', () {
    test('Login with correct credentials', () async {
      final result = await authService.login('test@example.com', 'password123');
      expect(result, 'Login Successful');
    });

    test('Login with incorrect credentials', () async {
      final result = await authService.login('wrong@example.com', 'wrongpassword');
      expect(result, 'Invalid email or password');
    });

    test('Register with valid details', () async {
      final result = await authService.register('newuser@example.com', 'newpassword', 'New User');
      expect(result, 'Registration Successful');
    });

    test('Register with empty fields', () async {
      final result = await authService.register('', '', '');
      expect(result, 'Please fill in all fields');
    });

    test('Logout', () async {
      final result = await authService.signOut();
      expect(result, 'Logged out successfully');
    });
  });
}
