
// Author: Yeabsira Daniel
// Date: JAN/26/2025
//
// This file implements the HomeScreen, the main landing page for the Gara Bike app.
// It displays a greeting, weather info, a list of nearby bikes, and a floating QR scan button.
// The screen checks for active rides and reservations, and fetches location-based data on startup.
//
// Main components:
// - HomeScreen: StatefulWidget that manages the home UI and data fetching.
// - _buildBikesList: Shows a horizontal list of nearby bikes.
// - _buildReservationBanner: Shows a banner if the user has an active reservation.

// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gara_bike/providers/auth_provider.dart';
import 'package:gara_bike/providers/bike_provider.dart';
import 'package:gara_bike/providers/weather_provider.dart';
import 'package:gara_bike/widgets/app_drawer.dart';
import 'package:gara_bike/widgets/weather_card.dart';
import 'package:gara_bike/widgets/bike_card.dart';
import 'package:gara_bike/screens/search_screen.dart';
import 'package:gara_bike/screens/reservation_screen.dart';
import 'package:gara_bike/models/bike_model.dart';
import 'package:gara_bike/screens/qr_scan_screen.dart';
import 'package:gara_bike/l10n/app_localizations.dart';

import '../providers/ride_provider.dart';
import 'active_ride_screen.dart';


/// The main landing screen for the app, showing greeting, weather, bikes, and quick actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


/// State for [HomeScreen]. Handles data fetching, ride checks, and UI building.
class _HomeScreenState extends State<HomeScreen> {
  /// Whether the app is currently checking for an active ride.
  bool _isCheckingRide = true;

  @override
  void initState() {
    super.initState();
    // Fetch initial data and check for active rides after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
      _checkAndFetchData();
    });
  }

  /// Checks for an active ride. If found, navigates to the active ride screen.
  /// Otherwise, fetches home screen data and allows the UI to build.
  Future<void> _checkAndFetchData() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    // First, check for an active ride.
    await rideProvider.fetchActiveRide();

    if (mounted) {
      if (rideProvider.activeRide != null) {
        // If a ride is active, navigate immediately.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ActiveRideScreen()),
        );
      } else {
        // If no active ride, proceed to fetch home screen data.
        _fetchInitialData();
        setState(() {
          _isCheckingRide = false; // Allow the UI to build.
        });
      }
    }
  }

  /// Fetches the user's location, nearby bikes, weather, and active reservation.
  /// Handles permission requests and errors.
  Future<void> _fetchInitialData() async {
    final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Location permissions are denied');
      }
      if (permission == LocationPermission.deniedForever) throw Exception('Location permissions are permanently denied.');

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Fetch everything in parallel to be efficient
      await Future.wait([
        bikeProvider.fetchNearbyBikes(),
        weatherProvider.fetchWeather(position),
        bikeProvider.fetchActiveReservation(), // Check for active reservation on startup
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.couldNotGetLocation(e.toString()))),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Get the current user and any active reservation from providers.
    final user = Provider.of<AuthProvider>(context).user;
    final activeReservation = Provider.of<BikeProvider>(context).activeReservation;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Main scrollable content with pull-to-refresh
          RefreshIndicator(
            onRefresh: _fetchInitialData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting and subtitle
                  Text(AppLocalizations.of(context)!.hello(user?.capitalizedUsername ?? ''), style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(AppLocalizations.of(context)!.wannaTakeARide, style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 24),
                  // Weather card widget
                  const WeatherCard(),
                  const SizedBox(height: 32),
                  // Section header for bikes
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(AppLocalizations.of(context)!.nearbyBikes, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () {}, child: Text(AppLocalizations.of(context)!.browseMap, style: GoogleFonts.poppins(color: Colors.amber[800]))),
                  ]),
                  const SizedBox(height: 16),
                  // List of nearby bikes
                  _buildBikesList(),
                  const SizedBox(height: 80), // Space for the floating button and banner
                ],
              ),
            ),
          ),
          // Reservation banner if user has an active reservation
          if (activeReservation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildReservationBanner(activeReservation),
            ),
        ],
      ),
      // Floating action button for QR scanning
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const QRScanScreen()));
        },
        backgroundColor: Colors.green[800],
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  /// Builds a horizontal list of nearby bikes, or a loading/error/empty state.
  Widget _buildBikesList() {
    return Consumer<BikeProvider>(
      builder: (context, provider, child) {
        switch (provider.status) {
          case BikeStatus.loading:
          case BikeStatus.initial:
            return const Center(child: CircularProgressIndicator());
          case BikeStatus.error:
            return Center(child: Text("${AppLocalizations.of(context)!.error} ${provider.errorMessage!}"));
          case BikeStatus.loaded:
            if (provider.bikes.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)!.noBikesFoundNearby));
            }
            return SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.bikes.length,
                itemBuilder: (context, index) {
                  return BikeCard(bike: provider.bikes[index]);
                },
              ),
            );
        }
      },
    );
  }


  /// Builds a banner at the bottom of the screen if the user has an active reservation.
  /// Tapping the banner navigates to the reservation details.
  Widget _buildReservationBanner(Bike bike) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReservationScreen(bike: bike)),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.amber[700],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.bikeIsReserved(bike.id.toString()),
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            Text(AppLocalizations.of(context)!.view, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
