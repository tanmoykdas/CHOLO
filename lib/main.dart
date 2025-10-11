import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/ride_provider.dart';
import 'core/services/notification_service.dart';
import 'core/models/ride_model.dart';
import 'core/models/user_model.dart';
import 'core/services/ride_service.dart';
import 'core/services/rating_service.dart';
import 'core/models/rating_model.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Capture Flutter framework errors into a visible widget instead of silent white screen
  ErrorWidget.builder = (details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('CHOLO Crash', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(details.exceptionAsString(), style: const TextStyle(color: Colors.red, fontSize: 12)),
                const SizedBox(height: 12),
                Text(details.stack.toString(), style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  };

  runApp(const _BootstrapApp());
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();
  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  bool _ready = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    debugPrint('[BOOT] Starting initialization');
    try {
      // If you have firebase_options.dart, replace with:
      // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      debugPrint('[BOOT] Firebase initialized');
      await NotificationService().init();
      debugPrint('[BOOT] Notifications initialized');
      setState(() => _ready = true);
    } catch (e, st) {
      debugPrint('[BOOT][ERROR] Initialization failed: $e\n$st');
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      // Special handling: if running on web and placeholder config still present, show guidance.
      final placeholderWeb = DefaultFirebaseOptions.webConfigIsPlaceholder;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Initialization Error', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('$_error', style: const TextStyle(color: Colors.red)),
                  if (placeholderWeb) ...[
                    const SizedBox(height: 16),
                    const Text('Web config placeholders detected. Fix steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('1. In Firebase Console > Project settings > Add app > Web.\n'
                        '2. Register (nickname optional), enable Hosting not required.\n'
                        '3. Copy the config OR run: flutterfire configure --platforms=web,android\n'
                        '4. Replace firebase_options.dart (auto-generated) and re-run.'),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _error = null);
                      _init();
                    },
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() => _ready = true),
                    child: const Text('Continue without Firebase (demo)'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (!_ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    }
    return const CholoApp();
  }
}

