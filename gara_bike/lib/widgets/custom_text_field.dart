
// Custom text field widget for forms with validation and styling.
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gara_bike/l10n/app_localizations.dart';

class CustomTextField extends StatelessWidget {
  // Controller for the text field input
  final TextEditingController controller;
  // Label text to display above the field
  final String labelText;
  // Whether to obscure the text (e.g., for passwords)
  final bool obscureText;
  // Keyboard type (e.g., text, number, email)
  final TextInputType keyboardType;
  // Optional custom validator function
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      // Use provided validator or default to non-empty check
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.fieldCannotBeEmpty(labelText);
        }
        return null;
      },
      decoration: InputDecoration(
        // Field label
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(),
        // Outline border with rounded corners
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        // Border when field is focused
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
