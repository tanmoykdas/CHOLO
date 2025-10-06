import 'package:flutter/material.dart';
import 'package:cholo/models/booking_model.dart';  // Import the Booking model
import 'package:cholo/models/ride_model.dart';  // Import the Ride model

class BookingService {
  // Dummy list of booked rides (simulating a database)
  List<Booking> _bookings = [];

  // Function to book a ride
  Future<String> bookRide(
      String riderId,
      Ride ride,  // Ride being booked
      int seatsBooked) async {
    try {
      // Check if the ride has enough available seats
      if (seatsBooked > ride.availableSeats) {
        return "Not enough seats available";
      }

      // Calculate the total price for the booking
      double totalPrice = seatsBooked * ride.pricePerSeat;

      // Create a new booking object
      final newBooking = Booking(
        id: DateTime.now().toString(),  // Unique ID using current timestamp
        riderId: riderId,
        rideId: ride.id,
        seatsBooked: seatsBooked,
        totalPrice: totalPrice,
        bookingTime: DateTime.now().toString(),
        isConfirmed: false,  // Default to unconfirmed
        isActive: true,  // Default to active
      );

      // Simulating saving the booking (adding to the list)
      _bookings.add(newBooking);

      // Decrease available seats in the ride
      ride.availableSeats -= seatsBooked;

      // In a real app, save the booking to Firebase or a database
      return "Booking successful. Total price: \$${totalPrice.toStringAsFixed(2)}";
    } catch (e) {
      return "Error booking ride: $e";
    }
  }

  // Function to get all bookings for a rider
  List<Booking> getBookingsByRider(String riderId) {
    // Filter bookings by rider ID
    return _bookings.where((booking) => booking.riderId == riderId).toList();
  }

  // Function to get all bookings (for testing purposes)
  List<Booking> getAllBookings() {
    return _bookings;
  }

  // Function to cancel a booking
  Future<String> cancelBooking(String bookingId) async {
    try {
      // Find the booking by ID
      final bookingIndex = _bookings.indexWhere((booking) => booking.id == bookingId);

      if (bookingIndex == -1) {
        return "Booking not found";
      }

      // Mark the booking as canceled
      _bookings[bookingIndex].isActive = false;

      // Get the associated ride to add back the available seats
      final booking = _bookings[bookingIndex];
      final ride = _getRideById(booking.rideId);
      if (ride != null) {
        ride.availableSeats += booking.seatsBooked;
      }

      return "Booking canceled successfully";
    } catch (e) {
      return "Error canceling booking: $e";
    }
  }

  // Dummy function to get ride by ID (replace with Firebase or database query)
  Ride? _getRideById(String rideId) {
    // In a real app, fetch ride data from Firebase or your database
    return Ride(id: rideId, driverId: "", vehicleType: "", route: "", availableSeats: 0, pricePerSeat: 0, time: "");
  }
}
