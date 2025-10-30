
// Author: Yeabsira Daniel
// Date: JAN/26/2025
//
// This file implements the RegisterScreen, which allows users to create a new Gara Bike account.
// It includes a registration form with validation for username, email, phone, NID, and password.
// On successful registration, the user is navigated to the OTP verification screen.
//
// Main components:
// - RegisterScreen: StatefulWidget that manages the registration form and logic.

// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gara_bike/providers/auth_provider.dart';
import 'package:gara_bike/screens/auth/otp_screen.dart';
import 'package:gara_bike/widgets/custom_text_field.dart';


/// Screen for user registration, including form validation and navigation to OTP.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}


/// State for [RegisterScreen]. Handles form controllers, validation, and registration logic.
class _RegisterScreenState extends State<RegisterScreen> {
  /// Key for the registration form.
  final _formKey = GlobalKey<FormState>();
  /// Controller for the email field.
  final _emailController = TextEditingController();
  /// Controller for the username field.
  final _usernameController = TextEditingController();
  /// Controller for the phone number field.
  final _phoneController = TextEditingController();
  /// Controller for the NID field.
  final _nidController = TextEditingController();
  /// Controller for the password field.
  final _passwordController = TextEditingController();
  /// Whether the registration is in progress.
  bool _isLoading = false;

  /// Handles form submission, validation, and registration API call.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await authProvider.register(
      username: _usernameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      nid: _nidController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (response['success']) {
        // Navigate to OTP screen on successful registration.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OTPScreen(email: _emailController.text),
          ),
        );
      } else {
        // Show error message if registration failed.
        String errorMessage = 'Registration failed. Please try again.';
        if (response['error'] != null && response['error'] is Map) {
          final errors = response['error'] as Map<String, dynamic>;
          errorMessage = errors.entries
              .map((entry) => '${entry.key}: ${entry.value.join(", ")}')
              .join('\n');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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
    _usernameController.dispose();
    _phoneController.dispose();
    _nidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Main UI: registration form with validation and loading state.
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up', style: GoogleFonts.poppins()),
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
                'Create Your Account',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'Join Gara Bike to start your journey.',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              // Username field
              CustomTextField(controller: _usernameController, labelText: 'Username'),
              const SizedBox(height: 24),
              // Email field
              CustomTextField(controller: _emailController, labelText: 'Email Address', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              // Phone number field
              CustomTextField(controller: _phoneController, labelText: 'Phone Number (e.g., +251...)' , keyboardType: TextInputType.phone),
              const SizedBox(height: 24),

              // NID FAN number field with validation
              CustomTextField(
                controller: _nidController,
                labelText: 'NID FAN number',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NID FAN number cannot be empty';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Please enter only digits';
                  }
                  if (value.length != 16) {
                    return 'NID FAN must be exactly 16 digits';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              // Password field
              CustomTextField(controller: _passwordController, labelText: 'Password', obscureText: true),
              const SizedBox(height: 32),
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
                        'Create Account',
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
