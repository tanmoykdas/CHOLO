import 'package:flutter/material.dart';
import 'package:cholo/models/ride_model.dart';

class RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback? onTap;
  final Widget? trailing;

  const RideCard({super.key, required this.ride, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          ride.vehicleType.toLowerCase() == 'bike' ? Icons.pedal_bike : Icons.directions_car,
          size: 40,
          color: Colors.blueAccent,
        ),
        title: Text('${ride.vehicleType} - ${ride.route}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Time: ${ride.time}\nPrice: \$${ride.pricePerSeat} per seat\nSeats Available: ${ride.availableSeats}',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        trailing: trailing,
      ),
    );
  }
}
