import 'package:cloud_firestore/cloud_firestore.dart';

enum RatingType { asRider, asOwner }

class Rating {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String rideId;
  final int rating; // 1-5 stars
  final String review;
  final RatingType type;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.rideId,
    required this.rating,
    required this.review,
    required this.type,
    required this.createdAt,
  });

  factory Rating.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Rating(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      fromUserName: data['fromUserName'] ?? '',
      toUserId: data['toUserId'] ?? '',
      rideId: data['rideId'] ?? '',
      rating: data['rating'] ?? 0,
      review: data['review'] ?? '',
      type: RatingType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => RatingType.asRider,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'fromUserId': fromUserId,
        'fromUserName': fromUserName,
        'toUserId': toUserId,
        'rideId': rideId,
        'rating': rating,
        'review': review,
        'type': type.name,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
