import 'package:flutter_test/flutter_test.dart';
import 'package:cholo/services/booking_service.dart';
import 'package:cholo/services/ride_service.dart';
import 'package:cholo/models/ride_model.dart';

void main() {
  final bookingService = BookingService();
  final rideService = RideService();

  final Ride testRide = Ride(
    id: '1',
    driverId: 'driver1',
    vehicleType: 'Car',
    route: 'A to B',
    availableSeats: 4,
    pricePerSeat: 100.0,
    time: '10:00 AM',
  );

  group('BookingService Tests', () {
    test('Offer a ride successfully', () async {
      final result = await rideService.offerRide('driver1', 'Car', 'A to B', 4, 100.0, '10:00 AM');
      expect(result, 'Ride offered successfully');
    });

    test('Book a ride successfully', () async {
      final result = await bookingService.bookRide('rider1', testRide, 2);
      expect(result, 'Booking successful. Total price: \$200.00');
    });

    test('Book a ride with insufficient available seats', () async {
      final result = await bookingService.bookRide('rider2', testRide, 5);
      expect(result, 'Not enough seats available');
    });

    test('Get bookings by rider', () async {
      await bookingService.bookRide('rider1', testRide, 2);
      final bookings = bookingService.getBookingsByRider('rider1');
      expect(bookings.isNotEmpty, true);
      expect(bookings.first.riderId, 'rider1');
      expect(bookings.first.rideId, '1');
    });

    test('Cancel a booking successfully', () async {
      final bookingResult = await bookingService.bookRide('rider1', testRide, 2);
      expect(bookingResult, 'Booking successful. Total price: \$200.00');
      final bookingId = bookingService.getAllBookings().last.id;
      final cancelResult = await bookingService.cancelBooking(bookingId);
      expect(cancelResult, 'Booking canceled successfully');
    });

    test('Cancel a non-existing booking', () async {
      final cancelResult = await bookingService.cancelBooking('non-existent-id');
      expect(cancelResult, 'Booking not found');
    });
  });
}
