// lib/providers/bike_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gara_bike/api/api_service.dart';
import 'package:gara_bike/models/bike_model.dart';
import 'package:gara_bike/providers/auth_provider.dart';

enum BikeStatus { initial, loading, loaded, error }

class BikeProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  BikeProvider(this._authProvider);

  // --- ADD THIS METHOD ---
  void updateAuth(AuthProvider? newAuth) {
    _authProvider = newAuth;
  }

  final ApiService _apiService = ApiService();
  List<Bike> _bikes = [];
  BikeStatus _status = BikeStatus.initial;
  String _errorMessage = '';

  // State for the user's active reservation
  Bike? _activeReservation;

  // Getters for the UI to access the state
  List<Bike> get bikes => _bikes;
  BikeStatus get status => _status;
  String get errorMessage => _errorMessage;
  Bike? get activeReservation => _activeReservation;

  Future<void> fetchNearbyBikes() async {
    // This is a helper to get the position just for this call
    // Note: The UI layer (HomeScreen) now controls when this is called.
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _status = BikeStatus.loading;
      notifyListeners();
      _bikes = await _apiService.getNearbyBikes(position);
      _status = BikeStatus.loaded;
    } on UnauthorizedException {
      _authProvider?.logout();
      _status = BikeStatus.error;
      _errorMessage = 'Your session has expired. Please log in.';
    } catch (e) {
      _status = BikeStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchActiveReservation() async {
    try {
      final response = await _apiService.getActiveReservation();
      if (response['success'] && response['data'] != null) {
        _activeReservation = Bike.fromJson(response['data']);
      } else {
        _activeReservation = null;
      }
      notifyListeners();
    } on UnauthorizedException {
      _authProvider?.logout();
    } catch (e) {
      print("Could not fetch active reservation: $e");
      _activeReservation = null;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> reserveBike(int bikeId, int duration) async {
    try {
      final response = await _apiService.reserveBike(bikeId, duration);
      if (response['success']) {
        // After reserving, update the global state
        await fetchActiveReservation();
        // Also refresh the main list of bikes on the home screen
        await fetchNearbyBikes();
      }
      return response;
    } on UnauthorizedException {
      _authProvider?.logout();
      return {'success': false, 'error': 'Session expired.'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> cancelReservation(int bikeId, int originalDuration) async {
    try {
      final response = await _apiService.cancelReservation(bikeId, originalDuration);
      if (response['success']) {
        _activeReservation = null; // Clear the reservation state
        notifyListeners();
        await fetchNearbyBikes();
      }
      return response;
    } on UnauthorizedException {
      _authProvider?.logout();
      return {'success': false, 'error': 'Session expired.'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
