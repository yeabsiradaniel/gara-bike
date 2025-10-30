
// Author: Yeabsira Daniel
// Date: JAN/26/2025
//
// This file implements the InviteFriendsScreen, which allows users to view and share their
// unique invitation/referral code with friends. The code can be copied to the clipboard or
// shared using the device's share sheet. The referral code is fetched from the AuthProvider.
//
// Main components:
// - InviteFriendsScreen: StatefulWidget that manages fetching and displaying the referral code.
// - _shareCode: Helper method to share the code using the share_plus package.

// lib/screens/invite_friends_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gara_bike/providers/auth_provider.dart';


/// Screen that allows the user to view and share their invitation/referral code.
class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}


/// State for [InviteFriendsScreen]. Handles fetching the referral code and sharing logic.
class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the referral code after the first frame to ensure context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchReferralCode();
    });
  }

  /// Shares the referral code using the device's share sheet.
  void _shareCode(String code) {
    final shareText = "Join me on Gara Bike! It's a great way to get around the city. Use my invitation code to get started: $code";
    Share.share(shareText, subject: 'Gara Bike Invitation');
  }


  @override
  Widget build(BuildContext context) {
    // Main UI: AppBar, Lottie animation, referral code display, and share button.
    return Scaffold(
      appBar: AppBar(
        title: Text('Invite Friends', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Lottie animation for inviting friends
            Lottie.asset(
              'assets/animations/invite.json',
              height: MediaQuery.of(context).size.height * 0.3,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.people_alt_outlined, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Title for the invitation code section
            Text(
              'Your Invitation Code',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            // Display the referral code and copy button
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                if (auth.referralCode == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // The referral code in a monospace font
                      Text(
                        auth.referralCode!,
                        style: GoogleFonts.robotoMono(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      // Copy button for the referral code
                      IconButton(
                        icon: Icon(Icons.copy, color: Colors.grey[600]),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: auth.referralCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code copied to clipboard!')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const Spacer(),
            // Share button for the referral code
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return ElevatedButton.icon(
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: Text('Share Code', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                  onPressed: auth.referralCode == null ? null : () => _shareCode(auth.referralCode!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}