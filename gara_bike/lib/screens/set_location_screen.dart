// lib/screens/set_location_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class SetLocationScreen extends StatefulWidget {
  final LatLng initialCenter;
  const SetLocationScreen({super.key, required this.initialCenter});

  @override
  State<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialCenter;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _confirmLocation() async {
    final locationName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Name this Location', style: GoogleFonts.poppins()),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g., Home, Office, Gym'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                Navigator.of(context).pop(_nameController.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (mounted && locationName != null && locationName.isNotEmpty && _selectedLocation != null) {
      Navigator.of(context).pop({
        'name': locationName,
        'lat': _selectedLocation!.latitude,
        'lon': _selectedLocation!.longitude,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Location', style: GoogleFonts.poppins()),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialCenter,
              initialZoom: 17.0,
              onPositionChanged: (position, hasGesture) {
                _selectedLocation = position.center;
              },
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
            ],
          ),
          // Central marker pin
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0), // Adjust for pin's shadow
                child: Icon(Icons.location_pin, size: 50.0, color: Colors.red[700]),
              ),
            ),
          ),
          // Confirm button at the bottom
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text('Confirm Location', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
              onPressed: _confirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}