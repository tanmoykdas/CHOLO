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
      ownerName: ride.ownerName,
      vehicleType: ride.vehicleType,
      route: ride.route,
      source: ride.source,
      destination: ride.destination,
      routeKey: ride.routeKey,
      availableSeats: ride.availableSeats,
      pricePerSeat: ride.pricePerSeat,
      rideTime: ride.rideTime,
      bookedSeats: ride.bookedSeats,
    );
  }

  Stream<List<Ride>> ridesForRoute(String route) {
    final parts = route.split(' to ');
    final src = parts.isNotEmpty ? parts.first.trim() : '';
    final dst = parts.length > 1 ? parts.last.trim() : '';
    final key = Ride.buildRouteKey(src, dst);
    return _rides.where('routeKey', isEqualTo: key).snapshots().map((snap) =>
        snap.docs.map((d) => Ride.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>)).toList());
  }

  Future<List<Ride>> searchByRoute(String route) async {
    final parts = route.split(' to ');
    final src = parts.isNotEmpty ? parts.first.trim() : '';
    final dst = parts.length > 1 ? parts.last.trim() : '';
    final key = Ride.buildRouteKey(src, dst);

    final List<Ride> combined = [];
    // Run lookups and merge results, ignoring failures
    await Future.wait([
      () async {
        try {
          final snap = await _rides.where('routeKey', isEqualTo: key).get();
          combined.addAll(snap.docs.map((d) => Ride.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>)));
        } catch (_) {}
      }(),
      () async {
        try {
          final routeStr = '$src to $dst';
          final snap = await _rides.where('route', isEqualTo: routeStr).get();
          combined.addAll(snap.docs.map((d) => Ride.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>)));
        } catch (_) {}
      }(),
      () async {
        try {
          final snap = await _rides.where('source', isEqualTo: src).where('destination', isEqualTo: dst).get();
          combined.addAll(snap.docs.map((d) => Ride.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>)));
        } catch (_) {}
      }(),
    ]);

    // De-duplicate by id
    final seen = <String>{};
    final unique = <Ride>[];
    for (final r in combined) {
      if (!seen.contains(r.id)) {
        seen.add(r.id);
        unique.add(r);
      }
    }
    if (unique.isNotEmpty) return unique;

    // Final fallback: fetch a limited batch and filter client-side by normalized key
    try {
      final snap = await _rides.limit(200).get();
      final filtered = <Ride>[];
      for (final d in snap.docs) {
        try {
          final data = d.data() as Map<String, dynamic>;
          String srcF = (data['source'] ?? '').toString();
          String dstF = (data['destination'] ?? '').toString();
          if (srcF.isEmpty || dstF.isEmpty) {
            final route = (data['route'] ?? '').toString();
            final idx = route.indexOf(' to ');
            if (idx != -1) {
              srcF = route.substring(0, idx);
              dstF = route.substring(idx + 4);
            }
          }
          final itemKey = Ride.buildRouteKey(srcF, dstF);
          if (itemKey == key) {
            filtered.add(Ride.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>));
          }
        } catch (_) {}
      }
      return filtered;
    } catch (_) {
      return unique; // still empty
    }
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

  Future<bool> updateRide(
    String rideId, {
    String? source,
    String? destination,
    int? availableSeats,
    int? pricePerSeat,
    DateTime? rideTime,
    VehicleType? vehicleType,
  }) async {
    return FirebaseFirestore.instance.runTransaction((txn) async {
      final ref = _rides.doc(rideId);
      final snap = await txn.get(ref);
      if (!snap.exists) return false;
      final ride = Ride.fromFirestore(snap as DocumentSnapshot<Map<String, dynamic>>);
      if (ride.bookedSeats > 0) return false; // lock after bookings
      final updates = <String, dynamic>{};
      if (source != null) updates['source'] = source;
      if (destination != null) updates['destination'] = destination;
      if (source != null || destination != null) {
        final s = source ?? ride.source;
        final d = destination ?? ride.destination;
        updates['route'] = '$s to $d';
        updates['routeKey'] = Ride.buildRouteKey(s, d);
      }
      if (availableSeats != null) updates['availableSeats'] = availableSeats;
      if (pricePerSeat != null) updates['pricePerSeat'] = pricePerSeat;
      if (rideTime != null) updates['rideTime'] = Timestamp.fromDate(rideTime);
      if (vehicleType != null) updates['vehicleType'] = vehicleType.name;
      txn.update(ref, updates);
      return true;
    });
  }
}
