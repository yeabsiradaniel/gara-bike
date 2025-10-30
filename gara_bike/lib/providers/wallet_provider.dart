// lib/providers/wallet_provider.dart

import 'package:flutter/material.dart';
import 'package:gara_bike/api/api_service.dart';
import 'package:gara_bike/models/wallet_model.dart';
import 'package:gara_bike/providers/auth_provider.dart';

enum WalletStatus { initial, loading, loaded, error }

class WalletProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  WalletProvider(this._authProvider);

  // --- ADD THIS METHOD ---
  void updateAuth(AuthProvider? newAuth) {
    _authProvider = newAuth;
  }

  final ApiService _apiService = ApiService();
  Wallet? _wallet;
  WalletStatus _status = WalletStatus.initial;
  String _errorMessage = '';

  Wallet? get wallet => _wallet;
  WalletStatus get status => _status;
  String get errorMessage => _errorMessage;

  Future<void> fetchWalletDetails() async {
    _status = WalletStatus.loading;
    notifyListeners();
    try {
      final response = await _apiService.getWalletDetails();
      if (response['success'] && response['data'] != null) {
        _wallet = Wallet.fromJson(response['data']);
        _status = WalletStatus.loaded;
      } else {
        throw Exception('Failed to parse wallet data.');
      }
    } on UnauthorizedException {
      _authProvider?.logout();
      _status = WalletStatus.error;
      _errorMessage = 'Session expired. Please log in.';
    } catch (e) {
      _status = WalletStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> topUpWallet(double amount, String paymentMethod) async {
    Map<String, dynamic> response;
    try {
      response = await _apiService.topUpWallet(amount, paymentMethod);
      if (response['success']) {
        await fetchWalletDetails();
      }
      return response;
    } on UnauthorizedException {
      _authProvider?.logout();
      return {'success': false, 'error': {'detail': 'Session expired. Please log in again.'}};
    } catch (e) {
      return {'success': false, 'error': {'detail': e.toString()}};
    }
  }
}
