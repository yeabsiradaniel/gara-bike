
// Screen for purchasing ride passes in the Gara Bike app.
// Lists available passes and allows the user to buy one.
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/screens/purchase_pass_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gara_bike/providers/pass_provider.dart';
import 'package:gara_bike/models/pass_model.dart';
import 'package:gara_bike/l10n/app_localizations.dart';


class PurchasePassScreen extends StatefulWidget {
  const PurchasePassScreen({super.key});

  @override
  State<PurchasePassScreen> createState() => _PurchasePassScreenState();
}

class _PurchasePassScreenState extends State<PurchasePassScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch available passes after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PassProvider>(context, listen: false).fetchAvailablePasses();
    });
  }

  // Handles purchasing a pass
  Future<void> _purchasePass(int passId) async {
    final passProvider = Provider.of<PassProvider>(context, listen: false);
    final response = await passProvider.purchasePass(passId);

    if (mounted) {
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.passPurchasedSuccessfully), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(); // Go back to the wallet screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error']?.toString() ?? AppLocalizations.of(context)!.purchaseFailed), backgroundColor: Colors.red),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // App bar with title
        title: Text(AppLocalizations.of(context)!.buyAPass, style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<PassProvider>(
        builder: (context, provider, child) {
          // Show loading indicator while fetching passes
          if (provider.status == PassStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show error message if fetch fails
          if (provider.status == PassStatus.error) {
            return Center(child: Text("${AppLocalizations.of(context)!.error} ${provider.errorMessage!}"));
          }
          // Show message if no passes are available
          if (provider.passes.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noPassesAvailableAtThisTime));
          }

          // List of available passes
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.passes.length,
            itemBuilder: (context, index) {
              final pass = provider.passes[index];
              return _buildPassCard(pass);
            },
          );
        },
      ),
    );
  }


  // Builds a card for a single pass with purchase button
  Widget _buildPassCard(Pass pass) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pass name
            Text(pass.name, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Pass duration
            Text(AppLocalizations.of(context)!.daysOfUnlimitedRides(pass.durationDays), style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pass price
                Text(AppLocalizations.of(context)!.etb + ' ' + pass.price.toStringAsFixed(2), style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.green[900])),
                // Purchase button
                ElevatedButton(
                  onPressed: () => _purchasePass(pass.id),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                  child: Text(AppLocalizations.of(context)!.purchase, style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
