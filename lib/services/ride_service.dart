import 'package:flutter/material.dart';
import 'package:your_project/models/ride_model.dart'; // Import your Ride model

class RideService {
  // Dummy list of available rides (to simulate a database)
  List<Ride> _rides = [];

  // Function to offer a ride
  Future<String> offerRide(
      String driverId,
      String vehicleType,
      String route,
      int availableSeats,
      double pricePerSeat,
      String time) async {
    try {
      // Creating a new ride object
      final newRide = Ride(
        id: DateTime.now().toString(),  // Unique ID using current timestamp
        driverId: driverId,
        vehicleType: vehicleType,
        route: route,
        availableSeats: availableSeats,
        pricePerSeat: pricePerSeat,
        time: time,
      );

      // Simulating saving the ride to a database (add to the list here)
      _rides.add(newRide);

      // In a real app, you would save the new ride to Firebase or a database
      return "Ride offered successfully";
    } catch (e) {
      return "Error offering ride: $e";
    }
  }

  // Function to search for available rides
  Future<List<Ride>> searchRides(String route, String time) async {
    try {
      // Filter rides by route and time
      final availableRides = _rides.where((ride) {
        final routeMatch = ride.route.contains(route);
        final timeMatch = ride.time.contains(time);
        return routeMatch && timeMatch;
      }).toList();

      // In a real app, you would fetch this data from Firebase or a backend
      return availableRides;
    } catch (e) {
      print("Error fetching rides: $e");
      return [];
    }
  }

  // Function to get all rides (for testing)
  List<Ride> getAllRides() {
    return _rides;
  }
}
