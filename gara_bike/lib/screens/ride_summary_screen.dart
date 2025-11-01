
// Ride summary screen for Gara Bike app.
// Shows a map of the ride, trip statistics, and a summary card with Lottie animations.
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/screens/ride_summary_screen.dart

import 'dart:ui'; // Required for ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart' hide Marker; // Import the Lottie package
import 'package:latlong2/latlong.dart';
import 'package:gara_bike/models/ride_model.dart';
import 'package:gara_bike/main.dart';  // To navigate home
import 'package:gara_bike/l10n/app_localizations.dart';

class RideSummaryScreen extends StatefulWidget {
  // The completed ride to summarize
  final Ride completedRide;
  const RideSummaryScreen({super.key, required this.completedRide});

  @override
  State<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends State<RideSummaryScreen> {
  // Controller for the map
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Fit the map to show the ride bounds after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapToBounds();
    });
  }

  // Adjusts the map view to fit the ride's start and end points
  void _fitMapToBounds() {
    if (mounted && widget.completedRide.endLatitude != null) {
      final start = LatLng(widget.completedRide.startLatitude, widget.completedRide.startLongitude);
      final end = LatLng(widget.completedRide.endLatitude!, widget.completedRide.endLongitude!);

      if (start.latitude != end.latitude || start.longitude != end.longitude) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints([start, end]),
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 280),
          ),
        );
      } else {
        _mapController.move(start, 15.0);
      }
    }
  }

  // Formats the ride duration as 'Xm Ys'
  String _formatRideDuration() {
    if (widget.completedRide.endTime == null) return AppLocalizations.of(context)!.zeroMinsZeroSecs;
    final duration = DateTime.parse(widget.completedRide.endTime!).difference(DateTime.parse(widget.completedRide.startTime));
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }

  // Formats the ride distance in kilometers
  String _formatDistance() {
    final distance = widget.completedRide.distanceMeters;
    if (distance == null) return AppLocalizations.of(context)!.zeroPointZeroZero;
    return (distance / 1000).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    // Start and end points for the ride
    final startPoint = LatLng(widget.completedRide.startLatitude, widget.completedRide.startLongitude);
    final endPoint = widget.completedRide.endLatitude != null
        ? LatLng(widget.completedRide.endLatitude!, widget.completedRide.endLongitude!)
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // Map showing the ride route
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: startPoint,
              initialZoom: 15,
            ),
            children: [
              // OpenStreetMap tile layer
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              // Markers for start and end points
              MarkerLayer(markers: [
                Marker(point: startPoint, child: const Icon(Icons.trip_origin, color: Colors.green, size: 40)),
                if (endPoint != null) Marker(point: endPoint, child: const Icon(Icons.location_on, color: Colors.red, size: 40)),
              ]),
            ],
          ),
          // Summary card overlay
          _buildSummaryCard(),
        ],
      ),
    );
  }

  // Builds the summary card overlay with ride stats and actions
  Widget _buildSummaryCard() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.85),
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  AppLocalizations.of(context)!.tripCompleted,
                  style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Row of fare and duration stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('assets/animations/fare.json', AppLocalizations.of(context)!.etb + ' ' + (widget.completedRide.cost?.toStringAsFixed(2) ?? AppLocalizations.of(context)!.zeroPointZeroZero), AppLocalizations.of(context)!.fare),
                    _buildStatItem('assets/animations/timer.json', _formatRideDuration(), AppLocalizations.of(context)!.duration),
                  ],
                ),
                const SizedBox(height: 20),
                // Row of distance and calories stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('assets/animations/route.json', '${_formatDistance()} ' + AppLocalizations.of(context)!.km, AppLocalizations.of(context)!.distance),
                    _buildStatItem('assets/animations/calories.json', '${widget.completedRide.caloriesBurned ?? AppLocalizations.of(context)!.zero} ' + AppLocalizations.of(context)!.kcal, AppLocalizations.of(context)!.calories),
                  ],
                ),

                const SizedBox(height: 32),
                // Done button to return to home
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const AuthWrapper()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(AppLocalizations.of(context)!.done, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to display a stat with a Lottie animation, value, and label
  Widget _buildStatItem(String lottieAsset, String value, String label) {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          // Lottie animation for the stat
          Lottie.asset(
            lottieAsset,
            height: 45,
            width: 45,
            // Shows a fallback icon if the Lottie file fails to load
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error_outline, color: Colors.red, size: 28);
            },
          ),
          const SizedBox(height: 8),
          // Stat value
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          // Stat label
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}