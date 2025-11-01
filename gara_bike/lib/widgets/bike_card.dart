
// Widget that displays a card for a single bike, showing its image, ID, distance, and battery level.
// Tapping the card navigates to the reservation screen for that bike.
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/widgets/bike_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gara_bike/models/bike_model.dart';
import 'package:gara_bike/screens/reservation_screen.dart'; // Import the new reservation screen

import 'package:gara_bike/l10n/app_localizations.dart';

class BikeCard extends StatelessWidget {
  // The bike to display in this card
  final Bike bike;
  const BikeCard({super.key, required this.bike});

  @override
  Widget build(BuildContext context) {
    // Convert distance from meters to a more readable format for display
    String distanceText;
    if (bike.distance != null) {
      if (bike.distance! < 1000) {
        distanceText = AppLocalizations.of(context)!.metersAway(bike.distance!.round().toString());
      } else {
        distanceText = AppLocalizations.of(context)!.kmAway((bike.distance! / 1000).toStringAsFixed(1));
      }
    } else {
      distanceText = AppLocalizations.of(context)!.distanceUnknown;
    }

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          // Make the whole card tappable
          onTap: () {
            // Navigate to the reservation screen, passing the bike info
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReservationScreen(bike: bike),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bike image section
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.green[50],
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    'assets/images/bike_image.png', // A generic image for a bike
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => Icon(Icons.error_outline, color: Colors.grey[400]),
                  ),
                ),
              ),
              // Bike details section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bike ID
                      Text(
                        AppLocalizations.of(context)!.bike(bike.id.toString()),
                        style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      // Distance from user
                      Text(
                        distanceText,
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      // Battery level row
                      Row(
                        children: [
                          Icon(
                            Icons.battery_charging_full,
                            color: bike.batteryLevel > 20 ? Colors.green[700] : Colors.red[700],
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.battery(bike.batteryLevel.toString()),
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
