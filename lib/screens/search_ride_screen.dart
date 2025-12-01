import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/ride_provider.dart';
import '../core/services/ride_service.dart';
import '../core/widgets/location_input_widget.dart';

class SearchRideScreen extends StatefulWidget {
  const SearchRideScreen({super.key});
  @override
  State<SearchRideScreen> createState() => _SearchRideScreenState();
}

class _SearchRideScreenState extends State<SearchRideScreen> {
  LocationData? _sourceLocation;
  LocationData? _destinationLocation;
  bool _hasSearched = false;
  
  @override
  Widget build(BuildContext context) {
    final rideProv = context.watch<RideProvider>();
    final auth = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Book Ride')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            
            // From Field - Location Picker
            LocationInputWidget(
              label: 'From',
              hintText: 'Enter starting point or select from map',
              prefixIcon: Icons.location_on,
              onLocationSelected: (location) {
                setState(() => _sourceLocation = location);
              },
            ),
            
            const SizedBox(height: 20),
            
            // To Field - Location Picker
            LocationInputWidget(
              label: 'To',
              hintText: 'Enter destination or select from map',
              prefixIcon: Icons.flag,
              onLocationSelected: (location) {
                setState(() => _destinationLocation = location);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Search Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_sourceLocation == null || _sourceLocation!.address.trim().isEmpty || 
                      _destinationLocation == null || _destinationLocation!.address.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter both From and To locations')),
                    );
                    return;
                  }
                  if (_sourceLocation!.address.toLowerCase() == _destinationLocation!.address.toLowerCase()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('From and To locations cannot be the same')),
                    );
                    return;
                  }
                  setState(() => _hasSearched = true);
                  final route = '${_sourceLocation!.address} to ${_destinationLocation!.address}';
                  context.read<RideProvider>().search(route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            if (rideProv.isLoading) const LinearProgressIndicator(),
            
            Expanded(
              child: !_hasSearched
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey.shade600),
                          const SizedBox(height: 16),
                          Text(
                            'Enter From and To locations\nto search for rides',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : rideProv.results.isEmpty && !rideProv.isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade600),
                              const SizedBox(height: 16),
                              Text(
                                'No rides found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try searching with different locations',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                      itemCount: rideProv.results.length,
                      itemBuilder: (c, i) {
                        final r = rideProv.results[i];
                        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance.collection('users').doc(r.ownerId).get(),
                          builder: (context, ownerSnap) {
                            String profilePicUrl = '';
                            String ownerName = r.ownerName;
                            double ownerRating = 0.0;
                            int ratingCount = 0;
                            
                            if (ownerSnap.hasData && ownerSnap.data!.exists) {
                              final ownerData = ownerSnap.data!.data();
                              profilePicUrl = ownerData?['profilePictureUrl'] ?? '';
                              ownerName = ownerData?['name'] ?? r.ownerName;
                              final totalRatings = (ownerData?['totalRatings'] ?? 0.0).toDouble();
                              ratingCount = (ownerData?['ratingCount'] ?? 0) as int;
                              if (ratingCount > 0) {
                                ownerRating = totalRatings / ratingCount;
                              }
                            }
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: profilePicUrl.isNotEmpty
                                      ? NetworkImage(profilePicUrl)
                                      : null,
                                  child: profilePicUrl.isEmpty
                                      ? Text(
                                          ownerName.isNotEmpty ? ownerName[0].toUpperCase() : 'U',
                                        )
                                      : null,
                                ),
                                title: Text(r.route,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text('Owner: $ownerName',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        if (ratingCount > 0) ...[
                                          const SizedBox(width: 8),
                                          const Icon(Icons.star, size: 14, color: Colors.amber),
                                          const SizedBox(width: 2),
                                          Text('${ownerRating.toStringAsFixed(1)} ($ratingCount)',
                                              style: const TextStyle(fontSize: 12)),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            '${r.rideTime.day}/${r.rideTime.month}/${r.rideTime.year} ${r.rideTime.hour.toString().padLeft(2, '0')}:${r.rideTime.minute.toString().padLeft(2, '0')}',
                                            style: const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '${r.vehicleType.name.toUpperCase()} • ${r.remainingSeats} seats • ৳${r.pricePerSeat}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            trailing: SizedBox(
                              width: 90,
                              child: ElevatedButton(
                                onPressed: r.remainingSeats == 0 || auth == null
                                    ? null
                                    : () async {
                                        final ctrl = TextEditingController(text: '1');
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Select seats'),
                                            content: TextField(
                                              controller: ctrl,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'Seats (max ${r.remainingSeats})',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Book')),
                                            ],
                                          ),
                                        );
                                        if (confirmed != true) return;
                                        final seats = int.tryParse(ctrl.text.trim()) ?? 1;
                                        if (seats < 1 || seats > r.remainingSeats) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Enter 1 to ${r.remainingSeats} seats')),
                                            );
                                          }
                                          return;
                                        }
                                        final ok = await RideService().bookRide(rideId: r.id, userId: auth.id, seats: seats);
                                        if (ok && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booked successfully')));
                                          final route = '${_sourceLocation!.address} to ${_destinationLocation!.address}';
                                          // Refresh search to update remaining seats
                                          // ignore: use_build_context_synchronously
                                          context.read<RideProvider>().search(route);
                                        } else if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking failed')));
                                        }
                                      },
                                    child: const Text('Book'),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
