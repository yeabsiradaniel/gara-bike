
// Screen for topping up the user's wallet in the Gara Bike app.
// Allows users to select or enter a custom amount and choose a payment method.
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/screens/top_up_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gara_bike/providers/wallet_provider.dart';


class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  // Nullable double for selected amount (chip selection)
  double? _selectedAmount = 50.0;
  // Controller for custom amount text field
  final _customAmountController = TextEditingController();
  // Loading state for top-up process
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Listen to custom amount field; deselect chips if user types
    _customAmountController.addListener(() {
      if (_customAmountController.text.isNotEmpty && _selectedAmount != null) {
        setState(() {
          _selectedAmount = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  // Handles the top-up process
  Future<void> _processTopUp() async {
    // Determine the final amount from either the chip or the text field
    double finalAmount = 0;
    if (_selectedAmount != null) {
      finalAmount = _selectedAmount!;
    } else {
      finalAmount = double.tryParse(_customAmountController.text) ?? 0;
    }

    // Validate amount
    if (finalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    // For now, payment method is hardcoded as 'Telebirr'
    final response = await walletProvider.topUpWallet(finalAmount, 'Telebirr');

    if (mounted) {
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Top-up successful!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error']?.toString() ?? 'Top-up failed.'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  // Returns the button text based on selected or custom amount
  String get _topUpButtonText {
    if (_selectedAmount != null) {
      return 'Top Up ETB ${_selectedAmount!.toStringAsFixed(2)}';
    }
    if (_customAmountController.text.isNotEmpty) {
      return 'Top Up ETB ${_customAmountController.text}';
    }
    return 'Top Up';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // App bar with title
        title: Text('Top Up Wallet', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section: Select amount chips
            Text('Select Amount', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildAmountSelector(),
            const SizedBox(height: 24),
            // OR divider
            Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('OR', style: GoogleFonts.poppins(color: Colors.grey[600])),
              ),
              const Expanded(child: Divider()),
            ]),
            const SizedBox(height: 24),
            // Section: Custom amount field
            _buildCustomAmountField(),
            const SizedBox(height: 32),
            // Section: Payment method
            Text('Select Payment Method', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // For simplicity, we are assuming one payment method for now.
            _buildPaymentMethodSelector('Telebirr', 'assets/images/telebirr_logo.png'),
            const Spacer(),
            // Top Up button or loading indicator
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _processTopUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_topUpButtonText, style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  // Widget for selecting a top-up amount using chips
  Widget _buildAmountSelector() {
    final amounts = [10.0, 50.0, 100.0, 200.0];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: amounts.map((amount) {
        final isSelected = _selectedAmount == amount;
        return ChoiceChip(
          label: Text('ETB ${amount.toStringAsFixed(0)}', style: GoogleFonts.poppins(color: isSelected ? Colors.white : Colors.black87)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedAmount = amount;
                _customAmountController.clear(); // Clear the text field when a chip is selected
              });
            }
          },
          selectedColor: Colors.green[800],
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      }).toList(),
    );
  }

  // Widget for entering a custom top-up amount
  Widget _buildCustomAmountField() {
    return TextField(
      controller: _customAmountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: GoogleFonts.poppins(fontSize: 18),
      decoration: InputDecoration(
        prefixText: 'ETB ',
        labelText: 'Enter Custom Amount',
        labelStyle: GoogleFonts.poppins(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
      ),
    );
  }

  // Widget for displaying a payment method option
  Widget _buildPaymentMethodSelector(String name, String logoAsset) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green[800]!, width: 2),
      ),
      child: ListTile(
        leading: Image.asset(logoAsset, height: 40, errorBuilder: (c,e,s)=> const Icon(Icons.payment)),
        title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.check_circle, color: Colors.green[800]),
      ),
    );
  }
}
