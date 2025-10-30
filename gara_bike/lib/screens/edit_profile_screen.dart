// lib/screens/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gara_bike/providers/auth_provider.dart';
import 'package:gara_bike/widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await authProvider.updateUserProfile({
      'username': _usernameController.text,
      'phone_number': _phoneController.text,
    });

    setState(() => _isLoading = false);

    if (mounted) {
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error']?['detail'] ?? 'Failed to update profile.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.poppins()),
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
              // Read-only email and NID fields
              _buildReadOnlyField(label: 'Email Address', value: user?.email ?? '...'),
              const SizedBox(height: 24),
              _buildReadOnlyField(label: 'NID / FAN', value: user?.nid ?? '...'),
              const Divider(height: 48),

              // Editable fields
              CustomTextField(
                controller: _usernameController,
                labelText: 'Username',
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Save Changes', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 18),
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }
}