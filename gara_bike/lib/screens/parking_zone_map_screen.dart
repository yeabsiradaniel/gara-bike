
// Screen for viewing a parking zone and available bikes on a map in the Gara Bike app.
// Shows a pulsing beacon for the zone and markers for bikes, with a bottom sheet list.
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/screens/parking_zone_map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gara_bike/models/parking_zone_model.dart';
import 'package:gara_bike/models/bike_model.dart';
import 'package:gara_bike/api/api_service.dart';
import 'package:gara_bike/screens/reservation_screen.dart';


class ParkingZoneMapScreen extends StatefulWidget {
  // The parking zone to display
  final ParkingZone zone;
  const ParkingZoneMapScreen({super.key, required this.zone});

  @override
  State<ParkingZoneMapScreen> createState() => _ParkingZoneMapScreenState();
}

class _ParkingZoneMapScreenState extends State<ParkingZoneMapScreen> with TickerProviderStateMixin {
  // API service for fetching bikes
  final ApiService _apiService = ApiService();
  // List of bikes in the zone
  List<Bike> _bikesInZone = [];
  // Loading state
  bool _isLoading = true;
  // Animation controller for pulsing beacon
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Start pulsing animation and fetch bikes
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _fetchBikesInZone();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fetches bikes available in the parking zone
  Future<void> _fetchBikesInZone() async {
    try {
      final bikes = await _apiService.getBikesInZone(widget.zone.id);
      if (mounted) setState(() { _bikesInZone = bikes; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    // Position of the parking zone
    final zonePosition = LatLng(widget.zone.latitude, widget.zone.longitude);

    return Scaffold(
      appBar: AppBar(
        // App bar with zone name
        title: Text(widget.zone.name, style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Map showing the parking zone and bikes
          FlutterMap(
            options: MapOptions(
              initialCenter: zonePosition,
              initialZoom: 17.5,
            ),
            children: [
              // Tile layer for map
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              // Marker for the parking zone with pulsing beacon
              MarkerLayer(markers: [
                Marker(
                  point: zonePosition,
                  width: 80,
                  height: 80,
                  child: PulsingBeacon(controller: _animationController),
                ),
              ]),
              // Markers for each bike in the zone
              MarkerLayer(
                markers: _bikesInZone.map((bike) {
                  return Marker(
                    width: 40.0,
                    height: 40.0,
                    point: LatLng(bike.latitude, bike.longitude),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReservationScreen(bike: bike))),
                      child: Icon(
                        Icons.pedal_bike,
                        color: Colors.green[700],
                        size: 30,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 5.0,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          // Bottom sheet with list of bikes
          _buildBikesBottomSheet(),
        ],
      ),
    );
  }


  // Builds the bottom sheet listing available bikes in the zone
  Widget _buildBikesBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.2))],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              // Header with bike count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_bikesInZone.length} Bikes Available',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              // List of bikes or loading indicator
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ..._bikesInZone.map((bike) => ListTile(
                leading: Icon(Icons.battery_charging_full, color: bike.batteryLevel > 20 ? Colors.green : Colors.red),
                title: Text('Bike #${bike.id}', style: GoogleFonts.poppins()),
                subtitle: Text('${bike.batteryLevel}% Battery'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReservationScreen(bike: bike))),
              )).toList(),
            ],
          ),
        );
      },
    );
  }
}


// Helper widget for the pulsing beacon animation on the map
class PulsingBeacon extends StatelessWidget {
  const PulsingBeacon({
    super.key,
    required this.controller,
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
      child: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent.withOpacity(0.5),
            border: Border.all(color: Colors.blueAccent, width: 2),
          ),
        ),
      ),
    );
  }
}
