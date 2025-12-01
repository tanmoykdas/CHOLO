import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/services/ride_service.dart';
import '../core/models/ride_model.dart';
import '../core/widgets/location_input_widget.dart';

class OfferRideScreen extends StatefulWidget {
  const OfferRideScreen({super.key});
  @override
  State<OfferRideScreen> createState() => _OfferRideScreenState();
}

class _OfferRideScreenState extends State<OfferRideScreen> {
  final _form = GlobalKey<FormState>();
  String _vehicle = 'car';
  LocationData? _sourceLocation;
  LocationData? _destinationLocation;
  int _seats = 1;
  int _price = 0;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Share Ride')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              
              // Vehicle Type
              DropdownButtonFormField<String>(
                value: _vehicle,
                decoration: InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                ),
                items: const [
                  DropdownMenuItem(value: 'car', child: Text('Car')),
                  DropdownMenuItem(value: 'bike', child: Text('Bike')),
                ],
                onChanged: (v) => setState(() => _vehicle = v!),
              ),
              
              const SizedBox(height: 20),
              
              // From (Starting Point) - Location Picker
              LocationInputWidget(
                label: 'From',
                hintText: 'Enter starting point or select from map',
                prefixIcon: Icons.location_on,
                onLocationSelected: (location) {
                  setState(() => _sourceLocation = location);
                },
              ),
              
              const SizedBox(height: 20),
              
              // To (Destination) - Location Picker
              LocationInputWidget(
                label: 'To',
                hintText: 'Enter destination or select from map',
                prefixIcon: Icons.flag,
                onLocationSelected: (location) {
                  setState(() => _destinationLocation = location);
                },
              ),
              
              const SizedBox(height: 20),
              
              // Available Seats
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Available Seats',
                  hintText: 'Enter number of seats',
                  prefixIcon: const Icon(Icons.event_seat),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final i = int.tryParse(v ?? '');
                  if (i == null || i <= 0) {
                    return 'Enter seats > 0';
                  }
                  return null;
                },
                onSaved: (v) => _seats = int.tryParse(v ?? '1') ?? 1,
              ),
              
              const SizedBox(height: 20),
              
              // Price per Seat
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price per Seat',
                  hintText: 'Enter price',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final i = int.tryParse(v ?? '');
                  if (i == null || i < 0) {
                    return 'Enter valid price';
                  }
                  return null;
                },
                onSaved: (v) => _price = int.tryParse(v ?? '0') ?? 0,
              ),
              
              const SizedBox(height: 20),
              
              // Ride Time
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: _time);
                    if (picked != null) setState(() => _time = picked);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ride Time: ${_time.format(context)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Share Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () async {
                        if (!(_form.currentState?.validate() ?? false)) return;
                        _form.currentState!.save();
                        
                        // Validate location selections
                        if (_sourceLocation == null || _sourceLocation!.address.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter starting location')),
                          );
                          return;
                        }
                        if (_destinationLocation == null || _destinationLocation!.address.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter destination')),
                          );
                          return;
                        }
                        
                        // Prevent sharing if source and destination are the same
                        if (_sourceLocation!.address.toLowerCase() == _destinationLocation!.address.toLowerCase()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Starting point and destination cannot be the same'),
                            ),
                          );
                          return;
                        }
                        setState(() => _submitting = true);
                        try {
                          final now = DateTime.now();
                          final rideDate = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
                          final ownerId = auth!.id;
                          final ownerName = auth.name;
                          final route = '${_sourceLocation!.address} to ${_destinationLocation!.address}';
                          final ride = Ride(
                            id: 'temp',
                            ownerId: ownerId,
                            ownerName: ownerName,
                            vehicleType: _vehicle == 'car' ? VehicleType.car : VehicleType.bike,
                            route: route,
                            source: _sourceLocation!.address,
                            destination: _destinationLocation!.address,
                            routeKey: Ride.buildRouteKey(_sourceLocation!.address, _destinationLocation!.address),
                            availableSeats: _seats,
                            pricePerSeat: _price,
                            rideTime: rideDate,
                          );
                          await RideService().createRide(ride);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ride shared')));
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        } finally {
                          if (mounted) setState(() => _submitting = false);
                        }
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
