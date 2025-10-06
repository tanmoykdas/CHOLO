class Booking {
  final String id;             // Booking ID
  final String riderId;        // ID of the rider who booked the ride
  final String rideId;         // ID of the ride being booked
  final int seatsBooked;       // Number of seats booked
  final double totalPrice;     // Total price for the booking
  final String bookingTime;    // Time when the booking was made
  final bool isConfirmed;      // Booking confirmation status
  final bool isActive;         // If the booking is still active (not canceled)

  Booking({
    required this.id,
    required this.riderId,
    required this.rideId,
    required this.seatsBooked,
    required this.totalPrice,
    required this.bookingTime,
    this.isConfirmed = false,    // Default to false (unconfirmed)
    this.isActive = true,        // Default to true (active)
  });

  // Convert a Booking into a Map for easy database storage (like Firestore or SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'riderId': riderId,
      'rideId': rideId,
      'seatsBooked': seatsBooked,
      'totalPrice': totalPrice,
      'bookingTime': bookingTime,
      'isConfirmed': isConfirmed,
      'isActive': isActive,
    };
  }

  // Create a Booking from a Map (for reading from database)
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      riderId: map['riderId'],
      rideId: map['rideId'],
      seatsBooked: map['seatsBooked'],
      totalPrice: map['totalPrice'],
      bookingTime: map['bookingTime'],
      isConfirmed: map['isConfirmed'] ?? false, // Default to false if not specified
      isActive: map['isActive'] ?? true, // Default to true if not specified
    );
  }
}
