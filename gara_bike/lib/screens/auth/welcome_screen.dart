
// Author: Yeabsira Daniel
// Date: JAN/26/2025
//
// This file implements the WelcomeScreen, which is the entry point for new and returning users.
// It displays the Gara Bike logo, a welcome message, and navigation buttons for registration and login.
//
// Main components:
// - WelcomeScreen: StatelessWidget that builds the welcome UI and handles navigation.

// lib/screens/auth/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gara_bike/screens/auth/login_screen.dart';
import 'package:gara_bike/screens/auth/register_screen.dart';


/// The welcome screen for the app, showing logo, greeting, and navigation to register or log in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Main UI: logo, welcome message, and navigation buttons.
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Gara Bike logo (shows icon if not found)
              Image.asset(
                'assets/images/logo.png',
                height: MediaQuery.of(context).size.height * 0.2,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.pedal_bike, size: 100, color: Colors.grey),
              ),
              const Spacer(),
              // Welcome title
              Text(
                'Welcome to Gara Bike',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Subtitle
              Text(
                'The future of urban mobility in Addis Ababa. Tap to get started.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
              ),
              const Spacer(flex: 2),
              // Get Started button (navigates to registration)
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Get Started', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              // Login prompt and button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?', style: GoogleFonts.poppins(fontSize: 14)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen())),
                    child: Text('Log In', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber[800])),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
