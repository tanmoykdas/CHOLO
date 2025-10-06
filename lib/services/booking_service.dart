import 'package:cholo/models/booking_model.dart';
import 'package:cholo/models/ride_model.dart';

/// In-memory booking service. Replace with persistent storage later.
class BookingService {
  final List<Booking> _bookings = [];
  final Map<String, Ride> _ridesById = {}; // track rides for seat restoration

  Future<String> bookRide(String riderId, Ride ride, int seatsBooked) async {
    try {
      if (seatsBooked <= 0) return 'Invalid seat count';
      if (seatsBooked > ride.availableSeats) return 'Not enough seats available';
      final total = seatsBooked * ride.pricePerSeat;
      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        riderId: riderId,
        rideId: ride.id,
        seatsBooked: seatsBooked,
        totalPrice: total,
        bookingTime: DateTime.now().toIso8601String(),
        isConfirmed: false,
        isActive: true,
      );
      _bookings.add(booking);
      _ridesById[ride.id] = ride;
      ride.availableSeats -= seatsBooked;
      return 'Booking successful. Total price: \$${total.toStringAsFixed(2)}';
    } catch (e) {
      return 'Error booking ride: $e';
    }
  }

  List<Booking> getBookingsByRider(String riderId) =>
      _bookings.where((b) => b.riderId == riderId).toList(growable: false);

  List<Booking> getAllBookings() => List.unmodifiable(_bookings);

  Future<String> cancelBooking(String bookingId) async {
    try {
      final idx = _bookings.indexWhere((b) => b.id == bookingId);
      if (idx == -1) return 'Booking not found';
      final existing = _bookings[idx];
      if (!existing.isActive) return 'Booking already canceled';
      _bookings[idx] = Booking(
        id: existing.id,
        riderId: existing.riderId,
        rideId: existing.rideId,
        seatsBooked: existing.seatsBooked,
        totalPrice: existing.totalPrice,
        bookingTime: existing.bookingTime,
        isConfirmed: existing.isConfirmed,
        isActive: false,
      );
      final ride = _ridesById[existing.rideId];
      if (ride != null) {
        ride.availableSeats += existing.seatsBooked;
      }
      return 'Booking canceled successfully';
    } catch (e) {
      return 'Error canceling booking: $e';
    }
  }
}
