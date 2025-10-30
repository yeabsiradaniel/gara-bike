// lib/providers/weather_provider.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gara_bike/api/api_service.dart';
import 'package:gara_bike/models/weather_model.dart';

enum WeatherStatus { initial, loading, loaded, error }

class WeatherProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Weather? _weather;
  WeatherStatus _status = WeatherStatus.initial;
  String _errorMessage = '';

  Weather? get weather => _weather;
  WeatherStatus get status => _status;
  String get errorMessage => _errorMessage;

  Future<void> fetchWeather(Position position) async {
    _status = WeatherStatus.loading;
    notifyListeners();
    try {
      _weather = await _apiService.getWeather(position);
      _status = WeatherStatus.loaded;
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
