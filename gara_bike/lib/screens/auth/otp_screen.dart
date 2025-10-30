
// Author: Yeabsira Daniel
// Date: JAN/26/2025
//
// This file implements the OTPScreen, which allows users to verify their account
// by entering a 4-digit code sent to their phone. On successful verification,
// the user is navigated to the login screen.
//
// Main components:
// - OTPScreen: StatefulWidget that manages OTP input, validation, and verification logic.

// lib/screens/auth/otp_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gara_bike/providers/auth_provider.dart';
import 'package:gara_bike/screens/auth/login_screen.dart'; // To navigate to login after verification


/// Screen for OTP verification after registration.
class OTPScreen extends StatefulWidget {
  /// The email address to verify.
  final String email;
  const OTPScreen({super.key, required this.email});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}


/// State for [OTPScreen]. Handles OTP input, validation, and verification logic.
class _OTPScreenState extends State<OTPScreen> {
  /// Key for the OTP form.
  final _formKey = GlobalKey<FormState>();
  /// Controller for the OTP input field.
  final _otpController = TextEditingController();
  /// Whether the verification is in progress.
  bool _isLoading = false;

  /// Handles OTP form submission and verification API call.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await authProvider.verifyOtp(
      widget.email,
      _otpController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (response['success']) {
        // Show success message and navigate to login screen.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account verified! Please log in to continue.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Show error message if verification failed.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error']?.toString() ?? 'Verification failed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  void dispose() {
    // Dispose the OTP controller to free resources.
    _otpController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Main UI: OTP input form, submit button, and resend prompt.
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification', style: GoogleFonts.poppins()),
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
                'Enter Your Code',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'A 4-digit code has been sent to your phone.',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              // OTP input field
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 24, letterSpacing: 10),
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.length < 4) {
                    return 'Please enter the 4-digit code';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  counterText: "", // Hides the counter
                  labelText: 'Verification Code',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Submit button or loading indicator
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Verify',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
              // Resend OTP prompt (not implemented)
              TextButton(
                onPressed: () {
                  // TODO: Implement resend OTP logic
                },
                child: Text(
                  "Didn't receive SMS?",
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
