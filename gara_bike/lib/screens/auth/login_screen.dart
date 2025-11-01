
// Author: Yeabsira Daniel
// Date: JAN/26/2025
//
// This file implements the LoginScreen, which allows users to log in to their Gara Bike account.
// It includes a login form with validation for email and password, and navigates to the home screen on success.
//
// Main components:
// - LoginScreen: StatefulWidget that manages the login form and logic.

// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gara_bike/providers/auth_provider.dart';
import 'package:gara_bike/screens/home_screen.dart'; // To navigate after login
import 'package:gara_bike/widgets/custom_text_field.dart';
import 'package:gara_bike/l10n/app_localizations.dart';


/// Screen for user login, including form validation and navigation to home.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


/// State for [LoginScreen]. Handles form controllers, validation, and login logic.
class _LoginScreenState extends State<LoginScreen> {
  /// Key for the login form.
  final _formKey = GlobalKey<FormState>();
  /// Controller for the email field.
  final _emailController = TextEditingController();
  /// Controller for the password field.
  final _passwordController = TextEditingController();
  /// Whether the login is in progress.
  bool _isLoading = false;

  /// Handles form submission, validation, and login API call.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (response['success']) {
        // Navigate to home screen on successful login.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Show error message if login failed.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error']?['detail'] ?? AppLocalizations.of(context)!.loginFailedPleaseTryAgain),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  void dispose() {
    // Dispose all controllers to free resources.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Main UI: login form with validation and loading state.
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.logIn, style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                AppLocalizations.of(context)!.welcomeBack,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                AppLocalizations.of(context)!.logInToContinueYourJourney,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              // Email field
              CustomTextField(
                controller: _emailController,
                labelText: AppLocalizations.of(context)!.emailAddress,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return AppLocalizations.of(context)!.pleaseEnterAValidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Password field
              CustomTextField(
                controller: _passwordController,
                labelText: AppLocalizations.of(context)!.password,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.passwordCannotBeEmpty;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48),
              // Submit button or loading indicator
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.logIn,
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
