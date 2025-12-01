import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/providers/auth_provider.dart';
import '../core/models/ride_model.dart';
import '../core/services/ride_service.dart';
import '../helpers/rating_dialogs.dart';

class MyOfferedRidesScreen extends StatelessWidget {
  const MyOfferedRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Offered Rides')),
      body: user == null
          ? const Center(child: Text('Please login to view your offered rides'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
          .collection('rides')
          .where('ownerId', isEqualTo: user.id)
          .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No rides offered yet', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Start offering rides to help fellow students!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                final rides = docs.map((d) => Ride.fromFirestore(d)).toList()
                  ..sort((a, b) => b.rideTime.compareTo(a.rideTime));
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final ride = rides[index];
                    final timeStr = '${ride.rideTime.day}/${ride.rideTime.month}/${ride.rideTime.year} ${ride.rideTime.hour.toString().padLeft(2, '0')}:${ride.rideTime.minute.toString().padLeft(2, '0')}';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          ride.vehicleType == VehicleType.car ? Icons.directions_car : Icons.motorcycle,
                          color: Colors.white,
                        ),
                        title: Text(ride.route, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time: $timeStr'),
                            Text('Seats: ${ride.remainingSeats}/${ride.availableSeats} • Price: ৳${ride.pricePerSeat}'),
                            if (ride.bookedSeats > 0)
                              const Text('Locked after booking', style: TextStyle(color: Colors.orange)),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            if (ride.bookedSeats > 0)
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                tooltip: 'Rate bookers',
                                onPressed: () => showRateBookersDialog(context, ride.id, user.id, user.name),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              tooltip: ride.bookedSeats > 0 ? 'Locked after booking' : 'Edit',
                              onPressed: ride.bookedSeats > 0
                                  ? null
                                  : () async {
                                      final srcCtrl = TextEditingController(text: ride.source);
                                      final dstCtrl = TextEditingController(text: ride.destination);
                                      final seatsCtrl = TextEditingController(text: ride.availableSeats.toString());
                                      final priceCtrl = TextEditingController(text: ride.pricePerSeat.toString());
                                      TimeOfDay time = TimeOfDay(hour: ride.rideTime.hour, minute: ride.rideTime.minute);
                                      final saved = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) {
                                          return StatefulBuilder(
                                            builder: (ctx, setSt) => AlertDialog(
                                              title: const Text('Edit Ride'),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextField(controller: srcCtrl, decoration: const InputDecoration(labelText: 'Starting point')),
                                                    const SizedBox(height: 8),
                                                    TextField(controller: dstCtrl, decoration: const InputDecoration(labelText: 'Destination')),
                                                    const SizedBox(height: 8),
                                                    TextField(controller: seatsCtrl, decoration: const InputDecoration(labelText: 'Available seats'), keyboardType: TextInputType.number),
                                                    const SizedBox(height: 8),
                                                    TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price per seat'), keyboardType: TextInputType.number),
                                                    const SizedBox(height: 8),
                                                    ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Text('Time: ${time.format(ctx)}'),
                                                      trailing: const Icon(Icons.access_time),
                                                      onTap: () async {
                                                        final picked = await showTimePicker(context: ctx, initialTime: time);
                                                        if (picked != null) setSt(() => time = picked);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                      if (saved == true) {
                                        try {
                                          final t = ride.rideTime;
                                          final newRideTime = DateTime(t.year, t.month, t.day, time.hour, time.minute);
                                          final ok = await RideService().updateRide(
                                            ride.id,
                                            source: srcCtrl.text.trim(),
                                            destination: dstCtrl.text.trim(),
                                            availableSeats: int.tryParse(seatsCtrl.text.trim()),
                                            pricePerSeat: int.tryParse(priceCtrl.text.trim()),
                                            rideTime: newRideTime,
                                          );
                                          if (ok && context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ride updated')));
                                          } else if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update failed')));
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                          }
                                        }
                                      }
                                    },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: ride.bookedSeats > 0 ? 'Cannot delete after booking' : 'Delete',
                              onPressed: ride.bookedSeats > 0
                                  ? null
                                  : () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Ride'),
                                          content: const Text('Are you sure you want to delete this ride offer?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        try {
                                          await FirebaseFirestore.instance.collection('rides').doc(ride.id).delete();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Ride deleted successfully')),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error deleting ride: $e')),
                                            );
                                          }
                                        }
                                      }
                                    },
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
