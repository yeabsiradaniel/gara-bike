
// Author: Yeabsira Daniel
// Date: JAN/26/2025
//
// This file implements the onboarding flow for the Gara Bike app.
// It presents a series of onboarding pages to introduce new users to the app's features.
// The onboarding state is persisted using SharedPreferences so users only see it once.
//
// Main components:
// - OnboardingInfo: Model for onboarding page content.
// - OnboardingScreen: StatefulWidget managing the onboarding flow and navigation.
// - OnboardingPage: StatelessWidget for displaying a single onboarding page.

// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gara_bike/screens/auth/welcome_screen.dart';
import 'package:gara_bike/l10n/app_localizations.dart';

/// Model class representing the content for a single onboarding page.
class OnboardingInfo {

  /// Path to the image asset for the onboarding page.
  final String imageAsset;
  /// Title text for the onboarding page.
  final String title;
  /// Description text for the onboarding page.
  final String description;

  /// Creates an [OnboardingInfo] with the given [imageAsset], [title], and [description].
  OnboardingInfo({
    required this.imageAsset,
    required this.title,
    required this.description,
  });
}


/// The main onboarding screen that displays a series of onboarding pages.
/// Handles navigation, page transitions, and onboarding completion logic.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}


class _OnboardingScreenState extends State<OnboardingScreen> {
  /// Controller for the onboarding [PageView].
  final PageController _pageController = PageController();
  /// Index of the currently visible onboarding page.
  int _currentPage = 0;

  /// Called when the onboarding page changes.
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }


  /// Marks onboarding as complete in persistent storage and navigates to the welcome screen.
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<OnboardingInfo> _pages = [
      OnboardingInfo(
        imageAsset: 'assets/images/onboarding_locate.png',
        title: AppLocalizations.of(context)!.locate,
        description: AppLocalizations.of(context)!.findBikesNearYouInstantly,
      ),
      OnboardingInfo(
        imageAsset: 'assets/images/onboarding_unlock.png',
        title: AppLocalizations.of(context)!.unlock,
        description: AppLocalizations.of(context)!.seamlesslyUnlockBikesWithATap,
      ),
      OnboardingInfo(
        imageAsset: 'assets/images/onboarding_ride.png',
        title: AppLocalizations.of(context)!.ride,
        description: AppLocalizations.of(context)!.enjoyASmoothAndEcoFriendlyRide,
      ),
    ];

    // The onboarding UI consists of a PageView for the pages and controls for navigation.
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Onboarding pages
            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(info: _pages[index]);
                },
              ),
            ),
            // Navigation controls and indicators
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page indicator dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? Colors.amber[700] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    // Skip and Next/Get Started buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            AppLocalizations.of(context)!.skip,
                            style: GoogleFonts.poppins(color: Colors.grey[600]),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _pages.length - 1) {
                              // Complete onboarding if on last page
                              _completeOnboarding();
                            } else {
                              // Go to next onboarding page
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1 ? AppLocalizations.of(context)!.getStarted : AppLocalizations.of(context)!.next,
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
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
    );
  }
}


/// Widget for displaying a single onboarding page with image, title, and description.
class OnboardingPage extends StatelessWidget {
  /// The onboarding info to display.
  final OnboardingInfo info;
  const OnboardingPage({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display the onboarding image. If not found, show a bike icon.
          Image.asset(
            info.imageAsset,
            height: MediaQuery.of(context).size.height * 0.3,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.pedal_bike, size: 100, color: Colors.grey[300]),
          ),
          const SizedBox(height: 48),
          // Onboarding title
          Text(
            info.title,
            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Onboarding description
          Text(
            info.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }
}
