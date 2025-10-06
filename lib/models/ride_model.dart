class Ride {
  final String id;
  final String driverId;
  final String vehicleType; // e.g., "Car" or "Bike"
  final String route;
  int availableSeats; // mutable so seats can change when booked/canceled
  final double pricePerSeat;
  final String time; // e.g., "10:00 AM"
  bool isActive; // mutable so ride can be deactivated

  Ride({
    required this.id,
    required this.driverId,
    required this.vehicleType,
    required this.route,
    required this.availableSeats,
    required this.pricePerSeat,
    required this.time,
    this.isActive = true,
  }) : assert(availableSeats >= 0, 'availableSeats cannot be negative');

  Ride copyWith({
    String? id,
    String? driverId,
    String? vehicleType,
    String? route,
    int? availableSeats,
    double? pricePerSeat,
    String? time,
    bool? isActive,
  }) {
    return Ride(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      vehicleType: vehicleType ?? this.vehicleType,
      route: route ?? this.route,
      availableSeats: availableSeats ?? this.availableSeats,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'driverId': driverId,
        'vehicleType': vehicleType,
        'route': route,
        'availableSeats': availableSeats,
        'pricePerSeat': pricePerSeat,
        'time': time,
        'isActive': isActive,
      };

  factory Ride.fromMap(Map<String, dynamic> map) => Ride(
        id: map['id'],
        driverId: map['driverId'],
        vehicleType: map['vehicleType'],
        route: map['route'],
        availableSeats: map['availableSeats'],
        pricePerSeat: (map['pricePerSeat'] as num).toDouble(),
        time: map['time'],
        isActive: map['isActive'] ?? true,
      );
}