class CholoApp extends StatelessWidget {
  const CholoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Colors.grey,
        surface: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.black,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CHOLO',
        theme: theme,
        initialRoute: '/',
        routes: {
          '/': (_) => const LandingScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/offer': (_) => const OfferRideScreen(),
          '/search': (_) => const SearchRideScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/my_offered': (_) => const MyOfferedRidesScreen(),
          '/my_booked': (_) => const MyBookedRidesScreen(),
          '/view_ratings': (_) => const ViewRatingsScreen(),
        },
      ),
    );
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoggedIn) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/home'));
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // CHOLO Logo with Glow Effect
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // CHOLO Title - Professional
                const Text(
                  'CHOLO',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Login Button - Professional Design
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Create Account Button - Outlined Design
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // How CHOLO Works Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade800, width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'How CHOLO Works?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade200,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildFeatureStep(
                        icon: Icons.add_circle_outline,
                        number: '1',
                        title: 'Share Your Ride',
                        description: 'Offer empty seats in your vehicle and earn money',
                      ),
                      const SizedBox(height: 20),
                      
                      _buildFeatureStep(
                        icon: Icons.search,
                        number: '2',
                        title: 'Find Rides',
                        description: 'Search and book available rides to your destination',
                      ),
                      const SizedBox(height: 20),
                      
                      _buildFeatureStep(
                        icon: Icons.star_outline,
                        number: '3',
                        title: 'Rate & Review',
                        description: 'Build trust and reputation in the community',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Benefits Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade900, Colors.grey.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Why Choose CHOLO?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildBenefit(
                        icon: Icons.attach_money,
                        title: 'Save Money',
                        description: 'Split travel costs with fellow students',
                      ),
                      const SizedBox(height: 12),
                      
                      _buildBenefit(
                        icon: Icons.group,
                        title: 'Build Network',
                        description: 'Connect with university community',
                      ),
                      const SizedBox(height: 12),
                      
                      _buildBenefit(
                        icon: Icons.verified_user,
                        title: 'Safe & Trusted',
                        description: 'University email verification & ratings',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Who Can Use Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Who Can Use CHOLO?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school, color: Colors.white70, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'University Students Only',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureStep({
    required IconData icon,
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
        Icon(icon, color: Colors.grey.shade600, size: 28),
      ],
    );
  }
  
  Widget _buildBenefit({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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

  Future<void> _handleLogin() async {
    if (_email.isEmpty || _password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
      setState(() {
        _errorMessage = 'Your password or email is wrong. Please correct and try again.';
        _isLoading = false;
      });
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _universityEmail = '';
  String _password = '';

  bool _validUniversityEmail(String email) {
    final domains = ['pstu.ac.bd', 'bu.ac.bd', 'du.ac.bd'];
    return domains.any((d) => email.toLowerCase().endsWith(d));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                onSaved: (v) => _name = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Login Email'),
                onSaved: (v) => _email = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'University Email'),
                validator: (v) => v != null && _validUniversityEmail(v) ? null : 'Use valid university email',
                onSaved: (v) => _universityEmail = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (v) => _password = v!.trim(),
              ),
              const SizedBox(height: 24),
              if (auth.error != null) Text(auth.error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        if (!_form.currentState!.validate()) return;
                        _form.currentState!.save();
                        await context.read<AuthProvider>().register(
                              name: _name,
                              email: _email,
                              password: _password,
                              universityEmail: _universityEmail,
                            );
                        if (mounted && context.read<AuthProvider>().isLoggedIn) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                child: auth.isLoading ? const CircularProgressIndicator() : const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHOLO'),
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Please login to continue', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Section at Top
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white24,
                                backgroundImage: user.profilePictureUrl.isNotEmpty
                                    ? NetworkImage(user.profilePictureUrl)
                                    : null,
                                child: user.profilePictureUrl.isEmpty
                                    ? Text(
                                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (user.age != null || user.gender.isNotEmpty)
                                      Text(
                                        [
                                          if (user.age != null) '${user.age} years',
                                          if (user.gender.isNotEmpty) user.gender,
                                        ].join(' • '),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    if (user.universityName.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        user.universityName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 2),
                                    Text(
                                      user.universityEmail,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Rating Section
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  user.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${user.ratingCount} reviews)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Divider
                  Divider(
                    thickness: 1,
                    color: Colors.grey.shade800,
                    height: 1,
                  ),
                  
                  // Four Options in 2x2 Grid
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildGridButton(
                                context,
                                icon: Icons.directions_car,
                                title: 'Share Ride',
                                onTap: () => Navigator.pushNamed(context, '/offer'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGridButton(
                                context,
                                icon: Icons.search,
                                title: 'Book Ride',
                                onTap: () => Navigator.pushNamed(context, '/search'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildGridButton(
                                context,
                                icon: Icons.list_alt,
                                title: 'Offered Rides',
                                onTap: () => Navigator.pushNamed(context, '/my_offered'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGridButton(
                                context,
                                icon: Icons.book_online,
                                title: 'Booked Rides',
                                onTap: () => Navigator.pushNamed(context, '/my_booked'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Logout Button at Bottom
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final auth = context.read<AuthProvider>();
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGridButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OfferRideScreen extends StatefulWidget {
  const OfferRideScreen({super.key});
  @override
  State<OfferRideScreen> createState() => _OfferRideScreenState();
}

class _OfferRideScreenState extends State<OfferRideScreen> {
  final _form = GlobalKey<FormState>();
  String _vehicle = 'car';
  String _source = '';
  String _destination = '';
  int _seats = 1;
  int _price = 0;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Share Ride')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              
              // Vehicle Type
              DropdownButtonFormField<String>(
                value: _vehicle,
                decoration: InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                ),
                items: const [
                  DropdownMenuItem(value: 'car', child: Text('Car')),
                  DropdownMenuItem(value: 'bike', child: Text('Bike')),
                ],
                onChanged: (v) => setState(() => _vehicle = v!),
              ),
              
              const SizedBox(height: 20),
              
              // From (Starting Point)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'From',
                  hintText: 'Enter starting point',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                onSaved: (v) => _source = v!.trim(),
              ),
              
              const SizedBox(height: 20),
              
              // To (Destination)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'To',
                  hintText: 'Enter destination',
                  prefixIcon: const Icon(Icons.flag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                onSaved: (v) => _destination = v!.trim(),
              ),
              
              const SizedBox(height: 20),
              
              // Available Seats
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Available Seats',
                  hintText: 'Enter number of seats',
                  prefixIcon: const Icon(Icons.event_seat),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final i = int.tryParse(v ?? '');
                  if (i == null || i <= 0) {
                    return 'Enter seats > 0';
                  }
                  return null;
                },
                onSaved: (v) => _seats = int.tryParse(v ?? '1') ?? 1,
              ),
              
              const SizedBox(height: 20),
              
              // Price per Seat
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price per Seat',
                  hintText: 'Enter price',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final i = int.tryParse(v ?? '');
                  if (i == null || i < 0) {
                    return 'Enter valid price';
                  }
                  return null;
                },
                onSaved: (v) => _price = int.tryParse(v ?? '0') ?? 0,
              ),
              
              const SizedBox(height: 20),
              
              // Ride Time
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: _time);
                    if (picked != null) setState(() => _time = picked);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ride Time: ${_time.format(context)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Share Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () async {
                        if (!(_form.currentState?.validate() ?? false)) return;
                        _form.currentState!.save();
                        // Prevent sharing if source and destination are the same
                        if (_source.trim().toLowerCase() == _destination.trim().toLowerCase()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Starting point and destination cannot be the same'),
                            ),
                          );
                          return;
                        }
                        setState(() => _submitting = true);
                        try {
                          final now = DateTime.now();
                          final rideDate = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
                          final ownerId = auth!.id;
                          final ownerName = auth.name;
                          final route = '$_source to $_destination';
                          final ride = Ride(
                            id: 'temp',
                            ownerId: ownerId,
                            ownerName: ownerName,
                            vehicleType: _vehicle == 'car' ? VehicleType.car : VehicleType.bike,
                            route: route,
                            source: _source,
                            destination: _destination,
                            routeKey: Ride.buildRouteKey(_source, _destination),
                            availableSeats: _seats,
                            pricePerSeat: _price,
                            rideTime: rideDate,
                          );
                          await RideService().createRide(ride);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ride shared')));
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        } finally {
                          if (mounted) setState(() => _submitting = false);
                        }
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchRideScreen extends StatefulWidget {
  const SearchRideScreen({super.key});
  @override
  State<SearchRideScreen> createState() => _SearchRideScreenState();
}

class _SearchRideScreenState extends State<SearchRideScreen> {
  final _srcCtrl = TextEditingController();
  final _dstCtrl = TextEditingController();
  bool _hasSearched = false;
  
  @override
  Widget build(BuildContext context) {
    final rideProv = context.watch<RideProvider>();
    final auth = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Book Ride')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            
            // From Field
            TextField(
              controller: _srcCtrl,
              decoration: InputDecoration(
                labelText: 'From',
                hintText: 'Enter starting point',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade900,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // To Field
            TextField(
              controller: _dstCtrl,
              decoration: InputDecoration(
                labelText: 'To',
                hintText: 'Enter destination',
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade900,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Search Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final src = _srcCtrl.text.trim();
                  final dst = _dstCtrl.text.trim();
                  if (src.isEmpty || dst.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter both From and To locations')),
                    );
                    return;
                  }
                  if (src.toLowerCase() == dst.toLowerCase()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('From and To locations cannot be the same')),
                    );
                    return;
                  }
                  setState(() => _hasSearched = true);
                  final route = '$src to $dst';
                  context.read<RideProvider>().search(route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            if (rideProv.isLoading) const LinearProgressIndicator(),
            
            Expanded(
              child: !_hasSearched
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey.shade600),
                          const SizedBox(height: 16),
                          Text(
                            'Enter From and To locations\nto search for rides',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : rideProv.results.isEmpty && !rideProv.isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade600),
                              const SizedBox(height: 16),
                              Text(
                                'No rides found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try searching with different locations',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                      itemCount: rideProv.results.length,
                      itemBuilder: (c, i) {
                        final r = rideProv.results[i];
                        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance.collection('users').doc(r.ownerId).get(),
                          builder: (context, ownerSnap) {
                            String profilePicUrl = '';
                            String ownerName = r.ownerName;
                            double ownerRating = 0.0;
                            int ratingCount = 0;
                            
                            if (ownerSnap.hasData && ownerSnap.data!.exists) {
                              final ownerData = ownerSnap.data!.data();
                              profilePicUrl = ownerData?['profilePictureUrl'] ?? '';
                              ownerName = ownerData?['name'] ?? r.ownerName;
                              final totalRatings = (ownerData?['totalRatings'] ?? 0.0).toDouble();
                              ratingCount = (ownerData?['ratingCount'] ?? 0) as int;
                              if (ratingCount > 0) {
                                ownerRating = totalRatings / ratingCount;
                              }
                            }
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: profilePicUrl.isNotEmpty
                                      ? NetworkImage(profilePicUrl)
                                      : null,
                                  child: profilePicUrl.isEmpty
                                      ? Text(
                                          ownerName.isNotEmpty ? ownerName[0].toUpperCase() : 'U',
                                        )
                                      : null,
                                ),
                                title: Text(r.route,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text('Owner: $ownerName',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        if (ratingCount > 0) ...[
                                          const SizedBox(width: 8),
                                          const Icon(Icons.star, size: 14, color: Colors.amber),
                                          const SizedBox(width: 2),
                                          Text('${ownerRating.toStringAsFixed(1)} ($ratingCount)',
                                              style: const TextStyle(fontSize: 12)),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            '${r.rideTime.day}/${r.rideTime.month}/${r.rideTime.year} ${r.rideTime.hour.toString().padLeft(2, '0')}:${r.rideTime.minute.toString().padLeft(2, '0')}',
                                            style: const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '${r.vehicleType.name.toUpperCase()} • ${r.remainingSeats} seats • ৳${r.pricePerSeat}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            trailing: SizedBox(
                              width: 90,
                              child: ElevatedButton(
                                onPressed: r.remainingSeats == 0 || auth == null
                                    ? null
                                    : () async {
                                        final ctrl = TextEditingController(text: '1');
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Select seats'),
                                            content: TextField(
                                              controller: ctrl,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'Seats (max ${r.remainingSeats})',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Book')),
                                            ],
                                          ),
                                        );
                                        if (confirmed != true) return;
                                        final seats = int.tryParse(ctrl.text.trim()) ?? 1;
                                        if (seats < 1 || seats > r.remainingSeats) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Enter 1 to ${r.remainingSeats} seats')),
                                            );
                                          }
                                          return;
                                        }
                                        final ok = await RideService().bookRide(rideId: r.id, userId: auth.id, seats: seats);
                                        if (ok && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booked successfully')));
                                          final route = '${_srcCtrl.text.trim()} to ${_dstCtrl.text.trim()}';
                                          // Refresh search to update remaining seats
                                          // ignore: use_build_context_synchronously
                                          context.read<RideProvider>().search(route);
                                        } else if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking failed')));
                                        }
                                      },
                                    child: const Text('Book'),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showEditProfileDialog(BuildContext context, CholoUser user) async {
    final nameCtrl = TextEditingController(text: user.name);
    final ageCtrl = TextEditingController(text: user.age?.toString() ?? '');
    final universityNameCtrl = TextEditingController(text: user.universityName);
    String selectedGender = user.gender.isNotEmpty ? user.gender : 'Male';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female', 'Other'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedGender = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: universityNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'University Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final updates = <String, dynamic>{
          'name': nameCtrl.text.trim(),
          'gender': selectedGender,
          'universityName': universityNameCtrl.text.trim(),
        };
        
        final ageText = ageCtrl.text.trim();
        if (ageText.isNotEmpty) {
          updates['age'] = int.tryParse(ageText);
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .update(updates);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _uploadProfilePicture(BuildContext context, String userId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      if (!context.mounted) return;
      
      // Show loading
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Uploading...'),
            ],
          ),
        ),
      );

      try {
        print('Starting upload for user: $userId');
        
        // Upload to Firebase Storage (cross-platform)
        final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$userId.jpg');
        
        print('Reading image bytes...');
        // Read image bytes (works on all platforms)
        final bytes = await image.readAsBytes();
        print('Image size: ${bytes.length} bytes');
        
        print('Uploading to Firebase Storage...');
        // Upload with timeout
        final uploadTask = await storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Upload timeout - please check your internet connection');
          },
        );
        
        print('Getting download URL...');
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        print('Download URL: $downloadUrl');

        print('Updating Firestore...');
        // Update Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'profilePictureUrl': downloadUrl,
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Firestore update timeout');
          },
        );

        print('Upload complete!');
        
        // Close loading dialog
        navigator.pop();
        
        // Show success message
        messenger.showSnackBar(
          const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        print('Upload error: $e');
        
        // Close loading dialog
        navigator.pop();
        
        // Show error message
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Image picker error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('Not logged in'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture with Upload Button
                  Center(
                    child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white24,
                        backgroundImage: user.profilePictureUrl.isNotEmpty
                            ? NetworkImage(user.profilePictureUrl)
                            : null,
                        child: user.profilePictureUrl.isEmpty
                            ? Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18, color: Colors.black),
                            padding: EdgeInsets.zero,
                            onPressed: () => _uploadProfilePicture(context, user.id),
                          ),
                        ),
                      ),
                    ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Login Email: ${user.email}'),
                  Text('University Email: ${user.universityEmail}'),
                  if (user.age != null) Text('Age: ${user.age}'),
                  if (user.gender.isNotEmpty) Text('Gender: ${user.gender}'),
                  if (user.universityName.isNotEmpty) Text('University: ${user.universityName}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showEditProfileDialog(context, user),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                user.averageRating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(' (${user.ratingCount} reviews)', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/view_ratings', arguments: user.id),
                              child: const Text('View All Ratings'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ViewRatingsScreen extends StatelessWidget {
  const ViewRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = ModalRoute.of(context)?.settings.arguments as String?;
    
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ratings')),
        body: const Center(child: Text('Invalid user')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Ratings')),
      body: StreamBuilder<List<Rating>>(
        stream: RatingService().getRatingsForUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final ratings = snapshot.data ?? [];
          
          if (ratings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No ratings yet', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ratings.length,
            itemBuilder: (context, index) {
              final rating = ratings[index];
              final dateStr = '${rating.createdAt.day}/${rating.createdAt.month}/${rating.createdAt.year}';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              rating.fromUserName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < rating.rating ? Icons.star : Icons.star_border,
                              color: Colors.orange,
                              size: 20,
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'As ${rating.type == RatingType.asOwner ? 'Ride Owner' : 'Rider'}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      if (rating.review.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(rating.review),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        dateStr,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> _showRateBookersDialog(
  BuildContext context,
  String rideId,
  String ownerId,
  String ownerName,
) async {
  // Fetch all bookings for this ride
  final bookingsSnap = await FirebaseFirestore.instance
      .collection('bookings')
      .where('rideId', isEqualTo: rideId)
      .get();

  if (bookingsSnap.docs.isEmpty && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No bookings for this ride')),
    );
    return;
  }

  // Get unique bookers
  final bookerIds = bookingsSnap.docs
      .map((d) => d.data()['userId'] as String?)
      .whereType<String>()
      .toSet()
      .toList();

  if (bookerIds.isEmpty && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No bookers found')),
    );
    return;
  }

  // Fetch user details for bookers
  final bookers = <Map<String, String>>[];
  for (final userId in bookerIds) {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      bookers.add({
        'id': userId,
        'name': data['name'] ?? 'Unknown',
      });
    }
  }

  if (!context.mounted) return;

  // Show list of bookers to rate
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Rate Bookers'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: bookers.length,
          itemBuilder: (context, index) {
            final booker = bookers[index];
            return ListTile(
              title: Text(booker['name']!),
              trailing: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _showRatingDialogForBooker(
                    context,
                    rideId: rideId,
                    bookerId: booker['id']!,
                    bookerName: booker['name']!,
                    ownerId: ownerId,
                    ownerName: ownerName,
                  );
                },
                child: const Text('Rate'),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> _showRatingDialogForBooker(
  BuildContext context, {
  required String rideId,
  required String bookerId,
  required String bookerName,
  required String ownerId,
  required String ownerName,
}) async {
  // Check if already rated
  final alreadyRated = await RatingService().hasRated(
    fromUserId: ownerId,
    toUserId: bookerId,
    rideId: rideId,
  );

  if (alreadyRated && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You already rated $bookerName')),
    );
    return;
  }

  int rating = 5;
  final reviewCtrl = TextEditingController();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text('Rate $bookerName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was the booker?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 36,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewCtrl,
                decoration: const InputDecoration(
                  labelText: 'Review (optional)',
                  hintText: 'Share your experience...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    ),
  );

  if (confirmed == true && context.mounted) {
    final success = await RatingService().submitRating(
      fromUserId: ownerId,
      fromUserName: ownerName,
      toUserId: bookerId,
      rideId: rideId,
      rating: rating,
      review: reviewCtrl.text.trim(),
      type: RatingType.asRider,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully!')),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit rating')),
      );
    }
  }
}

class MyOfferedRidesScreen extends StatelessWidget {
  const MyOfferedRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Offered Rides')),
      body: user == null
          ? const Center(child: Text('Please login to view your offered rides'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
          .collection('rides')
          .where('ownerId', isEqualTo: user.id)
          .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No rides offered yet', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Start offering rides to help fellow students!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                final rides = docs.map((d) => Ride.fromFirestore(d)).toList()
                  ..sort((a, b) => b.rideTime.compareTo(a.rideTime));
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final ride = rides[index];
                    final timeStr = '${ride.rideTime.day}/${ride.rideTime.month}/${ride.rideTime.year} ${ride.rideTime.hour.toString().padLeft(2, '0')}:${ride.rideTime.minute.toString().padLeft(2, '0')}';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          ride.vehicleType == VehicleType.car ? Icons.directions_car : Icons.motorcycle,
                          color: Colors.white,
                        ),
                        title: Text(ride.route, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time: $timeStr'),
                            Text('Seats: ${ride.remainingSeats}/${ride.availableSeats} • Price: ৳${ride.pricePerSeat}'),
                            if (ride.bookedSeats > 0)
                              const Text('Locked after booking', style: TextStyle(color: Colors.orange)),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            if (ride.bookedSeats > 0)
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                tooltip: 'Rate bookers',
                                onPressed: () => _showRateBookersDialog(context, ride.id, user.id, user.name),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              tooltip: ride.bookedSeats > 0 ? 'Locked after booking' : 'Edit',
                              onPressed: ride.bookedSeats > 0
                                  ? null
                                  : () async {
                                      final srcCtrl = TextEditingController(text: ride.source);
                                      final dstCtrl = TextEditingController(text: ride.destination);
                                      final seatsCtrl = TextEditingController(text: ride.availableSeats.toString());
                                      final priceCtrl = TextEditingController(text: ride.pricePerSeat.toString());
                                      TimeOfDay time = TimeOfDay(hour: ride.rideTime.hour, minute: ride.rideTime.minute);
                                      final saved = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) {
                                          return StatefulBuilder(
                                            builder: (ctx, setSt) => AlertDialog(
                                              title: const Text('Edit Ride'),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextField(controller: srcCtrl, decoration: const InputDecoration(labelText: 'Starting point')),
                                                    const SizedBox(height: 8),
                                                    TextField(controller: dstCtrl, decoration: const InputDecoration(labelText: 'Destination')),
                                                    const SizedBox(height: 8),
                                                    TextField(controller: seatsCtrl, decoration: const InputDecoration(labelText: 'Available seats'), keyboardType: TextInputType.number),
                                                    const SizedBox(height: 8),
                                                    TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price per seat'), keyboardType: TextInputType.number),
                                                    const SizedBox(height: 8),
                                                    ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Text('Time: ${time.format(ctx)}'),
                                                      trailing: const Icon(Icons.access_time),
                                                      onTap: () async {
                                                        final picked = await showTimePicker(context: ctx, initialTime: time);
                                                        if (picked != null) setSt(() => time = picked);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                      if (saved == true) {
                                        try {
                                          final t = ride.rideTime;
                                          final newRideTime = DateTime(t.year, t.month, t.day, time.hour, time.minute);
                                          final ok = await RideService().updateRide(
                                            ride.id,
                                            source: srcCtrl.text.trim(),
                                            destination: dstCtrl.text.trim(),
                                            availableSeats: int.tryParse(seatsCtrl.text.trim()),
                                            pricePerSeat: int.tryParse(priceCtrl.text.trim()),
                                            rideTime: newRideTime,
                                          );
                                          if (ok && context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ride updated')));
                                          } else if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update failed')));
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                          }
                                        }
                                      }
                                    },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: ride.bookedSeats > 0 ? 'Cannot delete after booking' : 'Delete',
                              onPressed: ride.bookedSeats > 0
                                  ? null
                                  : () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Ride'),
                                          content: const Text('Are you sure you want to delete this ride offer?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        try {
                                          await FirebaseFirestore.instance.collection('rides').doc(ride.id).delete();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Ride deleted successfully')),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error deleting ride: $e')),
                                            );
                                          }
                                        }
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

Future<void> _showRatingDialog(
  BuildContext context, {
  required String bookingId,
  required String rideId,
  required String ownerId,
  required String ownerName,
  required String userId,
  required String userName,
}) async {
  int rating = 5;
  final reviewCtrl = TextEditingController();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text('Rate $ownerName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was your ride?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 36,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewCtrl,
                decoration: const InputDecoration(
                  labelText: 'Review (optional)',
                  hintText: 'Share your experience...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    ),
  );

  if (confirmed == true && context.mounted) {
    final success = await RatingService().submitRating(
      fromUserId: userId,
      fromUserName: userName,
      toUserId: ownerId,
      rideId: rideId,
      rating: rating,
      review: reviewCtrl.text.trim(),
      type: RatingType.asOwner,
    );

    if (success && context.mounted) {
      // Mark booking as completed and rated
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'isCompleted': true, 'ratingGiven': true});
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully!')),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit rating')),
      );
    }
  }
}

class MyBookedRidesScreen extends StatelessWidget {
  const MyBookedRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Booked Rides')),
      body: user == null
          ? const Center(child: Text('Please login to view your booked rides'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.id)
          .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final bookingDocs = snapshot.data?.docs ?? [];
                if (bookingDocs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book_online, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No rides booked yet', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Book your first ride to get started!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                bookingDocs.sort((a, b) {
                  final at = (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
                  final bt = (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
                  return bt.compareTo(at);
                });
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookingDocs.length,
                  itemBuilder: (context, index) {
                    final bookingDoc = bookingDocs[index];
                    final bookingData = bookingDoc.data();
                    final bookingId = bookingDoc.id;
                    final rideId = bookingData['rideId'] ?? '';
                    final isCompleted = bookingData['isCompleted'] ?? false;
                    final ratingGiven = bookingData['ratingGiven'] ?? false;
                    final bookedAt = (bookingData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final bookedTimeStr = '${bookedAt.day}/${bookedAt.month}/${bookedAt.year} ${bookedAt.hour.toString().padLeft(2, '0')}:${bookedAt.minute.toString().padLeft(2, '0')}';
                    
                    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance.collection('rides').doc(rideId).get(),
                      builder: (context, rideSnapshot) {
                        if (rideSnapshot.connectionState == ConnectionState.waiting) {
                          return const Card(
                            child: ListTile(
                              leading: CircularProgressIndicator(),
                              title: Text('Loading...'),
                            ),
                          );
                        }
                        if (rideSnapshot.hasError || !rideSnapshot.hasData || !rideSnapshot.data!.exists) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.error, color: Colors.red),
                              title: const Text('Ride not found'),
                              subtitle: Text('Booked on: $bookedTimeStr'),
                            ),
                          );
                        }
                        
                        final ride = Ride.fromFirestore(rideSnapshot.data!);
                        final rideTimeStr = '${ride.rideTime.day}/${ride.rideTime.month}/${ride.rideTime.year} ${ride.rideTime.hour.toString().padLeft(2, '0')}:${ride.rideTime.minute.toString().padLeft(2, '0')}';
                        final bookedSeats = bookingData['seatsBooked'] ?? 1;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left side - Ride details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Route with icon
                                      Row(
                                        children: [
                                          Icon(
                                            ride.vehicleType == VehicleType.car 
                                              ? Icons.directions_car 
                                              : Icons.motorcycle,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${ride.source} → ${ride.destination}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Owner info
                                      Row(
                                        children: [
                                          const Icon(Icons.person, size: 16, color: Colors.black54),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Owner: ${ride.ownerName}',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // Ride time
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 16, color: Colors.black54),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Ride Time: $rideTimeStr',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // Vehicle type
                                      Row(
                                        children: [
                                          const Icon(Icons.info_outline, size: 16, color: Colors.black54),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Vehicle: ${ride.vehicleType == VehicleType.car ? 'Car' : 'Bike'}',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // Seats and price
                                      Row(
                                        children: [
                                          const Icon(Icons.event_seat, size: 16, color: Colors.black54),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Seats Booked: $bookedSeats',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                          const SizedBox(width: 16),
                                          const Icon(Icons.attach_money, size: 16, color: Colors.black54),
                                          Text(
                                            '৳${ride.pricePerSeat * bookedSeats}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // Booked timestamp
                                      Text(
                                        'Booked on: $bookedTimeStr',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black45,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      
                                      if (isCompleted && ratingGiven) ...[
                                        const SizedBox(height: 6),
                                        const Row(
                                          children: [
                                            Icon(Icons.star, size: 16, color: Colors.black),
                                            SizedBox(width: 4),
                                            Text(
                                              'Rating submitted',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(width: 12),
                                
                                // Right side - Done button
                                SizedBox(
                                  width: 80,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isCompleted && ratingGiven)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.black,
                                          size: 32,
                                        )
                                      else
                                        ElevatedButton(
                                          onPressed: () => _showRatingDialog(
                                            context,
                                            bookingId: bookingId,
                                            rideId: rideId,
                                            ownerId: ride.ownerId,
                                            ownerName: ride.ownerName,
                                            userId: user.id,
                                            userName: user.name,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            'Done',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
