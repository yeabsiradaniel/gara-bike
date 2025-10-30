// lib/providers/statistics_provider.dart

import 'package:flutter/material.dart';
import 'package:gara_bike/api/api_service.dart';
import 'package:gara_bike/providers/auth_provider.dart';

enum StatisticsStatus { initial, loading, loaded, error }

class StatisticsProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  StatisticsProvider(this._authProvider);

  // --- ADD THIS METHOD ---
  void updateAuth(AuthProvider? newAuth) {
    _authProvider = newAuth;
  }

  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _stats;
  StatisticsStatus _status = StatisticsStatus.initial;
  String _errorMessage = '';

  Map<String, dynamic>? get stats => _stats;
  StatisticsStatus get status => _status;
  String get errorMessage => _errorMessage;

  Future<void> fetchStatistics() async {
    _status = StatisticsStatus.loading;
    notifyListeners();
    try {
      final response = await _apiService.getUserStatistics();
      if (response['success']) {
        _stats = response['data'];
        _status = StatisticsStatus.loaded;
      } else {
        throw Exception(response['error']?['detail'] ?? 'Failed to load stats');
      }
    } on UnauthorizedException {
      _authProvider?.logout();
      _status = StatisticsStatus.error;
      _errorMessage = 'Session expired. Please log in.';
    } catch (e) {
      _status = StatisticsStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}