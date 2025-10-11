import 'package:cloud_firestore/cloud_firestore.dart';

enum VehicleType { car, bike }

class Ride {
  final String id;
  final String ownerId;
  final String ownerName;
  final VehicleType vehicleType;
  final String route; // legacy display
  final String source;
  final String destination;
  final String routeKey; // lowercased "source__destination"
  final int availableSeats;
  final int pricePerSeat;
  final DateTime rideTime;
  final int bookedSeats;

  Ride({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.vehicleType,
    required this.route,
    required this.source,
    required this.destination,
    required this.routeKey,
    required this.availableSeats,
    required this.pricePerSeat,
    required this.rideTime,
    this.bookedSeats = 0,
  });

  int get remainingSeats => availableSeats - bookedSeats;

  factory Ride.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final src = (data['source'] ?? '') as String;
    final dst = (data['destination'] ?? '') as String;
    return Ride(
      id: doc.id,
      ownerId: data['ownerId'],
      ownerName: data['ownerName'] ?? '',
      vehicleType: VehicleType.values.firstWhere(
          (e) => e.name == data['vehicleType'],
          orElse: () => VehicleType.bike),
      route: data['route'] ?? (src.isNotEmpty && dst.isNotEmpty ? '$src to $dst' : ''),
      source: src,
      destination: dst,
      routeKey: data['routeKey'] ?? buildRouteKey(src, dst),
      availableSeats: data['availableSeats'],
      pricePerSeat: data['pricePerSeat'],
      rideTime: (data['rideTime'] as Timestamp).toDate(),
      bookedSeats: data['bookedSeats'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'ownerName': ownerName,
        'vehicleType': vehicleType.name,
        'route': route,
        'source': source,
        'destination': destination,
        'routeKey': routeKey,
        'availableSeats': availableSeats,
        'pricePerSeat': pricePerSeat,
        'rideTime': Timestamp.fromDate(rideTime),
        'bookedSeats': bookedSeats,
      };

  Ride copyWith({
    int? bookedSeats,
    String? source,
    String? destination,
    String? ownerName,
    int? availableSeats,
    int? pricePerSeat,
    DateTime? rideTime,
  }) => Ride(
        id: id,
        ownerId: ownerId,
        ownerName: ownerName ?? this.ownerName,
        vehicleType: vehicleType,
        route: route,
        source: source ?? this.source,
        destination: destination ?? this.destination,
        routeKey: buildRouteKey(source ?? this.source, destination ?? this.destination),
        availableSeats: availableSeats ?? this.availableSeats,
        pricePerSeat: pricePerSeat ?? this.pricePerSeat,
        rideTime: rideTime ?? this.rideTime,
        bookedSeats: bookedSeats ?? this.bookedSeats,
      );

  static String buildRouteKey(String source, String destination) =>
      '${source.trim().toLowerCase()}__${destination.trim().toLowerCase()}';
}

class Booking {
  final String id;
  final String rideId;
  final String userId;
  final int seats;
  final DateTime createdAt;
  final bool isCompleted;
  final bool ratingGiven;

  Booking({
    required this.id,
    required this.rideId,
    required this.userId,
    required this.seats,
    required this.createdAt,
    this.isCompleted = false,
    this.ratingGiven = false,
  });

  factory Booking.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Booking(
      id: doc.id,
      rideId: data['rideId'],
      userId: data['userId'],
      seats: data['seats'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      ratingGiven: data['ratingGiven'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'rideId': rideId,
        'userId': userId,
        'seats': seats,
        'createdAt': Timestamp.fromDate(createdAt),
        'isCompleted': isCompleted,
        'ratingGiven': ratingGiven,
      };
}
