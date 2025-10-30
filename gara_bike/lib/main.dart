// lib/main.dart

import 'package:flutter/material.dart';
import 'package:gara_bike/providers/statistics_provider.dart';
import 'package:gara_bike/providers/support_provider.dart';
import 'package:provider/provider.dart';
import 'package:gara_bike/providers/auth_provider.dart';
import 'package:gara_bike/providers/bike_provider.dart';
import 'package:gara_bike/providers/weather_provider.dart';
import 'package:gara_bike/providers/ride_provider.dart';
import 'package:gara_bike/providers/wallet_provider.dart';
import 'package:gara_bike/providers/pass_provider.dart';
import 'package:gara_bike/screens/splash_screen.dart';
import 'package:gara_bike/screens/home_screen.dart';
import 'package:gara_bike/screens/auth/welcome_screen.dart';

import 'package:gara_bike/providers/theme_provider.dart'; // Make sure ThemeProvider is imported
import 'package:google_fonts/google_fonts.dart';

// Entry point of the application
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => WeatherProvider()),
        ChangeNotifierProxyProvider<AuthProvider, BikeProvider>(
          create: (context) => BikeProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => previous!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, RideProvider>(
          create: (context) => RideProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => previous!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, WalletProvider>(
          create: (context) => WalletProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => previous!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, StatisticsProvider>(
          create: (context) => StatisticsProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => previous!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SupportProvider>(
            create: (context) => SupportProvider(Provider.of<AuthProvider>(context, listen: false)),
            update: (context, auth, previous) => previous!..updateAuth(auth)
        ),
        ChangeNotifierProxyProvider2<AuthProvider, WalletProvider, PassProvider>(
          create: (context) => PassProvider(
            Provider.of<AuthProvider>(context, listen: false),
            Provider.of<WalletProvider>(context, listen: false),
          ),
          update: (context, auth, wallet, previous) => previous!..updateAuth(auth, wallet),
        ),
      ],
      child: const GaraBikeApp(),
    ),
  );
}

// Root widget of the Gara Bike app
class GaraBikeApp extends StatelessWidget {
  const GaraBikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Gara Bike',
          themeMode: themeProvider.themeMode,
          
          // --- LIGHT THEME DEFINITION ---
          theme: ThemeData(
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.grey[50],
            visualDensity: VisualDensity.adaptivePlatformDensity,
            // FIX: Base the textTheme on ThemeData.light() instead of the context
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.light),
          ),

          // --- DARK THEME DEFINITION ---
          darkTheme: ThemeData(
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color(0xFF121212),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            // This was already correct, based on ThemeData.dark()
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
          ),

          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// Widget that decides which screen to show based on authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Attempt auto-login when the app starts
      future: Provider.of<AuthProvider>(context, listen: false).tryAutoLogin(),
      builder: (ctx, authResultSnapshot) {
        // Show loading indicator while waiting for auto-login
        if (authResultSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // Listen to authentication state and show appropriate screen
        return Consumer<AuthProvider>(
          builder: (ctx, auth, _) {
            if (auth.isAuthenticated) {
              // If authenticated, show HomeScreen
              return const HomeScreen();
            } else {
              // If not authenticated, show WelcomeScreen
              return const WelcomeScreen();
            }
          },
        );
      },
    );
  }
}
