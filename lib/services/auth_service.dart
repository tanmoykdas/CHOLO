/// Simple authentication stub service. Replace with real backend integration.
class AuthService {
  Future<String?> login(String email, String password) async {
    if (email == "test@example.com" && password == "password123") {
      return "Login Successful";
    }
    return "Invalid email or password";
  }

  Future<String?> register(String email, String password, String name) async {
    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
      return "Registration Successful";
    }
    return "Please fill in all fields";
  }

  Future<String?> signOut() async {
    return "Logged out successfully";
  }
}
