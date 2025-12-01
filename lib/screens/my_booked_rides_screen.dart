import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/providers/auth_provider.dart';
import '../core/models/ride_model.dart';
import '../helpers/rating_dialogs.dart';

class MyBookedRidesScreen extends StatelessWidget {
  const MyBookedRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Booked Rides')),
      body: user == null
          ? const Center(child: Text('Please login to view your booked rides'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.id)
          .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final bookingDocs = snapshot.data?.docs ?? [];
                if (bookingDocs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book_online, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No rides booked yet', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Book your first ride to get started!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                bookingDocs.sort((a, b) {
                  final at = (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
                  final bt = (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
                  return bt.compareTo(at);
                });
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookingDocs.length,
                  itemBuilder: (context, index) {
                    final bookingDoc = bookingDocs[index];
                    final bookingData = bookingDoc.data();
                    final bookingId = bookingDoc.id;
                    final rideId = bookingData['rideId'] ?? '';
                    final isCompleted = bookingData['isCompleted'] ?? false;
                    final ratingGiven = bookingData['ratingGiven'] ?? false;
                    final bookedAt = (bookingData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final bookedTimeStr = '${bookedAt.day}/${bookedAt.month}/${bookedAt.year} ${bookedAt.hour.toString().padLeft(2, '0')}:${bookedAt.minute.toString().padLeft(2, '0')}';
                    
                    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance.collection('rides').doc(rideId).get(),
                      builder: (context, rideSnapshot) {
                        if (rideSnapshot.connectionState == ConnectionState.waiting) {
                          return const Card(
                            child: ListTile(
                              leading: CircularProgressIndicator(),
                              title: Text('Loading...'),
                            ),
                          );
                        }
                        if (rideSnapshot.hasError || !rideSnapshot.hasData || !rideSnapshot.data!.exists) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.error, color: Colors.red),
                              title: const Text('Ride not found'),
                              subtitle: Text('Booked on: $bookedTimeStr'),
                            ),
                          );
                        }
                        
                        final ride = Ride.fromFirestore(rideSnapshot.data!);
                        final rideTimeStr = '${ride.rideTime.day}/${ride.rideTime.month}/${ride.rideTime.year} ${ride.rideTime.hour.toString().padLeft(2, '0')}:${ride.rideTime.minute.toString().padLeft(2, '0')}';
                        final bookedSeats = bookingData['seatsBooked'] ?? 1;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left side - Ride details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Route with icon
                                      Row(
                                        children: [
                                          Icon(
                                            ride.vehicleType == VehicleType.car 
                                              ? Icons.directions_car 
                                              : Icons.motorcycle,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${ride.source} → ${ride.destination}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Owner info
                                      Row(
                                        children: [
                                          const Icon(Icons.person, size: 16, color: Colors.black54),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Owner: ${ride.ownerName}',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // Ride time
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 16, color: Colors.black54),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Ride Time: $rideTimeStr',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // Vehicle type
                                      Row(
                                        children: [
                                          const Icon(Icons.info_outline, size: 16, color: Colors.black54),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Vehicle: ${ride.vehicleType == VehicleType.car ? 'Car' : 'Bike'}',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // Seats and price
                                      Row(
                                        children: [
                                          const Icon(Icons.event_seat, size: 16, color: Colors.black54),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Seats Booked: $bookedSeats',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                          const SizedBox(width: 16),
                                          const Icon(Icons.attach_money, size: 16, color: Colors.black54),
                                          Text(
                                            '৳${ride.pricePerSeat * bookedSeats}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // Booked timestamp
                                      Text(
                                        'Booked on: $bookedTimeStr',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black45,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      
                                      if (isCompleted && ratingGiven) ...[
                                        const SizedBox(height: 6),
                                        const Row(
                                          children: [
                                            Icon(Icons.star, size: 16, color: Colors.black),
                                            SizedBox(width: 4),
                                            Text(
                                              'Rating submitted',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(width: 12),
                                
                                // Right side - Done button
                                SizedBox(
                                  width: 80,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isCompleted && ratingGiven)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.black,
                                          size: 32,
                                        )
                                      else
                                        ElevatedButton(
                                          onPressed: () => showRatingDialog(
                                            context,
                                            bookingId: bookingId,
                                            rideId: rideId,
                                            ownerId: ride.ownerId,
                                            ownerName: ride.ownerName,
                                            userId: user.id,
                                            userName: user.name,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            'Done',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
