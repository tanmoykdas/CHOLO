import 'package:flutter/material.dart';
import 'package:cholo/services/ride_service.dart';
import 'package:cholo/widgets/ride_card.dart';

final RideService _rideService = RideService();

class RideSearchScreen extends StatefulWidget {
  @override
  _RideSearchScreenState createState() => _RideSearchScreenState();
}

class _RideSearchScreenState extends State<RideSearchScreen> {
  final _routeController = TextEditingController();
  final _timeController = TextEditingController();
  bool _loading = false;
  List availableRides = [];

  Future<void> _searchRides() async {
    setState(() => _loading = true);
    final results = await _rideService.searchRides(
      _routeController.text,
      _timeController.text,
    );
    setState(() {
      availableRides = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Rides'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'CHOLO',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: _routeController,
                  decoration: InputDecoration(
                    labelText: 'Route (e.g., A to B)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: 'Time (e.g., 10:00 AM)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                ),
                SizedBox(height: 20),
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
                if (_loading) const CircularProgressIndicator(),
                if (!_loading)
                  availableRides.isEmpty
                      ? Text('No rides found', style: TextStyle(fontSize: 18, color: Colors.grey))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: availableRides.length,
                          itemBuilder: (context, index) {
                            final ride = availableRides[index];
                            return RideCard(
                              ride: ride,
                              onTap: () {},
                            );
                          },
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
