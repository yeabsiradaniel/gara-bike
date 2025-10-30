
// Widget that displays the current weather information in a styled card.
// Uses WeatherProvider to get weather data and status.
// Shows loading, error, or weather details based on provider state.
//
// Usage: Place WeatherCard inside a widget tree where WeatherProvider is available.
// Example: WeatherCard()
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/widgets/weather_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gara_bike/providers/weather_provider.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to WeatherProvider for weather data and status
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        Widget content;

        // Switch on the provider's status to determine what to show
        switch (provider.status) {
          case WeatherStatus.loading:
          case WeatherStatus.initial:
            // Show loading indicator while fetching weather
            content = const Center(child: CircularProgressIndicator(color: Colors.white));
            break;
          case WeatherStatus.error:
            // Show error message if weather could not be loaded
            content = Center(child: Text('Could not load weather.', style: GoogleFonts.poppins(color: Colors.white)));
            break;
          case WeatherStatus.loaded:
            // Weather loaded successfully, extract data
            final weather = provider.weather!;
            final temp = weather.temperature.round().toString(); // Rounded temperature
            final condition = weather.condition; // Weather condition (e.g., Sunny)
            final location = weather.locationName; // Location name
            // Format date as '4 Jul, Friday'
            final date = '${DateTime.now().day} ${_getMonthName(DateTime.now().month)}, ${_getWeekdayName(DateTime.now().weekday)}';
            // Weather icon from network, fallback to icon if error
            final icon = Image.network(
              weather.iconUrl,
              scale: 0.8,
              errorBuilder: (c, e, s) => const Icon(Icons.cloud_off, color: Colors.white, size: 40),
            );

            // Build the weather card content
            content = Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distributes space evenly
              children: [
                // Top row: temperature, condition, location, and icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Temperature and condition
                          Text('$temp° $condition', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          // Location name
                          Text(location, style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    // Weather icon
                    SizedBox(width: 60, height: 60, child: icon),
                  ],
                ),
                // Divider line
                Divider(color: Colors.white.withOpacity(0.3)),
                // Date row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(date, style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                  ],
                ),
              ],
            );
            break;
        }

        // Card container with styling
        return Container(
          // Padding inside the card
          padding: const EdgeInsets.all(20),
          // Card decoration: color, rounded corners, shadow
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: content,
        );
      },
    );
  }

  // Helper to get month name from month number
  String _getMonthName(int month) =>
      ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];

  // Helper to get weekday name from weekday number
  String _getWeekdayName(int day) =>
      ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][day - 1];
}
