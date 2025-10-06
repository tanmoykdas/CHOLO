import 'package:flutter/material.dart';
import 'package:your_project/models/ride_model.dart'; // Import your Ride model

class RideCard extends StatelessWidget {
  final Ride ride;
  final Function onTap; // Callback when the card is tapped (e.g., navigate to ride details)

  // Constructor for the RideCard widget
  RideCard({required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      child: ListTile(
        onTap: () => onTap(), // When the card is tapped, execute the onTap callback
        contentPadding: EdgeInsets.all(16),
        leading: Icon(
          Icons.directions_car, // You can customize this icon based on vehicle type
          size: 40,
          color: Colors.blueAccent,
        ),
        title: Text(
          '${ride.vehicleType} - ${ride.route}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Time: ${ride.time}\nPrice: \$${ride.pricePerSeat} per seat\nSeats Available: ${ride.availableSeats}',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}
