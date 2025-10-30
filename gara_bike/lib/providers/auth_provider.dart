// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gara_bike/api/api_service.dart';
import 'package:gara_bike/models/user_model.dart';


class AuthProvider with ChangeNotifier {
  // --- NEW METHOD TO HANDLE PROFILE UPDATES ---
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.updateUserProfile(data);
      if (response['success']) {
        // If update is successful, refresh the local user data
        await fetchUserProfile();
      }
      return response;
    } on UnauthorizedException {
      logout();
      return {'success': false, 'error': {'detail': 'Session expired.'}};
    } catch (e) {
      return {'success': false, 'error': {'detail': e.toString()}};
    }
  }
  // --- END OF NEW METHOD ---
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  String? _token;
  User? _user;
  String? _referralCode; // --- NEW: State for referral code ---

  bool get isAuthenticated => _token != null;
  User? get user => _user;
  String? get referralCode => _referralCode; // --- NEW: Getter ---

  // --- NEW: Function to fetch the code ---
  Future<void> fetchReferralCode() async {
    try {
      final response = await _apiService.getReferralCode();
      if (response['success']) {
        _referralCode = response['data']['invitation_code'];
        notifyListeners();
      }
    } catch (e) {
      print("Could not fetch referral code: $e");
    }
  }

  Future<bool> tryAutoLogin() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return false;
    _token = token;
    try {
      await fetchUserProfile();
    } catch (e) {
      await logout();
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.login(email: email, password: password);
    if (response['success']) {
      _token = response['data']['access'];
      await fetchUserProfile();
      notifyListeners();
    }
    return response;
  }

  Future<void> fetchUserProfile() async {
    try {
      _user = await _apiService.getUserProfile();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _apiService.logout();
    notifyListeners();
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String phoneNumber,
    required String nid,
    required String password,
  }) async {
    return await _apiService.register(
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      nid: nid,
      password: password,
    );
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    return await _apiService.verifyOtp(email: email, otp: otp);
  }
}
