import 'package:flutter/material.dart';
import 'package:cholo/models/ride_model.dart'; // Import your Ride model

/// In-memory ride service. Replace with backend integration later.
class RideService {
  final List<Ride> _rides = [];

  Future<String> offerRide(
    String driverId,
    String vehicleType,
    String route,
    int availableSeats,
    double pricePerSeat,
    String time,
  ) async {
    try {
      if (availableSeats <= 0) return 'Ride offering failed: Invalid available seats';
      if (pricePerSeat < 0) return 'Ride offering failed: Invalid price';
      if (vehicleType.trim().isEmpty || route.trim().isEmpty || time.trim().isEmpty) {
        return 'Ride offering failed: Missing required fields';
      }
      final ride = Ride(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        driverId: driverId,
        vehicleType: vehicleType.trim(),
        route: route.trim(),
        availableSeats: availableSeats,
        pricePerSeat: pricePerSeat,
        time: time.trim(),
      );
      _rides.add(ride);
      return 'Ride offered successfully';
    } catch (e) {
      return 'Error offering ride: $e';
    }
  }

  Future<List<Ride>> searchRides(String route, String time) async {
    try {
      final r = route.trim().toLowerCase();
      final t = time.trim().toLowerCase();
      return _rides.where((ride) {
        final routeMatch = r.isEmpty || ride.route.toLowerCase().contains(r);
        final timeMatch = t.isEmpty || ride.time.toLowerCase().contains(t);
        return ride.isActive && routeMatch && timeMatch;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  List<Ride> getAllRides() => List.unmodifiable(_rides);

  bool deactivateRide(String rideId) {
    final idx = _rides.indexWhere((r) => r.id == rideId);
    if (idx == -1) return false;
    _rides[idx].isActive = false;
    return true;
  }
}
