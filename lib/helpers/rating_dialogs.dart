import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/rating_service.dart';
import '../core/models/rating_model.dart';

/// Show rating dialog for a booker after ride completion
Future<void> showRatingDialogForBooker(
  BuildContext context, {
  required String rideId,
  required String bookerId,
  required String bookerName,
  required String ownerId,
  required String ownerName,
}) async {
  final ratingService = RatingService();
  
  // Check if already rated
  final alreadyRated = await ratingService.hasRated(
    fromUserId: ownerId,
    toUserId: bookerId,
    rideId: rideId,
  );

  if (alreadyRated && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You already rated $bookerName')),
    );
    return;
  }

  int rating = 5;
  final reviewCtrl = TextEditingController();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text('Rate $bookerName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was the booker?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 36,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewCtrl,
                decoration: const InputDecoration(
                  labelText: 'Review (optional)',
                  hintText: 'Share your experience...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    ),
  );

  if (confirmed == true && context.mounted) {
    final success = await ratingService.submitRating(
      fromUserId: ownerId,
      fromUserName: ownerName,
      toUserId: bookerId,
      rideId: rideId,
      rating: rating,
      review: reviewCtrl.text.trim(),
      type: RatingType.asRider,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully!')),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit rating')),
      );
    }
  }
}

/// Show list of bookers to rate
Future<void> showRateBookersDialog(
  BuildContext context,
  String rideId,
  String ownerId,
  String ownerName,
) async {
  // Fetch all bookings for this ride
  final bookingsSnap = await FirebaseFirestore.instance
      .collection('bookings')
      .where('rideId', isEqualTo: rideId)
      .get();

  if (bookingsSnap.docs.isEmpty && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No bookings for this ride')),
    );
    return;
  }

  // Get unique bookers
  final bookerIds = bookingsSnap.docs
      .map((d) => d.data()['userId'] as String?)
      .whereType<String>()
      .toSet()
      .toList();

  if (bookerIds.isEmpty && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No bookers found')),
    );
    return;
  }

  // Fetch user details for bookers
  final bookers = <Map<String, String>>[];
  for (final userId in bookerIds) {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      bookers.add({
        'id': userId,
        'name': data['name'] ?? 'Unknown',
      });
    }
  }

  if (!context.mounted) return;

  // Show list of bookers to rate
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Rate Bookers'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: bookers.length,
          itemBuilder: (context, index) {
            final booker = bookers[index];
            return ListTile(
              title: Text(booker['name']!),
              trailing: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await showRatingDialogForBooker(
                    context,
                    rideId: rideId,
                    bookerId: booker['id']!,
                    bookerName: booker['name']!,
                    ownerId: ownerId,
                    ownerName: ownerName,
                  );
                },
                child: const Text('Rate'),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// Show rating dialog for ride owner after ride completion
Future<void> showRatingDialog(
  BuildContext context, {
  required String bookingId,
  required String rideId,
  required String ownerId,
  required String ownerName,
  required String userId,
  required String userName,
}) async {
  final ratingService = RatingService();
  
  int rating = 5;
  final reviewCtrl = TextEditingController();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text('Rate $ownerName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was your ride?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 36,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewCtrl,
                decoration: const InputDecoration(
                  labelText: 'Review (optional)',
                  hintText: 'Share your experience...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    ),
  );

  if (confirmed == true && context.mounted) {
    final success = await ratingService.submitRating(
      fromUserId: userId,
      fromUserName: userName,
      toUserId: ownerId,
      rideId: rideId,
      rating: rating,
      review: reviewCtrl.text.trim(),
      type: RatingType.asOwner,
    );

    if (success && context.mounted) {
      // Mark booking as completed and rated
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'isCompleted': true, 'ratingGiven': true});
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully!')),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit rating')),
      );
    }
  }
}
