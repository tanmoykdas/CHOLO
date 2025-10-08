import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_model.dart';

class RideService {
  final _rides = FirebaseFirestore.instance.collection('rides');
  final _bookings = FirebaseFirestore.instance.collection('bookings');

  Future<Ride> createRide(Ride ride) async {
    final doc = await _rides.add(ride.toMap());
    return Ride(
      id: doc.id,
      ownerId: ride.ownerId,
      vehicleType: ride.vehicleType,
      route: ride.route,
      availableSeats: ride.availableSeats,
      pricePerSeat: ride.pricePerSeat,
      rideTime: ride.rideTime,
      bookedSeats: ride.bookedSeats,
    );
  }

  Stream<List<Ride>> ridesForRoute(String route) {
    return _rides.where('route', isEqualTo: route).snapshots().map((snap) =>
        snap.docs.map((d) => Ride.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>)).toList());
  }

  Future<Ride?> getRide(String id) async {
    final doc = await _rides.doc(id).get();
    if (!doc.exists) return null;
    return Ride.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
  }

  Future<bool> bookRide({required String rideId, required String userId, int seats = 1}) async {
    return FirebaseFirestore.instance.runTransaction((txn) async {
      final rideRef = _rides.doc(rideId);
      final rideSnap = await txn.get(rideRef);
      if (!rideSnap.exists) return false;
      final ride = Ride.fromFirestore(rideSnap as DocumentSnapshot<Map<String, dynamic>>);
      if (ride.remainingSeats < seats) return false;
      txn.update(rideRef, {'bookedSeats': ride.bookedSeats + seats});
      await _bookings.add({
        'rideId': rideId,
        'userId': userId,
        'seats': seats,
        'createdAt': Timestamp.now(),
      });
      return true;
    });
  }
}
