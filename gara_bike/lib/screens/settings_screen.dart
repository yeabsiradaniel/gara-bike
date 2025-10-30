// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:gara_bike/screens/edit_profile_screen.dart';
import 'package:gara_bike/screens/favorite_locations_screen.dart';

import '../providers/theme_provider.dart';
// import 'package:gara_bike/screens/favorite_locations_screen.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'Version ${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('General'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: Text('Dark Mode', style: GoogleFonts.poppins()),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                },
              );
            },
          ),
          _buildListTile(
            title: 'Notifications',
            leadingIcon: Icons.notifications_outlined,
            onTap: () {
              // TODO: Implement Notifications Screen
            },
          ),
          
          _buildSectionHeader('Account'),
          _buildListTile(
            title: 'Edit Profile',
            leadingIcon: Icons.person_outline,
            // --- UNCOMMENT THIS NAVIGATION ---
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            },
          ),
          _buildListTile(
            title: 'Favorite Locations',
            leadingIcon: Icons.favorite_border,
            // --- UNCOMMENT THIS NAVIGATION ---
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteLocationsScreen()));
            },
          ),

          _buildSectionHeader('About'),
          _buildListTile(
            title: 'Privacy Policy',
            leadingIcon: Icons.privacy_tip_outlined,
            onTap: () {
              // TODO: Launch URL to Privacy Policy
            },
          ),
          _buildListTile(
            title: 'Terms of Service',
            leadingIcon: Icons.description_outlined,
            onTap: () {
              // TODO: Launch URL to Terms of Service
            },
          ),
          ListTile(
            title: Text('App Version', style: GoogleFonts.poppins()),
            leading: const Icon(Icons.info_outline),
            trailing: Text(_appVersion, style: GoogleFonts.poppins(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildListTile({required String title, required IconData leadingIcon, required VoidCallback onTap}) {
    return ListTile(
      title: Text(title, style: GoogleFonts.poppins()),
      leading: Icon(leadingIcon),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}