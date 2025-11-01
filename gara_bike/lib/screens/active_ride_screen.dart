
// Author: Yeabsira Daniel
// Date: JAN/26/2025
//
// This file implements the ActiveRideScreen, which displays the user's current ride in progress.
// It shows a live map, ride stats, closest parking zones, and allows the user to end the ride.
// The screen listens to location updates and animates parking zone beacons.
//
// Main components:
// - ActiveRideScreen: StatefulWidget that manages the ride UI, map, and ride state.
// - PulsingBeacon: Animated widget for parking zone beacons on the map.

// lib/screens/active_ride_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gara_bike/screens/ride_summary_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart' hide Marker; // Hide Lottie's Marker
import 'package:gara_bike/providers/ride_provider.dart';
import 'package:gara_bike/models/parking_zone_model.dart';
import 'package:gara_bike/l10n/app_localizations.dart';

import '../models/ride_model.dart';


/// Screen that displays the user's current ride, live map, stats, and end-ride action.
class ActiveRideScreen extends StatefulWidget {
  const ActiveRideScreen({super.key});
  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}


/// State for [ActiveRideScreen]. Handles map, ride timer, location, and UI updates.
class _ActiveRideScreenState extends State<ActiveRideScreen> with TickerProviderStateMixin {
  /// Controller for the map widget.
  final MapController _mapController = MapController();
  /// Subscription to the user's position stream.
  StreamSubscription<Position>? _positionStream;
  /// Timer for updating the ride duration.
  Timer? _rideTimer;
  /// The current duration of the ride.
  Duration _rideDuration = Duration.zero;
  /// The user's current position as LatLng.
  LatLng? _userPosition;

  /// Animation controllers for each parking zone beacon.
  List<AnimationController> _beaconControllers = [];


  @override
  void initState() {
    super.initState();
    // Initialize the screen: get location, fetch zones, start timer, and listen to position.
    _initializeScreen();
  }

