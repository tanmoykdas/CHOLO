import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Model to hold location data
class LocationData {
  final String address;
  final double latitude;
  final double longitude;

  LocationData({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() => address;
}

/// Widget for selecting location with both manual input and map selection
class LocationInputWidget extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final Function(LocationData) onLocationSelected;
  final LocationData? initialLocation;

  const LocationInputWidget({
    Key? key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.onLocationSelected,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<LocationInputWidget> createState() => _LocationInputWidgetState();
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  late TextEditingController _controller;
  LocationData? _selectedLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _controller = TextEditingController(
      text: widget.initialLocation?.address ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Get current location using GPS
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is required')),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        
        // Build detailed address
        List<String> addressParts = [];
        if (place.name != null && place.name!.isNotEmpty) addressParts.add(place.name!);
        if (place.street != null && place.street!.isNotEmpty && place.street != place.name) addressParts.add(place.street!);
        if (place.subLocality != null && place.subLocality!.isNotEmpty) addressParts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty && 
            (place.locality == null || place.locality!.isEmpty)) addressParts.add(place.administrativeArea!);
        
        final address = addressParts.toSet().join(', ');
        final location = LocationData(
          address: address.isNotEmpty ? address : 'Current Location',
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _updateLocation(location);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  /// Open map picker to select location
  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<LocationData>(
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLocation: _selectedLocation,
        ),
      ),
    );

    if (result != null) {
      _updateLocation(result);
    }
  }

  /// Update location and notify parent
  void _updateLocation(LocationData location) {
    setState(() {
      _selectedLocation = location;
      _controller.text = location.address;
    });
    widget.onLocationSelected(location);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            prefixIcon: Icon(widget.prefixIcon),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Use Current Location button
                if (_isLoadingLocation)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.my_location),
                    tooltip: 'Use current location',
                    onPressed: _getCurrentLocation,
                  ),
                // Map picker button
                IconButton(
                  icon: const Icon(Icons.map),
                  tooltip: 'Select from map',
                  onPressed: _openMapPicker,
                ),
              ],
            ),
            filled: true,
            fillColor: Colors.grey.shade900,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            // Update location when user types (minimum 1 character)
            if (value.trim().isNotEmpty) {
              // Create a location from text input
              setState(() {
                _selectedLocation = LocationData(
                  address: value.trim(),
                  latitude: 0, // Will be updated when map is used
                  longitude: 0,
                );
              });
              widget.onLocationSelected(_selectedLocation!);
            }
          },
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Location required' : null,
        ),
        if (_selectedLocation != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lon: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
      ],
    );
  }
}

/// Map picker screen for selecting location on map
class MapPickerScreen extends StatefulWidget {
  final LocationData? initialLocation;

  const MapPickerScreen({
    Key? key,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late MapController _mapController;
  LatLng _selectedPosition = LatLng(23.8103, 90.4125); // Default: Dhaka
  String _selectedAddress = '';
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialLocation != null) {
      _selectedPosition = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _selectedAddress = widget.initialLocation!.address;
    } else {
      _getAddressFromCoordinates(_selectedPosition);
    }
  }

  /// Get address from coordinates using reverse geocoding
  Future<void> _getAddressFromCoordinates(LatLng position) async {
    setState(() => _isLoadingAddress = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        
        // Build a detailed, readable address
        List<String> addressParts = [];
        
        // Add street/name if available
        if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        }
        
        // Add street if different from name
        if (place.street != null && place.street!.isNotEmpty && place.street != place.name) {
          addressParts.add(place.street!);
        }
        
        // Add sublocality (neighborhood)
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        
        // Add locality (city/town)
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        
        // Add administrative area (state/division) if locality is not available
        if (place.administrativeArea != null && 
            place.administrativeArea!.isNotEmpty &&
            (place.locality == null || place.locality!.isEmpty)) {
          addressParts.add(place.administrativeArea!);
        }
        
        // Add postal code if available
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }
        
        // Build final address, removing duplicates
        final address = addressParts.toSet().join(', ');
        setState(() => _selectedAddress = address.isNotEmpty ? address : 'Unknown Location');
      } else {
        setState(() => _selectedAddress = 'Location at ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting address: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  /// Handle map tap to select location
  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _getAddressFromCoordinates(position);
  }

  /// Confirm location selection
  void _confirmLocation() {
    final location = LocationData(
      address: _selectedAddress,
      latitude: _selectedPosition.latitude,
      longitude: _selectedPosition.longitude,
    );
    Navigator.of(context).pop(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition,
              initialZoom: 15.0,
              onTap: _onMapTap,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.cholo.cholo',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPosition,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Bottom sheet with address and confirm button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selected Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isLoadingAddress)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedAddress.isNotEmpty)
                            Text(
                              _selectedAddress,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else
                            Text(
                              'Loading address...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Lat: ${_selectedPosition.latitude.toStringAsFixed(6)}, Lon: ${_selectedPosition.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedAddress.isEmpty
                            ? null
                            : _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoadingAddress
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black,
                                  ),
                                ),
                              )
                            : const Text(
                                'Confirm Location',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
