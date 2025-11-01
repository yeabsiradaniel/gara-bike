// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:gara_bike/screens/edit_profile_screen.dart';
import 'package:gara_bike/screens/favorite_locations_screen.dart';

import 'package:gara_bike/l10n/app_localizations.dart';

import 'package:gara_bike/providers/language_provider.dart';

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
        title: Text(AppLocalizations.of(context)!.settings, style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(AppLocalizations.of(context)!.general),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: Text(AppLocalizations.of(context)!.darkMode, style: GoogleFonts.poppins()),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                },
              );
            },
          ),
          _buildListTile(
            title: AppLocalizations.of(context)!.notifications,
            leadingIcon: Icons.notifications_outlined,
            onTap: () {
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.language, style: GoogleFonts.poppins()),
            leading: const Icon(Icons.language_outlined),
            trailing: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return DropdownButton<Locale>(
                  value: languageProvider.appLocale,
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      languageProvider.changeLanguage(newLocale);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: const Locale('en'),
                      child: Text(AppLocalizations.of(context)!.english),
                    ),
                    DropdownMenuItem(
                      value: const Locale('am'),
                      child: Text(AppLocalizations.of(context)!.amharic),
                    ),
                  ],
                );
              },
            ),
          ),
          
          _buildSectionHeader(AppLocalizations.of(context)!.account),
          _buildListTile(
            title: AppLocalizations.of(context)!.editProfile,
            leadingIcon: Icons.person_outline,
            // --- UNCOMMENT THIS NAVIGATION ---
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            },
          ),
          _buildListTile(
            title: AppLocalizations.of(context)!.favoriteLocations,
            leadingIcon: Icons.favorite_border,
            // --- UNCOMMENT THIS NAVIGATION ---
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteLocationsScreen()));
            },
          ),

          _buildSectionHeader(AppLocalizations.of(context)!.about),
          _buildListTile(
            title: AppLocalizations.of(context)!.privacyPolicy,
            leadingIcon: Icons.privacy_tip_outlined,
            onTap: () {
              // TODO: Launch URL to Privacy Policy
            },
          ),
          _buildListTile(
            title: AppLocalizations.of(context)!.termsOfService,
            leadingIcon: Icons.description_outlined,
            onTap: () {
              // TODO: Launch URL to Terms of Service
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.appVersion, style: GoogleFonts.poppins()),
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