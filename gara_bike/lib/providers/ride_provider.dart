// lib/providers/ride_provider.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gara_bike/api/api_service.dart';
import 'package:gara_bike/models/ride_model.dart';
import 'package:gara_bike/models/parking_zone_model.dart';
import 'package:gara_bike/providers/auth_provider.dart';
import 'package:latlong2/latlong.dart';

class RideProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  RideProvider(this._authProvider);

  // --- ADD THIS METHOD ---
  void updateAuth(AuthProvider? newAuth) {
    _authProvider = newAuth;
  }

  final ApiService _apiService = ApiService();
  Ride? _activeRide;
  bool _isLoading = false;

  List<ParkingZone> _allParkingZones = [];
  ParkingZone? _closestZone;
  double? _distanceToClosestZone;

  double _distanceTraveled = 0.0; // In meters
  double _caloriesBurned = 0.0;
  LatLng? _lastPosition;

  Ride? get activeRide => _activeRide;
  bool get isLoading => _isLoading;
  List<ParkingZone> get allParkingZones => _allParkingZones;
  ParkingZone? get closestZone => _closestZone;
  double? get distanceToClosestZone => _distanceToClosestZone;
  double get distanceTraveled => _distanceTraveled;
  double get caloriesBurned => _caloriesBurned;

  // --- NEW GETTER FOR CLEAN UI CODE ---
  String get distanceInKm => (distanceTraveled / 1000).toStringAsFixed(2);


  Future<void> fetchAllParkingZones() async {
    try {
      _allParkingZones = await _apiService.getAllParkingZones();
      notifyListeners();
    } on UnauthorizedException {
      _authProvider?.logout();
    } catch (e) {
      print("Could not fetch parking zones: $e");
    }
  }

  void updateClosestZone(Position userPosition) {
    if (_allParkingZones.isEmpty) return;

    final newPosition = LatLng(userPosition.latitude, userPosition.longitude);

    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude, _lastPosition!.longitude,
        newPosition.latitude, newPosition.longitude,
      );
      _distanceTraveled += distance;
      _caloriesBurned = _distanceTraveled * 0.05;
    }
    _lastPosition = newPosition;

    ParkingZone? currentClosest;
    double? minDistance;

    for (var zone in _allParkingZones) {
      final distance = Geolocator.distanceBetween(
          userPosition.latitude, userPosition.longitude,
          zone.latitude, zone.longitude
      );
      if (minDistance == null || distance < minDistance) {
        minDistance = distance;
        currentClosest = zone;
      }
    }

    _closestZone = currentClosest;
    _distanceToClosestZone = minDistance;
    notifyListeners();
  }

  Future<void> fetchActiveRide() async {
    try {
      final response = await _apiService.getActiveRide();
      if (response['success'] && response['data'] != null) {
        _activeRide = Ride.fromJson(response['data']);
        _distanceTraveled = 0.0;
        _caloriesBurned = 0.0;
        _lastPosition = null;
      } else {
        _activeRide = null;
      }
      notifyListeners();
    } on UnauthorizedException {
      _authProvider?.logout();
    } catch (e) {
      print("Could not fetch active ride: $e");
      _activeRide = null;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> startRide(String qrCode) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.startRide(qrCode);

      if (response['success'] && response['data'] != null) {
        _activeRide = Ride.fromJson(response['data']);
        _distanceTraveled = 0.0;
        _caloriesBurned = 0.0;
        _lastPosition = null;
        notifyListeners();
        return response;
      } else {
        return {'success': false, 'error': response['error'] ?? {'detail': 'Failed to start ride: Empty server response.'}};
      }
    } on UnauthorizedException {
      _authProvider?.logout();
      return {'success': false, 'error': {'detail': 'Session expired. Please log in again.'}};
    } catch (e) {
      return {'success': false, 'error': {'detail': 'An unknown error occurred: [33m${e.toString()}[0m'}};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> endActiveRide() async {
    if (_activeRide == null) {
      return {'success': false, 'error': {'detail': 'No active ride found.'}};
    }
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> response = {'success': false, 'error': {'detail': 'An unknown error occurred.'}};
    try {
      final position = await Geolocator.getCurrentPosition();
      response = await _apiService.endRide(_activeRide!.id, position, _distanceTraveled, _caloriesBurned);
      if (response['success']) {
        _activeRide = null;
      }
    } on UnauthorizedException {
      _authProvider?.logout();
      response = {'success': false, 'error': {'detail': 'Session expired. Please log in again.'}};
    } catch (e) {
      response = {'success': false, 'error': {'detail': e.toString()}};
    }
    _isLoading = false;
    notifyListeners();
    return response;
  }
}