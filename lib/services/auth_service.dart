/// Simple in-memory authentication stub (no backend).
class AuthService {
  // For demo: single hard-coded credential.
  static const _demoEmail = 'test@example.com';
  static const _demoPassword = 'password123';

  Future<String> login(String email, String password) async {
    if (email == _demoEmail && password == _demoPassword) {
      return 'Login Successful';
    }
    return 'Invalid email or password';
  }

  Future<String> register(String email, String password, String name) async {
    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
      // Accept any non-empty input (no persistence).
      return 'Registration Successful';
    }
    return 'Please fill in all fields';
  }

  Future<String> signOut() async => 'Logged out successfully';
}
