import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/ride_provider.dart';
import 'core/services/notification_service.dart';
import 'core/models/ride_model.dart';
import 'core/services/ride_service.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose an option',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: user != null ? () => Navigator.pushNamed(context, '/offer') : null,
                  child: const Text('Offer a Ride'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/search'),
                  child: const Text('Book a Ride'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: user != null ? () => Navigator.pushNamed(context, '/my_offered') : null,
                  child: const Text('My Offered Rides'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: user != null ? () => Navigator.pushNamed(context, '/my_booked') : null,
                  child: const Text('My Booked Rides'),
                ),
              ),
            ],
          ),
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
                decoration: const InputDecoration(labelText: 'Starting point'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                onSaved: (v) => _source = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Destination'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                onSaved: (v) => _destination = v!.trim(),
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
                onPressed: _submitting
                    ? null
                    : () async {
                        if (!(_form.currentState?.validate() ?? false)) return;
                        _form.currentState!.save();
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
                child: _submitting ? const CircularProgressIndicator() : const Text('Share'),
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
  final _srcCtrl = TextEditingController();
  final _dstCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final rideProv = context.watch<RideProvider>();
    final auth = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Ride')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _srcCtrl, decoration: const InputDecoration(labelText: 'Starting point')),
            const SizedBox(height: 12),
            TextField(controller: _dstCtrl, decoration: const InputDecoration(labelText: 'Destination')),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final src = _srcCtrl.text.trim();
                  final dst = _dstCtrl.text.trim();
                  if (src.isEmpty || dst.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter both Starting point and Destination')),
                    );
                    return;
                  }
                  final route = '$src to $dst';
                  context.read<RideProvider>().search(route);
                },
                child: const Text('Search'),
              ),
            ),
            const SizedBox(height: 16),
            if (rideProv.isLoading) const LinearProgressIndicator(),
            Expanded(
              child: rideProv.results.isEmpty && !rideProv.isLoading
                  ? const Center(child: Text('Nothing found, try again'))
                  : ListView.builder(
                      itemCount: rideProv.results.length,
                      itemBuilder: (c, i) {
                        final r = rideProv.results[i];
                        return Card(
                          child: ListTile(
                            title: Text(r.route),
                            subtitle: Text('${r.ownerName.isNotEmpty ? r.ownerName + ' • ' : ''}${r.vehicleType.name.toUpperCase()} • ${r.remainingSeats} seats • ৳${r.pricePerSeat}'),
                            trailing: ElevatedButton(
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

class MyOfferedRidesScreen extends StatelessWidget {
  const MyOfferedRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('My Offered Rides')),
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
                          spacing: 8,
                          children: [
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

class MyBookedRidesScreen extends StatelessWidget {
  const MyBookedRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('My Booked Rides')),
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
                    final bookingData = bookingDocs[index].data();
                    final rideId = bookingData['rideId'] ?? '';
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
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(
                              ride.vehicleType == VehicleType.car ? Icons.directions_car : Icons.motorcycle,
                              color: Colors.green,
                            ),
                            title: Text(ride.route, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ride Time: $rideTimeStr'),
                                Text('Price: ৳${ride.pricePerSeat}'),
                                Text('Booked on: $bookedTimeStr', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.check_circle, color: Colors.green),
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
