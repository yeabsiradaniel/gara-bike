// lib/providers/support_provider.dart

import 'package:flutter/material.dart';
import 'package:gara_bike/api/api_service.dart';
import 'package:gara_bike/models/support_ticket_model.dart';
import 'package:gara_bike/providers/auth_provider.dart';

enum SupportStatus { initial, loading, loaded, error }

class SupportProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  SupportProvider(this._authProvider);

  // --- ADD THIS METHOD ---
  void updateAuth(AuthProvider? newAuth) {
    _authProvider = newAuth;
  }
  // --- END OF FIX ---

  final ApiService _apiService = ApiService();
  List<SupportTicket> _tickets = [];
  SupportStatus _status = SupportStatus.initial;
  String _errorMessage = '';

  List<SupportTicket> get tickets => _tickets;
  SupportStatus get status => _status;
  String get errorMessage => _errorMessage;

  Future<void> fetchTickets() async {
    _status = SupportStatus.loading;
    notifyListeners();
    try {
      _tickets = await _apiService.getSupportTickets();
      _status = SupportStatus.loaded;
    } on UnauthorizedException {
      _authProvider?.logout();
      _status = SupportStatus.error;
      _errorMessage = 'Session expired.';
    } catch (e) {
      _status = SupportStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> createTicket(String subject, String message) async {
    try {
      final response = await _apiService.createSupportTicket(subject, message);
      if (response['success']) {
        // After creating a new ticket, refresh the list
        await fetchTickets();
      }
      return response;
    } on UnauthorizedException {
      _authProvider?.logout();
      return {'success': false, 'error': {'detail': 'Session expired.'}};
    } catch (e) {
      return {'success': false, 'error': {'detail': e.toString()}};
    }
  }
}