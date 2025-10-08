import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/ride_provider.dart';
import 'core/services/notification_service.dart';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('CHOLO', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (v) => _email = v!.trim(),
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
                        _form.currentState!.save();
                        await context.read<AuthProvider>().login(_email, _password);
                        if (mounted && context.read<AuthProvider>().isLoggedIn) {
                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                child: auth.isLoading ? const CircularProgressIndicator() : const Text('Login'),
              ),
            ],
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user != null && !user.emailVerified)
              const Text('Verify your email to unlock all features', style: TextStyle(color: Colors.orange)),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/offer'),
              child: const Text('Offer a Ride'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/search'),
              child: const Text('Find a Ride'),
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
  String _route = '';
  int _seats = 1;
  int _price = 0;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offer Ride')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _vehicle,
                decoration: const InputDecoration(labelText: 'Vehicle Type'),
                items: const [
                  DropdownMenuItem(value: 'car', child: Text('Car')),
                  DropdownMenuItem(value: 'bike', child: Text('Bike')),
                ],
                onChanged: (v) => setState(() => _vehicle = v!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Route (A to B)'),
                onSaved: (v) => _route = v!.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Available Seats'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _seats = int.tryParse(v ?? '1') ?? 1,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price per Seat'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _price = int.tryParse(v ?? '0') ?? 0,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Ride Time: ${_time.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: _time);
                  if (picked != null) setState(() => _time = picked);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _form.currentState!.save();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ride published (placeholder)')));
                  Navigator.pop(context);
                },
                child: const Text('Publish'),
              ),
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
  final _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final rideProv = context.watch<RideProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Find Ride')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Route (A to B)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.read<RideProvider>().search(_searchController.text.trim()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (rideProv.isLoading) const LinearProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemCount: rideProv.results.length,
                itemBuilder: (c, i) {
                  final r = rideProv.results[i];
                  return Card(
                    child: ListTile(
                      title: Text(r.route),
                      subtitle: Text('${r.vehicleType.name.toUpperCase()} • ${r.remainingSeats} seats • ৳${r.pricePerSeat}'),
                      trailing: ElevatedButton(
                        onPressed: r.remainingSeats == 0
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booked (placeholder)')));
                              },
                        child: const Text('Book'),
                      ),
                    ),
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: user == null
            ? const Text('Not logged in')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${user.name}'),
                  Text('Login Email: ${user.email}'),
                  Text('University Email: ${user.universityEmail}'),
                  Text('Verified: ${user.emailVerified}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                      }
                    },
                    child: const Text('Logout'),
                  )
                ],
              ),
      ),
    );
  }
}
