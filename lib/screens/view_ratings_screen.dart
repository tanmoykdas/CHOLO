import 'package:flutter/material.dart';
import '../core/services/rating_service.dart';
import '../core/models/rating_model.dart';

class ViewRatingsScreen extends StatelessWidget {
  const ViewRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = ModalRoute.of(context)?.settings.arguments as String?;
    
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ratings')),
        body: const Center(child: Text('Invalid user')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Ratings')),
      body: StreamBuilder<List<Rating>>(
        stream: RatingService().getRatingsForUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final ratings = snapshot.data ?? [];
          
          if (ratings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No ratings yet', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ratings.length,
            itemBuilder: (context, index) {
              final rating = ratings[index];
              final dateStr = '${rating.createdAt.day}/${rating.createdAt.month}/${rating.createdAt.year}';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              rating.fromUserName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < rating.rating ? Icons.star : Icons.star_border,
                              color: Colors.orange,
                              size: 20,
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'As ${rating.type == RatingType.asOwner ? 'Ride Owner' : 'Rider'}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      if (rating.review.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(rating.review),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        dateStr,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
