// lib/screens/support_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gara_bike/providers/auth_provider.dart';
import 'package:gara_bike/providers/support_provider.dart';
import 'package:gara_bike/widgets/custom_text_field.dart';
import 'package:gara_bike/models/support_ticket_model.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Fetch initial ticket history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupportProvider>(context, listen: false).fetchTickets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(),
          tabs: const [
            Tab(text: 'New Ticket'),
            Tab(text: 'Ticket History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NewTicketForm(tabController: _tabController),
          const TicketHistoryList(),
        ],
      ),
    );
  }
}

// Form for creating a new ticket
class NewTicketForm extends StatefulWidget {
  final TabController tabController;
  const NewTicketForm({super.key, required this.tabController});

  @override
  State<NewTicketForm> createState() => _NewTicketFormState();
}

class _NewTicketFormState extends State<NewTicketForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = Provider.of<SupportProvider>(context, listen: false);
    final response = await provider.createTicket(
      _subjectController.text,
      _messageController.text,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Support ticket created successfully!'), backgroundColor: Colors.green),
        );
        _formKey.currentState?.reset();
        _subjectController.clear();
        _messageController.clear();
        widget.tabController.animateTo(1); // Switch to history tab
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error']?['detail'] ?? 'Failed to create ticket.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Contact Us', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Your name and email are automatically included. Please describe your issue below.',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildUserInfo(Icons.person_outline, user?.capitalizedUsername ?? '...'),
            const SizedBox(height: 8),
            _buildUserInfo(Icons.email_outlined, user?.email ?? '...'),
            const SizedBox(height: 32),
            CustomTextField(controller: _subjectController, labelText: 'Subject'),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _messageController,
              labelText: 'Your Message',
              keyboardType: TextInputType.multiline,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Message cannot be empty';
                if (value.length < 10) return 'Please provide more details (at least 10 characters)';
                return null;
              },
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Submit Ticket', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text(text, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }
}

// Widget to display the list of past tickets
class TicketHistoryList extends StatelessWidget {
  const TicketHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SupportProvider>(
      builder: (context, provider, child) {
        if (provider.status == SupportStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.status == SupportStatus.error) {
          return Center(child: Text('Error: ${provider.errorMessage}'));
        }
        if (provider.tickets.isEmpty) {
          return const Center(child: Text('You have no support tickets.'));
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchTickets(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.tickets.length,
            itemBuilder: (context, index) {
              final ticket = provider.tickets[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(ticket.subject, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Submitted: ${DateFormat.yMMMd().add_jm().format(ticket.createdAt)}',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  trailing: _buildStatusChip(ticket.status),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text = status.replaceAll('_', ' ').toUpperCase();
    switch (status) {
      case 'OPEN':
        color = Colors.blue;
        break;
      case 'IN_PROGRESS':
        color = Colors.orange;
        break;
      case 'CLOSED':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(text, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}