import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
        final address =
            '${place.street}, ${place.locality}, ${place.administrativeArea}';
        final location = LocationData(
          address: address,
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade900,
          ),
          readOnly: true,
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
  late GoogleMapController _mapController;
  LatLng _selectedPosition = const LatLng(23.8103, 90.4125); // Default: Dhaka
  String _selectedAddress = '';
  bool _isLoadingAddress = false;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedPosition = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _selectedAddress = widget.initialLocation!.address;
    }
    _updateMarker();
  }

  /// Update marker position on map
  void _updateMarker() {
    _markers = {
      Marker(
        markerId: const MarkerId('selected'),
        position: _selectedPosition,
        infoWindow: InfoWindow(title: _selectedAddress),
      ),
    };
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
        final address =
            '${place.street}, ${place.locality}, ${place.administrativeArea}';
        setState(() => _selectedAddress = address);
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
  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _updateMarker();
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
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 15,
            ),
            markers: _markers,
            onTap: _onMapTap,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
          ),
          // Center marker
          Center(
            child: Pointer(
              child: Icon(
                Icons.location_on,
                size: 40,
                color: Colors.red[700],
              ),
            ),
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

/// Pointer widget to show center marker
class Pointer extends StatelessWidget {
  final Widget child;

  const Pointer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, -12),
            child: child,
          ),
          CustomPaint(
            painter: PointerPainter(),
            size: const Size(30, 30),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for pointer indicator
class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Draw circle at top
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 6, paint);

    // Draw triangle pointing down
    final path = Path();
    path.moveTo(size.width / 2 - 8, size.height / 2);
    path.lineTo(size.width / 2 + 8, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PointerPainter oldDelegate) => false;
}
