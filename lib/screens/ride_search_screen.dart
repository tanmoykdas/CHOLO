import 'package:flutter/material.dart';

class RideSearchScreen extends StatefulWidget {
  @override
  _RideSearchScreenState createState() => _RideSearchScreenState();
}

class _RideSearchScreenState extends State<RideSearchScreen> {
  final _routeController = TextEditingController();
  final _timeController = TextEditingController();

  // Dummy list of available rides (to be replaced by actual data from Firebase or database)
  List<Map<String, String>> availableRides = [
    {'vehicleType': 'Car', 'route': 'A to B', 'time': '10:00 AM', 'price': '100'},
    {'vehicleType': 'Bike', 'route': 'C to D', 'time': '11:00 AM', 'price': '50'},
    {'vehicleType': 'Car', 'route': 'B to A', 'time': '12:00 PM', 'price': '120'},
  ];

  // Function to search for rides
  void _searchRides() {
    final route = _routeController.text;
    final time = _timeController.text;

    // Filter available rides based on the entered route and time (simplified logic)
    setState(() {
      availableRides = availableRides.where((ride) {
        final routeMatch = ride['route']!.contains(route);
        final timeMatch = ride['time']!.contains(time);
        return routeMatch && timeMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Rides'),
        backgroundColor: Colors.black,  // Customize the app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // App Name in the Ride Search Screen
              Text(
                'CHOLO',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              // Route Field
              TextField(
                controller: _routeController,
                decoration: InputDecoration(
                  labelText: 'Route (e.g., A to B)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
              ),
              SizedBox(height: 20),
              // Time Field
              TextField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Time (e.g., 10:00 AM)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              SizedBox(height: 20),
              // Search Button
              ElevatedButton(
                onPressed: _searchRides,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shadowColor: Colors.black.withOpacity(0.3),
                  elevation: 8,
                ),
                child: Text(
                  'Search',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 30),
              // Display Available Rides
              availableRides.isEmpty
                  ? Text('No rides found', style: TextStyle(fontSize: 18, color: Colors.grey))
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: availableRides.length,
                itemBuilder: (context, index) {
                  final ride = availableRides[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    elevation: 4,
                    child: ListTile(
                      title: Text('${ride['vehicleType']} - ${ride['route']}'),
                      subtitle: Text('Time: ${ride['time']} - Price: ${ride['price']}'),
                      onTap: () {
                        // Navigate to ride details or booking screen
                        print('Ride selected: ${ride['route']}');
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
