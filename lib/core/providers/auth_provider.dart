import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final _service = AuthService();
  CholoUser? _user;
  bool _loading = false;
  String? _error;

  CholoUser? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _service.userChanges().listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String universityEmail,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _service.register(
        name: name,
        email: email,
        password: password,
        universityEmail: universityEmail,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _service.login(email, password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
  }

}
