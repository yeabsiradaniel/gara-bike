
// Splash screen for the Gara Bike app.
// Shows an animation and app name, then navigates to onboarding or authentication based on user state.
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gara_bike/main.dart'; // To access AuthWrapper
import 'package:gara_bike/screens/onboarding_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gara_bike/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start navigation logic after splash loads
    _navigate();
  }

  // Handles navigation after splash animation
  void _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // Wait for the splash animation to finish
    await Future.delayed(const Duration(seconds: 6 ));

    if (mounted) {
      if (hasSeenOnboarding) {
        // If user has seen onboarding, go straight to the auth check
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      } else {
        // Otherwise, show the onboarding screens first
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated bike splash using Lottie
            Lottie.asset(
              'assets/animations/bike_animation.json',
              width: 250, height: 250, fit: BoxFit.fill,
            ),
            const SizedBox(height: 20),
            // App name
            Text(
              AppLocalizations.of(context)!.garaBike,
              style: GoogleFonts.poppins(
                fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
