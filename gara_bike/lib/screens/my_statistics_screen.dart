
// Author: Yeabsira Daniel
// Date: JAN/26/2025
//
// This file implements the MyStatisticsScreen, which displays the user's ride statistics
// such as total duration, distance, calories burned, and carbon saved. It fetches data
// from the StatisticsProvider and presents each stat in a card with a Lottie animation.
//
// Main components:
// - MyStatisticsScreen: StatefulWidget that manages fetching and displaying statistics.
// - _buildStatCard: Helper method to build a stat card with animation and values.

// lib/screens/my_statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gara_bike/providers/statistics_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:gara_bike/l10n/app_localizations.dart';


/// Screen that displays the user's ride statistics with animated cards.
class MyStatisticsScreen extends StatefulWidget {
  const MyStatisticsScreen({super.key});

  @override
  State<MyStatisticsScreen> createState() => _MyStatisticsScreenState();
}


/// State for [MyStatisticsScreen]. Handles fetching statistics and building the UI.
class _MyStatisticsScreenState extends State<MyStatisticsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch statistics after the first frame to ensure context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatisticsProvider>(context, listen: false).fetchStatistics();
    });
  }


  @override
  Widget build(BuildContext context) {
    // Main UI: AppBar and statistics cards.
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myStatistics, style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, provider, child) {
          // Show loading indicator while fetching stats.
          if (provider.status == StatisticsStatus.loading || provider.status == StatisticsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show error message if fetching failed.
          if (provider.status == StatisticsStatus.error) {
            return Center(child: Text("${AppLocalizations.of(context)!.error} ${provider.errorMessage!}"));
          }
          // Show message if no stats are available.
          if (provider.stats == null) {
            return Center(child: Text(AppLocalizations.of(context)!.noStatisticsFound));
          }

          final stats = provider.stats!;
          // List of stat cards, each with a Lottie animation and value.
          return RefreshIndicator(
            onRefresh: () => provider.fetchStatistics(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildStatCard(
                  lottieAsset: 'assets/animations/timer.json',
                  label: AppLocalizations.of(context)!.totalDuration,
                  value: stats['duration'] ?? AppLocalizations.of(context)!.zeroMins,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  lottieAsset: 'assets/animations/route.json',
                  label: AppLocalizations.of(context)!.totalDistance,
                  value: stats['distance'] ?? AppLocalizations.of(context)!.zeroMeters,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  lottieAsset: 'assets/animations/calories.json',
                  label: AppLocalizations.of(context)!.caloriesBurned,
                  value: stats['calories'] ?? AppLocalizations.of(context)!.zeroCalories,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  lottieAsset: 'assets/animations/carbon.json',
                  label: AppLocalizations.of(context)!.carbonSaved,
                  value: '${stats['carbon'] ?? AppLocalizations.of(context)!.zero}',
                  color: Colors.grey,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds a card widget displaying a single statistic with a Lottie animation.
  ///
  /// [lottieAsset]: Path to the Lottie animation asset.
  /// [label]: The label for the statistic (e.g., 'Total Duration').
  /// [value]: The value to display (e.g., '120 mins').
  /// [color]: The color theme for the card (currently not used for background).
  Widget _buildStatCard({required String lottieAsset, required String label, required String value, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Row(
          children: [
            // Animated icon for the stat
            Lottie.asset(
              lottieAsset,
              height: 60,
              width: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error_outline, color: Colors.red, size: 40);
              },
            ),
            const SizedBox(width: 16),
            // Stat label and value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}