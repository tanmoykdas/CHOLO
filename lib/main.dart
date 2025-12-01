import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/ride_provider.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/offer_ride_screen.dart';
import 'screens/search_ride_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/my_offered_rides_screen.dart';
import 'screens/my_booked_rides_screen.dart';
import 'screens/view_ratings_screen.dart';

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
