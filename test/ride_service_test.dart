import 'package:flutter_test/flutter_test.dart';
import 'package:your_project/services/ride_service.dart';  // Import your RideService
import 'package:your_project/models/ride_model.dart';  // Import your Ride model

void main() {
  // Initialize the RideService instance
  final rideService = RideService();

  // Dummy ride data for testing
  final Ride testRide = Ride(
    id: '1',
    driverId: 'driver1',
    vehicleType: 'Car',
    route: 'A to B',
    availableSeats: 4,
    pricePerSeat: 100.0,
    time: '10:00 AM',
  );

  group('RideService Tests', () {
    test('Offer a ride successfully', () async {
      final result = await rideService.offerRide(
        'driver1',
        'Car',
        'A to B',
        4,
        100.0,
        '10:00 AM',
      );

      expect(result, 'Ride offered successfully');
    });

    test('Offer a ride with insufficient seats', () async {
      final result = await rideService.offerRide(
        'driver2',
        'Bike',
        'C to D',
        0,  // Invalid seat count (0 seats)
        50.0,
        '12:00 PM',
      );

      expect(result, 'Ride offering failed: Invalid available seats');
    });

    test('Search rides by route and time', () async {
      // Add the test ride to the RideService
      await rideService.offerRide(
        'driver1',
        'Car',
        'A to B',
        4,
        100.0,
        '10:00 AM',
      );

      // Search for rides matching the route and time
      final result = await rideService.searchRides('A to B', '10:00 AM');

      expect(result.length, 1);
      expect(result[0].route, 'A to B');
      expect(result[0].time, '10:00 AM');
    });

    test('Search rides with no matching results', () async {
      // Search for rides that don’t exist
      final result = await rideService.searchRides('X to Y', '11:00 AM');

      expect(result.isEmpty, true);  // No rides should match
    });
  });
}
