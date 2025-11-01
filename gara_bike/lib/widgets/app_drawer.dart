
// Drawer widget for the Gara Bike app, providing navigation to wallet, statistics, invite, support, settings, and logout.
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gara_bike/providers/auth_provider.dart';
import 'package:gara_bike/providers/wallet_provider.dart';
import 'package:gara_bike/main.dart';
import 'package:gara_bike/screens/wallet_screen.dart';
import 'package:gara_bike/screens/my_statistics_screen.dart';
import 'package:gara_bike/screens/invite_friends_screen.dart'; // Import the new screen
import 'package:gara_bike/screens/support_screen.dart'; // Import the new screen
import 'package:gara_bike/screens/settings_screen.dart'; // Import the new screen
import 'package:gara_bike/l10n/app_localizations.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Access authentication provider and user info
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Drawer header with user info
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.capitalizedUsername ?? AppLocalizations.of(context)!.garaRider,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.green),
            ),
            decoration: BoxDecoration(color: Colors.green[800]),
          ),
          // Wallet tile with live balance using Consumer
          Consumer<WalletProvider>(
            builder: (context, walletProvider, child) {
              final balance = walletProvider.wallet?.balance.toStringAsFixed(2) ?? '...';
              return _buildDrawerItem(
                icon: Icons.account_balance_wallet_outlined,
                title: AppLocalizations.of(context)!.myWallet,
                subtitle: '${AppLocalizations.of(context)!.etb} $balance',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                },
              );
            },
          ),
          // Statistics tile
          _buildDrawerItem(
            icon: Icons.bar_chart_outlined,
            title: AppLocalizations.of(context)!.myStatistics,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyStatisticsScreen()));
            },
          ),
          // Invite friends tile
          _buildDrawerItem(
            icon: Icons.people_outline,
            title: AppLocalizations.of(context)!.inviteFriends,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InviteFriendsScreen()));
            }
          ),
          // --- UPDATED THIS TILE ---
          _buildDrawerItem(
            icon: Icons.support_agent_outlined,
            title: AppLocalizations.of(context)!.support,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
            }
          ),
          const Divider(),
          // --- UPDATED THIS TILE ---
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: AppLocalizations.of(context)!.settings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }
          ),
          // Logout tile
          _buildDrawerItem(
            icon: Icons.logout,
            title: AppLocalizations.of(context)!.logOut,
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthWrapper()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper to build a styled drawer item
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.poppins()) : null,
      onTap: onTap,
    );
  }
}
