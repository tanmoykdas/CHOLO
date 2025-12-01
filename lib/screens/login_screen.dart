import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _showResendVerification = false;

  Future<void> _handleLogin() async {
    if (_email.isEmpty || _password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password';
        _showResendVerification = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showResendVerification = false;
    });

    try {
      await context.read<AuthProvider>().login(_email, _password);
      if (mounted && context.read<AuthProvider>().isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Your password or email is wrong. Please correct and try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      final errorString = e.toString();
      setState(() {
        // Check if error is about email verification
        if (errorString.contains('email-not-verified') || 
            errorString.contains('verify your email')) {
          _errorMessage = '⚠️ Your email is not verified yet!\n\nPlease check your inbox and click the verification link. Then try logging in again.';
          _showResendVerification = true;
        } else if (errorString.contains('user-not-found')) {
          _errorMessage = 'No account found with this email. Please sign up first.';
        } else if (errorString.contains('wrong-password') || errorString.contains('invalid-credential')) {
          _errorMessage = 'Incorrect email or password. Please try again.';
        } else if (errorString.contains('invalid-email')) {
          _errorMessage = 'Invalid email format. Please check your email.';
        } else if (errorString.contains('too-many-requests')) {
          _errorMessage = 'Too many failed attempts. Please try again later.';
        } else {
          _errorMessage = 'Login failed. Please check your credentials and try again.';
        }
        _isLoading = false;
      });
    }
  }
  
  Future<void> _resendVerification() async {
    if (_email.isEmpty || _password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email and password first';
        _isLoading = false;
      });
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      await context.read<AuthProvider>().resendVerificationEmail(_email, _password);
      if (mounted) {
        setState(() {
          _errorMessage = '✅ Verification email sent! Please check your inbox and spam folder.';
          _showResendVerification = false;
          _isLoading = false;
        });
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Email Sent'),
              ],
            ),
            content: Text(
              'A new verification email has been sent to $_email. Please check your inbox and spam folder.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to resend verification email. Please check your credentials.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  
                  // Simple Car Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Login Form
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (v) => _email = v!.trim(),
                    onChanged: (v) => _email = v.trim(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                    ),
                    obscureText: true,
                    onSaved: (v) => _password = v!.trim(),
                    onChanged: (v) => _password = v.trim(),
                  ),
                  
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade800),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Login Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  // Resend Verification Button
                  if (_showResendVerification) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _isLoading ? null : _resendVerification,
                      icon: const Icon(Icons.email, size: 18),
                      label: const Text('Resend Verification Email'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
