import 'package:cholo/models/ride_model.dart';

/// Fallback in-memory ride service (useful for tests or offline dev).
class LocalRideService {
  final List<Ride> _rides = [];

  Future<String> offerRide(String driverId, String vehicleType, String route, int availableSeats, double pricePerSeat, String time) async {
    if (availableSeats <= 0) return 'Ride offering failed: Invalid available seats';
    final ride = Ride(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      driverId: driverId,
      vehicleType: vehicleType,
      route: route,
      availableSeats: availableSeats,
      pricePerSeat: pricePerSeat,
      time: time,
    );
    _rides.add(ride);
    return 'Ride offered successfully';
  }

  Future<List<Ride>> searchRides(String route, String time) async {
    final r = route.toLowerCase();
    final t = time.toLowerCase();
    return _rides.where((ride) => ride.route.toLowerCase().contains(r) && ride.time.toLowerCase().contains(t)).toList();
  }

  List<Ride> getAllRides() => List.unmodifiable(_rides);
}