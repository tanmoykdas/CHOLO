import 'package:cloud_firestore/cloud_firestore.dart';

enum VehicleType { car, bike }

class Ride {
  final String id;
  final String ownerId;
  final VehicleType vehicleType;
  final String route; // e.g. "A to B"
  final int availableSeats;
  final int pricePerSeat;
  final DateTime rideTime;
  final int bookedSeats;

  Ride({
    required this.id,
    required this.ownerId,
    required this.vehicleType,
    required this.route,
    required this.availableSeats,
    required this.pricePerSeat,
    required this.rideTime,
    this.bookedSeats = 0,
  });

  int get remainingSeats => availableSeats - bookedSeats;

  factory Ride.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Ride(
      id: doc.id,
      ownerId: data['ownerId'],
      vehicleType: VehicleType.values.firstWhere(
          (e) => e.name == data['vehicleType'],
          orElse: () => VehicleType.bike),
      route: data['route'],
      availableSeats: data['availableSeats'],
      pricePerSeat: data['pricePerSeat'],
      rideTime: (data['rideTime'] as Timestamp).toDate(),
      bookedSeats: data['bookedSeats'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'vehicleType': vehicleType.name,
        'route': route,
        'availableSeats': availableSeats,
        'pricePerSeat': pricePerSeat,
        'rideTime': Timestamp.fromDate(rideTime),
        'bookedSeats': bookedSeats,
      };

  Ride copyWith({
    int? bookedSeats,
  }) => Ride(
        id: id,
        ownerId: ownerId,
        vehicleType: vehicleType,
        route: route,
        availableSeats: availableSeats,
        pricePerSeat: pricePerSeat,
        rideTime: rideTime,
        bookedSeats: bookedSeats ?? this.bookedSeats,
      );
}

class Booking {
  final String id;
  final String rideId;
  final String userId;
  final int seats;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.rideId,
    required this.userId,
    required this.seats,
    required this.createdAt,
  });

  factory Booking.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Booking(
      id: doc.id,
      rideId: data['rideId'],
      userId: data['userId'],
      seats: data['seats'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'rideId': rideId,
        'userId': userId,
        'seats': seats,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