  /// Initializes the screen: gets initial location, fetches parking zones, starts ride timer,
  /// sets up beacon animations, and begins listening to position updates.
  Future<void> _initializeScreen() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() => _userPosition = LatLng(position.latitude, position.longitude));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToGetInitialLocation(e.toString()))));
        Navigator.of(context).pop();
        return;
      }
    }

    await rideProvider.fetchAllParkingZones();

    // Start ride timer if there is an active ride.
    if (rideProvider.activeRide != null) {
      final startTime = DateTime.parse(rideProvider.activeRide!.startTime);
      _rideTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) setState(() => _rideDuration = DateTime.now().difference(startTime));
      });
    }

    // Set up beacon animation controllers for each parking zone.
    if (mounted) {
      for (var controller in _beaconControllers) {
        controller.dispose();
      }
      setState(() {
        _beaconControllers = List.generate(
          rideProvider.allParkingZones.length,
          (index) => AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(),
        );
      });
    }
    _listenToPosition();
  }


  /// Listens to the user's position stream and updates the map and closest zone.
  void _listenToPosition() {
    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {
        final newPosition = LatLng(position.latitude, position.longitude);
        setState(() => _userPosition = newPosition);
        // Move the map to the new position if needed.
        if (_mapController.camera.center != newPosition) {
          _mapController.move(newPosition, _mapController.camera.zoom);
        }
        // Update the closest parking zone in the provider.
        Provider.of<RideProvider>(context, listen: false).updateClosestZone(position);
      }
    });
  }


  @override
  void dispose() {
    // Clean up streams, timers, and animation controllers.
    _positionStream?.cancel();
    _rideTimer?.cancel();
    for (var controller in _beaconControllers) {
      controller.dispose();
    }
    super.dispose();
  }


  /// Formats a [Duration] as mm:ss for display.
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }


  /// Ends the current ride and navigates to the ride summary screen if successful.
  Future<void> _endRide() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final response = await rideProvider.endActiveRide();

    if (mounted) {
      if (response['success']) {
        final completedRide = Ride.fromJson(response['data']);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => RideSummaryScreen(completedRide: completedRide)),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error']?['detail']?.toString() ?? 'Failed to end ride.'), backgroundColor: Colors.red),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Main UI: map with beacons, user marker, and ride info sheet.
    return Scaffold(
      body: _userPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Map with parking zone beacons and user marker
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(initialCenter: _userPosition!, initialZoom: 17.0, maxZoom: 18.0),
                  children: [
                    TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                    _buildParkingZoneBeacons(),
                    if (_userPosition != null)
                      MarkerLayer(markers: [
                        Marker(
                          point: _userPosition!,
                          child: const Icon(Icons.directions_bike, color: Colors.blueAccent, size: 35),
                        ),
                      ]),
                  ],
                ),
                // Draggable sheet with ride stats and actions
                _buildDraggableSheet(),
              ],
            ),
    );
  }


  /// Builds animated beacons for each parking zone on the map.
  Widget _buildParkingZoneBeacons() {
    final zones = Provider.of<RideProvider>(context).allParkingZones;
    if (zones.length != _beaconControllers.length) return const SizedBox.shrink();
    return MarkerLayer(
      markers: List.generate(zones.length, (index) {
        final zone = zones[index];
        return Marker(
          width: 80, height: 80,
          point: LatLng(zone.latitude, zone.longitude),
          child: PulsingBeacon(controller: _beaconControllers[index]),
        );
      }),
    );
  }


  /// Builds the draggable bottom sheet with ride stats, info, and end-ride button.
  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.40,
      minChildSize: 0.40,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              // Ride in progress title
              Text(
                AppLocalizations.of(context)!.rideInProgress,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
              const SizedBox(height: 20),
              // Dashboard stats (duration, distance, calories)
              Consumer<RideProvider>(
                builder: (context, provider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDashboardStat('assets/animations/timer.json', _formatDuration(_rideDuration), AppLocalizations.of(context)!.duration),
                      _buildDashboardStat('assets/animations/route.json', provider.distanceInKm, AppLocalizations.of(context)!.km),
                      _buildDashboardStat('assets/animations/calories.json', provider.caloriesBurned.toStringAsFixed(0), AppLocalizations.of(context)!.kcal),
                    ],
                  );
                },
              ),
              const Divider(height: 32, indent: 20, endIndent: 20),
              // Info tile for current bike
              _buildInfoTile(
                icon: Icons.pedal_bike,
                iconColor: Colors.black87,
                title: AppLocalizations.of(context)!.currentlyRiding,
                subtitle: AppLocalizations.of(context)!.bike(Provider.of<RideProvider>(context).activeRide?.bike.id.toString() ?? ''),
              ),
              // Info tile for closest parking zone
              Consumer<RideProvider>(
                builder: (context, provider, child) {
                  return _buildInfoTile(
                    icon: Icons.local_parking_outlined,
                    iconColor: Colors.blueAccent,
                    title: AppLocalizations.of(context)!.closestParkingZone,
                    subtitle: provider.closestZone?.name ?? AppLocalizations.of(context)!.searching,
                    trailing: provider.distanceToClosestZone != null ? '${provider.distanceToClosestZone!.round()}m' : '--',
                  );
                },
              ),
              const SizedBox(height: 24),
              // End ride button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ElevatedButton.icon(
                  onPressed: _endRide,
                  icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
                  label: Text(AppLocalizations.of(context)!.endRide, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  /// Builds a dashboard stat widget with a Lottie animation, value, and label.
  Widget _buildDashboardStat(String lottieAsset, String value, String label) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Lottie.asset(
            lottieAsset,
            height: 35,
            width: 35,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error_outline, color: Colors.red, size: 24);
            },
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.robotoMono(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }


  /// Builds an info tile for the ride sheet (e.g., current bike, closest zone).
  Widget _buildInfoTile({required IconData icon, required Color iconColor, required String title, required String subtitle, String? trailing}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
      trailing: trailing != null ? Text(trailing, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)) : null,
    );
  }
}


/// Widget for displaying a pulsing beacon animation, used for parking zones on the map.
class PulsingBeacon extends StatelessWidget {
  /// Animation controller for the pulsing effect.
  final AnimationController controller;

  const PulsingBeacon({
    super.key,
    required this.controller,
  });

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