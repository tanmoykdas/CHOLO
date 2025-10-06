class Ride {
  final String id;
  final String driverId;
  final String vehicleType; // e.g., "Car" or "Bike"
  final String route;
  final int availableSeats;
  final double pricePerSeat;
  final String time; // Ride time (e.g., "10:00 AM")
  final bool isActive; // To check if the ride is still available

  Ride({
    required this.id,
    required this.driverId,
    required this.vehicleType,
    required this.route,
    required this.availableSeats,
    required this.pricePerSeat,
    required this.time,
    this.isActive = true, // Default to true, meaning the ride is active
  });

  // Convert a Ride into a Map for easy database storage (like Firestore or SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driverId': driverId,
      'vehicleType': vehicleType,
      'route': route,
      'availableSeats': availableSeats,
      'pricePerSeat': pricePerSeat,
      'time': time,
      'isActive': isActive,
    };
  }

  // Create a Ride from a Map (for reading from database)
  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      id: map['id'],
      driverId: map['driverId'],
      vehicleType: map['vehicleType'],
      route: map['route'],
      availableSeats: map['availableSeats'],
      pricePerSeat: map['pricePerSeat'],
      time: map['time'],
      isActive: map['isActive'] ?? true, // Default to true if not specified
    );
  }
}
