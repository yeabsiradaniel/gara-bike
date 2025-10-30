// lib/providers/pass_provider.dart

import 'package:flutter/material.dart';
import 'package:gara_bike/api/api_service.dart';
import 'package:gara_bike/models/pass_model.dart';
import 'package:gara_bike/providers/auth_provider.dart';
import 'package:gara_bike/providers/wallet_provider.dart';

enum PassStatus { initial, loading, loaded, error }

class PassProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  WalletProvider? _walletProvider; // To refresh wallet after purchase
  PassProvider(this._authProvider, this._walletProvider);

  // --- ADD THIS METHOD ---
  void updateAuth(AuthProvider? newAuth, WalletProvider? newWallet) {
    _authProvider = newAuth;
    _walletProvider = newWallet;
  }

  final ApiService _apiService = ApiService();
  List<Pass> _passes = [];
  PassStatus _status = PassStatus.initial;
  String _errorMessage = '';

  List<Pass> get passes => _passes;
  PassStatus get status => _status;
  String get errorMessage => _errorMessage;

  Future<void> fetchAvailablePasses() async {
    _status = PassStatus.loading;
    notifyListeners();
    try {
      _passes = await _apiService.getAvailablePasses();
      _status = PassStatus.loaded;
    } on UnauthorizedException {
      _authProvider?.logout();
      _status = PassStatus.error;
      _errorMessage = 'Session expired. Please log in.';
    } catch (e) {
      _status = PassStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> purchasePass(int passId) async {
    try {
      final response = await _apiService.purchasePass(passId);
      if (response['success']) {
        _walletProvider?.fetchWalletDetails();
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
