
// Wallet screen for Gara Bike app, showing current balance and transaction history.
// Allows users to top up their wallet or buy a pass.
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/screens/wallet_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gara_bike/providers/wallet_provider.dart';
import 'package:gara_bike/screens/top_up_screen.dart';
import 'package:gara_bike/screens/purchase_pass_screen.dart';
import 'package:intl/intl.dart';


class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch wallet details after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false).fetchWalletDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // App bar with title
        title: Text('My Wallet', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<WalletProvider>(
        builder: (context, provider, child) {
          // Show loading indicator while fetching wallet
          if (provider.status == WalletStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show error message if wallet fetch fails
          if (provider.status == WalletStatus.error) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }
          // Show message if no wallet details found
          if (provider.wallet == null) {
            return const Center(child: Text('No wallet details found.'));
          }

          final wallet = provider.wallet!;
          return Column(
            children: [
              // Show balance card
              _buildBalanceCard(wallet.balance),
              // Show transaction list
              Expanded(child: _buildTransactionList(wallet.transactions)),
            ],
          );
        },
      ),
    );
  }

  // Widget to display the current wallet balance and action buttons
  Widget _buildBalanceCard(double balance) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.green[800],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Current Balance', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text('ETB ${balance.toStringAsFixed(2)}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                // Top Up button
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_card, color: Colors.white),
                    label: Text('Top Up', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TopUpScreen()));
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Buy Pass button
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    label: Text('Buy Pass', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasePassScreen())),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget to display the list of wallet transactions
  Widget _buildTransactionList(List<dynamic> transactions) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isCredit = tx.transactionType == 'TOPUP';
        final amountText = '${isCredit ? '+' : '-'} ETB ${tx.amount.toStringAsFixed(2)}';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            // Icon for credit or debit
            leading: CircleAvatar(
              backgroundColor: isCredit ? Colors.green[100] : Colors.red[100],
              child: Icon(isCredit ? Icons.arrow_upward : Icons.arrow_downward, color: isCredit ? Colors.green[800] : Colors.red[800]),
            ),
            // Transaction description
            title: Text(tx.description, style: GoogleFonts.poppins()),
            // Transaction date and time
            subtitle: Text(DateFormat.yMMMd().add_jm().format(DateTime.parse(tx.timestamp))),
            // Transaction amount
            trailing: Text(amountText, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isCredit ? Colors.green : Colors.red)),
          ),
        );
      },
    );
  }
}
