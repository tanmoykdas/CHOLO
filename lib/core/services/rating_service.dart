import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

class RatingService {
  final _ratings = FirebaseFirestore.instance.collection('ratings');
  final _users = FirebaseFirestore.instance.collection('users');

  Future<bool> submitRating({
    required String fromUserId,
    required String fromUserName,
    required String toUserId,
    required String rideId,
    required int rating,
    required String review,
    required RatingType type,
  }) async {
    try {
      return await FirebaseFirestore.instance.runTransaction((txn) async {
        // Check if rating already exists for this ride and users
        final existingQuery = await _ratings
            .where('fromUserId', isEqualTo: fromUserId)
            .where('toUserId', isEqualTo: toUserId)
            .where('rideId', isEqualTo: rideId)
            .get();

        if (existingQuery.docs.isNotEmpty) {
          return false; // Already rated
        }

        // Add rating
        final ratingData = Rating(
          id: '',
          fromUserId: fromUserId,
          fromUserName: fromUserName,
          toUserId: toUserId,
          rideId: rideId,
          rating: rating,
          review: review,
          type: type,
          createdAt: DateTime.now(),
        ).toMap();

        await _ratings.add(ratingData);

        // Update recipient's rating stats
        final userRef = _users.doc(toUserId);
        final userSnap = await txn.get(userRef);
        
        if (userSnap.exists) {
          final userData = userSnap.data() as Map<String, dynamic>;
          final currentTotal = (userData['totalRatings'] ?? 0.0).toDouble();
          final currentCount = (userData['ratingCount'] ?? 0) as int;
          
          txn.update(userRef, {
            'totalRatings': currentTotal + rating,
            'ratingCount': currentCount + 1,
          });
        }

        return true;
      });
    } catch (e) {
      print('[RatingService] submitRating error: $e');
      return false;
    }
  }

  Stream<List<Rating>> getRatingsForUser(String userId) {
    return _ratings
        .where('toUserId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final ratings = snap.docs
              .map((d) => Rating.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>))
              .toList();
          // Sort on client side to avoid needing composite index
          ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return ratings;
        });
  }

  Future<bool> hasRated({
    required String fromUserId,
    required String toUserId,
    required String rideId,
  }) async {
    try {
      final query = await _ratings
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('rideId', isEqualTo: rideId)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
