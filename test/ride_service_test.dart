import 'package:flutter_test/flutter_test.dart';
import 'package:cholo/services/ride_service.dart';
import 'package:cholo/models/ride_model.dart';

void main() {
  final rideService = RideService();

  group('RideService Tests', () {
    test('Offer a ride successfully', () async {
      final result = await rideService.offerRide('driver1', 'Car', 'A to B', 4, 100.0, '10:00 AM');
      expect(result, 'Ride offered successfully');
    });

    test('Offer a ride with insufficient seats', () async {
      final result = await rideService.offerRide('driver2', 'Bike', 'C to D', 0, 50.0, '12:00 PM');
      expect(result, 'Ride offering failed: Invalid available seats');
    });

    test('Search rides by route and time', () async {
      await rideService.offerRide('driver1', 'Car', 'Campus to City', 3, 80.0, '09:00 AM');
      final result = await rideService.searchRides('Campus to City', '09:00');
      expect(result.isNotEmpty, true);
      expect(result.first.route, contains('Campus to City'));
    });

    test('Search rides with no matching results', () async {
      final result = await rideService.searchRides('X to Y', '11:00 AM');
      expect(result.isEmpty, true);
    });
  });
}
