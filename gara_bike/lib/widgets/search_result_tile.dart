
// Widget that displays a single search result for a parking zone in a list tile.
// Tapping the tile navigates to a map screen for the selected parking zone.
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/widgets/search_result_tile.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gara_bike/models/parking_zone_model.dart';
import 'package:gara_bike/screens/parking_zone_map_screen.dart'; // Import the new screen

import 'package:gara_bike/l10n/app_localizations.dart';

class SearchResultTile extends StatelessWidget {
  // The parking zone to display in this tile
  final ParkingZone zone;
  const SearchResultTile({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Leading icon for the parking zone
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Icon(Icons.local_parking, color: Colors.blue[800]),
      ),
      // Display the parking zone name
      title: Text(zone.name, style: GoogleFonts.poppins()),
      // Subtitle for context
      subtitle: Text(AppLocalizations.of(context)!.parkingZone),
      // On tap, navigate to the map screen for this parking zone
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParkingZoneMapScreen(zone: zone),
          ),
        );
      },
    );
  }
}
