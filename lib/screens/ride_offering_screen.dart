import 'package:flutter/material.dart';

class RideOfferingScreen extends StatefulWidget {
  @override
  _RideOfferingScreenState createState() => _RideOfferingScreenState();
}

class _RideOfferingScreenState extends State<RideOfferingScreen> {
  final _vehicleTypeController = TextEditingController();
  final _routeController = TextEditingController();
  final _availableSeatsController = TextEditingController();
  final _pricePerSeatController = TextEditingController();
  final _timeController = TextEditingController();

  // Function to handle ride offering
  void _offerRide() {
    final vehicleType = _vehicleTypeController.text;
    final route = _routeController.text;
    final availableSeats = int.tryParse(_availableSeatsController.text) ?? 0;
    final pricePerSeat = double.tryParse(_pricePerSeatController.text) ?? 0.0;
    final time = _timeController.text;

    // You can add ride offering logic here (e.g., save to Firebase, etc.)
    print('Vehicle Type: $vehicleType');
    print('Route: $route');
    print('Available Seats: $availableSeats');
    print('Price per Seat: $pricePerSeat');
    print('Time: $time');

    // After offering the ride, you can navigate back or show a success message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offer a Ride'),
        backgroundColor: Colors.black,  // Customize the app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // App Name in the Ride Offering Screen
                Text(
                  'CHOLO',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30),
                // Vehicle Type Field
                TextField(
                  controller: _vehicleTypeController,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Type (Car/Bike)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                ),
                SizedBox(height: 20),
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
                // Available Seats Field
                TextField(
                  controller: _availableSeatsController,
                  decoration: InputDecoration(
                    labelText: 'Available Seats',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event_seat),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                // Price per Seat Field
                TextField(
                  controller: _pricePerSeatController,
                  decoration: InputDecoration(
                    labelText: 'Price per Seat',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                SizedBox(height: 30),
                // Offer Ride Button
                ElevatedButton(
                  onPressed: _offerRide,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shadowColor: Colors.black.withOpacity(0.3),
                    elevation: 8,
                  ),
                  child: Text(
                    'Offer Ride',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
