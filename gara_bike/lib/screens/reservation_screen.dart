
// Reservation screen for reserving a bike in the Gara Bike app.
// Shows a map, route, reservation timer, and allows confirming or cancelling a reservation.
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/screens/reservation_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gara_bike/models/bike_model.dart';
import 'package:gara_bike/providers/bike_provider.dart';
import 'package:gara_bike/api/api_service.dart';
import 'package:gara_bike/screens/qr_scan_screen.dart';


class ReservationScreen extends StatefulWidget {
  // The bike to reserve
  final Bike bike;
  const ReservationScreen({super.key, required this.bike});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  // Map controller for the route map
  final MapController _mapController = MapController();
  // API service for route and reservation
  final ApiService _apiService = ApiService();

  // User's current position
  LatLng? _userPosition;
  // Route points from user to bike
  List<LatLng> _routePoints = [];
  // Loading state
  bool _isLoading = true;
  // Selected reservation duration in minutes
  int _selectedDuration = 5;

  // Timer for reservation countdown
  Timer? _countdownTimer;
  // Remaining seconds for reservation
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    // Setup reservation state and fetch route after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupInitialState();
    });
    _fetchRouteData();
  }

  // Checks for an existing reservation and starts countdown if needed
  void _setupInitialState() {
    final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
    final existingReservation = bikeProvider.activeReservation;

    if (existingReservation != null && existingReservation.id == widget.bike.id) {
      final expiresAt = DateTime.parse(existingReservation.reservationExpiresAt!);
      final duration = expiresAt.difference(DateTime.now());
      if (duration.inSeconds > 0) {
        _startCountdown(duration.inSeconds);
      }
    }
  }


  @override
  void dispose() {
    // Cancel countdown timer on dispose
    _countdownTimer?.cancel();
    super.dispose();
  }


  // Fetches the route from the user's location to the bike
  Future<void> _fetchRouteData() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final userPos = LatLng(position.latitude, position.longitude);
      final bikePos = LatLng(widget.bike.latitude, widget.bike.longitude);
      final route = await _apiService.getRoute(userPos, bikePos);

      if (mounted) {
        setState(() {
          _userPosition = userPos;
          _routePoints = route;
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: LatLngBounds.fromPoints([userPos, bikePos]),
                padding: const EdgeInsets.all(50.0),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  // Confirms the reservation and starts the countdown
  Future<void> _confirmReservation() async {
    setState(() => _isLoading = true);
    final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
    final response = await bikeProvider.reserveBike(widget.bike.id, _selectedDuration);

    if (mounted) {
      setState(() => _isLoading = false);
      if (response['success']) {
        final newReservation = bikeProvider.activeReservation;
        if (newReservation != null) {
          final expiresAt = DateTime.parse(newReservation.reservationExpiresAt!);
          final duration = expiresAt.difference(DateTime.now());
          _startCountdown(duration.inSeconds);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error']?.toString() ?? 'Reservation failed.'), backgroundColor: Colors.red),
        );
      }
    }
  }


  // Cancels the reservation and shows a message
  Future<void> _cancelReservation() async {
    setState(() => _isLoading = true);
    final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
    final response = await bikeProvider.cancelReservation(widget.bike.id, _selectedDuration);

    if (mounted) {
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reservation cancelled. Fee charged: ${response['data']['fee_charged']} ETB'), backgroundColor: Colors.orange)
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error']?.toString() ?? 'Cancellation failed.'), backgroundColor: Colors.red),
        );
      }
    }
  }


  // Starts the countdown timer for the reservation
  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    _remainingSeconds = seconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if(mounted) setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reservation expired!'), backgroundColor: Colors.red));
          Provider.of<BikeProvider>(context, listen: false).fetchActiveReservation();
          Navigator.of(context).pop();
        }
      }
    });
  }


  // Returns the countdown text in mm:ss format
  String get _countdownText {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // App bar with bike ID
        title: Text('Reserve Bike #${widget.bike.id}', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading && _userPosition == null
          // Show loading indicator if still loading and no user position
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Map showing user, bike, and route
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.bike.latitude, widget.bike.longitude),
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              if (_routePoints.isNotEmpty) PolylineLayer(polylines: [Polyline(points: _routePoints, strokeWidth: 5.0, color: Colors.blueAccent)]),
              MarkerLayer(
                markers: [
                  if (_userPosition != null) Marker(point: _userPosition!, child: Icon(Icons.my_location, color: Theme.of(context).primaryColor, size: 35)),
                  Marker(point: LatLng(widget.bike.latitude, widget.bike.longitude), child: Icon(Icons.pedal_bike, color: Colors.red[700], size: 40)),
                ],
              ),
            ],
          ),
          // Bottom card for reservation actions or countdown
          _buildBottomCard(context),
          // Overlay loading indicator if loading
          if (_isLoading) Container(color: Colors.black.withOpacity(0.3), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }


  // Builds the bottom card for reservation actions or countdown
  Widget _buildBottomCard(BuildContext context) {
    return Consumer<BikeProvider>(
      builder: (context, bikeProvider, child) {
        final activeReservation = bikeProvider.activeReservation;
        final bool isThisBikeReserved = activeReservation != null && activeReservation.id == widget.bike.id;

        return Positioned(
          bottom: 0, left: 0, right: 0,
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 10,
            shadowColor: Colors.black.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isThisBikeReserved ? _buildCountdownView() : _buildReservationView(),
              ),
            ),
          ),
        );
      },
    );
  }


  // View for selecting reservation duration and confirming
  Widget _buildReservationView() {
    return Column(
      key: const ValueKey('reservationView'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Reserve This Bike', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        // Dropdown for selecting reservation duration
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedDuration,
              isExpanded: true,
              icon: const Icon(Icons.timer_outlined),
              items: [5, 10, 15, 20, 25, 30].map((int value) => DropdownMenuItem<int>(value: value, child: Text('$value minutes', style: GoogleFonts.poppins(fontSize: 16)))).toList(),
              onChanged: (newValue) {
                if (newValue != null) setState(() => _selectedDuration = newValue);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Confirm reservation button
        ElevatedButton(
          onPressed: _confirmReservation,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text('Confirm & Reserve', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ],
    );
  }


  // View for showing countdown and actions after reservation
  Widget _buildCountdownView() {
    return Column(
      key: const ValueKey('countdownView'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Bike is reserved! Time remaining:', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700])),
        const SizedBox(height: 8),
        // Countdown timer
        Text(_countdownText, style: GoogleFonts.robotoMono(fontSize: 40, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        // Button to scan QR code when arrived
        ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
          label: Text('I\'ve Arrived, Scan QR', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScanScreen())),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
        const SizedBox(height: 8),
        // Button to cancel reservation
        TextButton(onPressed: _cancelReservation, child: Text('Cancel Reservation', style: GoogleFonts.poppins(color: Colors.red[700], fontWeight: FontWeight.w500))),
      ],
    );
  }
}
