import 'package:flutter_test/flutter_test.dart';
import 'package:your_project/services/booking_service.dart';  // Import your BookingService
import 'package:your_project/services/ride_service.dart';  // Import your RideService
import 'package:your_project/models/ride_model.dart';  // Import your Ride model
import 'package:your_project/models/booking_model.dart';  // Import your Booking model

void main() {
  // Initialize the services
  final bookingService = BookingService();
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

  group('BookingService Tests', () {
    // Offer a ride before testing booking functionality
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

    // Test booking a ride successfully
    test('Book a ride successfully', () async {
      final result = await bookingService.bookRide(
        'rider1',
        testRide,  // Ride being booked
        2,  // Seats booked
      );

      expect(result, 'Booking successful. Total price: \$200.00');
    });

    // Test booking a ride with insufficient available seats
    test('Book a ride with insufficient available seats', () async {
      final result = await bookingService.bookRide(
        'rider2',
        testRide,  // Ride being booked
        5,  // Trying to book more seats than available
      );

      expect(result, 'Not enough seats available');
    });

    // Test searching for bookings by rider ID
    test('Get bookings by rider', () async {
      // Book a ride first
      await bookingService.bookRide(
        'rider1',
        testRide,  // Ride being booked
        2,  // Seats booked
      );

      // Get the rider's bookings
      final bookings = bookingService.getBookingsByRider('rider1');

      expect(bookings.length, 1);
      expect(bookings[0].riderId, 'rider1');
      expect(bookings[0].rideId, '1');
    });

    // Test canceling a booking
    test('Cancel a booking successfully', () async {
      // Book a ride first
      final bookingResult = await bookingService.bookRide(
        'rider1',
        testRide,  // Ride being booked
        2,  // Seats booked
      );
      expect(bookingResult, 'Booking successful. Total price: \$200.00');

      // Now cancel the booking
      final cancelResult = await bookingService.cancelBooking('1');  // Booking ID
      expect(cancelResult, 'Booking canceled successfully');
    });

    // Test canceling a non-existing booking
    test('Cancel a non-existing booking', () async {
      final cancelResult = await bookingService.cancelBooking('non-existent-id');
      expect(cancelResult, 'Booking not found');
    });
  });
}
