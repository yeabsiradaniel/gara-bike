// lib/screens/favorite_locations_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gara_bike/providers/auth_provider.dart';
import 'package:gara_bike/models/user_model.dart';
import 'package:gara_bike/screens/set_location_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class FavoriteLocationsScreen extends StatelessWidget {
  const FavoriteLocationsScreen({super.key});

  Future<void> _setLocation(BuildContext context, String type) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    LatLng initialCenter;
    if (type == 'home' && user?.homeAddressLat != null) {
      initialCenter = LatLng(user!.homeAddressLat!, user.homeAddressLon!);
    } else if (type == 'work' && user?.workAddressLat != null) {
      initialCenter = LatLng(user!.workAddressLat!, user.workAddressLon!);
    } else {
      final position = await Geolocator.getCurrentPosition();
      initialCenter = LatLng(position.latitude, position.longitude);
    }
    
    if (!context.mounted) return;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => SetLocationScreen(initialCenter: initialCenter)),
    );

    if (result != null) {
      final data = type == 'home'
          ? {
              'home_address_name': result['name'],
              'home_address_lat': result['lat'],
              'home_address_lon': result['lon'],
            }
          : {
              'work_address_name': result['name'],
              'work_address_lat': result['lat'],
              'work_address_lon': result['lon'],
            };
      
      await authProvider.updateUserProfile(data);
    }
  }

  Future<void> _clearLocation(BuildContext context, String type) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final data = type == 'home'
        ? {'home_address_name': null, 'home_address_lat': null, 'home_address_lon': null}
        : {'work_address_name': null, 'work_address_lat': null, 'work_address_lon': null};
    await authProvider.updateUserProfile(data);
  }

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to rebuild when user data changes
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Scaffold(
          appBar: AppBar(
            title: Text('Favorite Locations', style: GoogleFonts.poppins()),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildLocationTile(
                context: context,
                icon: Icons.home_outlined,
                type: 'home',
                name: user?.homeAddressName,
              ),
              const SizedBox(height: 16),
              _buildLocationTile(
                context: context,
                icon: Icons.work_outline,
                type: 'work',
                name: user?.workAddressName,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationTile({
    required BuildContext context,
    required IconData icon,
    required String type,
    required String? name,
  }) {
    final title = type == 'home' ? 'Home' : 'Work';
    final hasLocation = name != null && name.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        subtitle: Text(
          hasLocation ? name : 'Not set',
          style: GoogleFonts.poppins(color: hasLocation ? null : Colors.grey[600]),
        ),
        trailing: hasLocation
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _setLocation(context, type);
                  } else if (value == 'clear') {
                    _clearLocation(context, type);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'clear', child: Text('Clear')),
                ],
              )
            : null,
        onTap: () => _setLocation(context, type),
      ),
    );
  }
}