
// Author: Yeabsira Daniel
// Date: JAN/26/2025
//
// This file implements the ApiService class, which handles all HTTP requests to the Gara Bike backend API.
// It provides methods for authentication, user profile, rides, reservations, wallet, passes, statistics, and more.
// The service uses secure storage for tokens and manages authorization headers for protected endpoints.
//
// Main components:
// - ApiService: Main class for all API calls and response handling.
// - UnauthorizedException: Custom exception for 401 responses.

// lib/api/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:gara_bike/models/bike_model.dart';
import 'package:gara_bike/models/user_model.dart';
import 'package:gara_bike/models/weather_model.dart';
import 'package:gara_bike/models/parking_zone_model.dart';
import '../models/pass_model.dart';
import 'package:gara_bike/models/support_ticket_model.dart';


/// Exception thrown when an API call returns a 401 Unauthorized response.
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}


/// Main service class for all Gara Bike API calls.
class ApiService {
  // --- NEW METHOD FOR UPDATING USER PROFILE ---
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    final response = await http.patch( // Using PATCH for partial updates
      Uri.parse('$_baseUrl/users/me/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    return _handleResponse(response);
  }
  // --- END OF NEW METHOD ---
  // --- NEW METHODS FOR SUPPORT ---
  Future<List<SupportTicket>> getSupportTickets() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/support-tickets/'),
      headers: await _getAuthHeaders(),
    );
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SupportTicket.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load support tickets');
    }
  }

  Future<Map<String, dynamic>> createSupportTicket(String subject, String message) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/support-tickets/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode({
        'subject': subject,
        'message': message,
      }),
    );
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    return _handleResponse(response);
  }
  // --- END OF NEW METHODS ---
  // --- Referral code API ---
  /// Fetches the user's referral code for inviting friends.
  Future<Map<String, dynamic>> getReferralCode() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/invite-friends/'),
      headers: await _getAuthHeaders(),
    );
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    return _handleResponse(response);
  }

  // --- User statistics API ---
  /// Fetches the user's ride statistics (duration, distance, calories, carbon, etc).
  Future<Map<String, dynamic>> getUserStatistics() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/statistics/'),
      headers: await _getAuthHeaders(),
    );
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    return _handleResponse(response);
  }

  /// Base URL for the Gara Bike API.
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  /// Secure storage for authentication tokens.
  final _storage = const FlutterSecureStorage();
  /// API key for weather data.
  static const String _weatherApiKey = 'e8fc8665d22b4f379e7175246250207';

  /// Reads the stored authentication token.
  Future<String?> _getToken() async => await _storage.read(key: 'auth_token');

  /// Builds headers for authenticated API requests.
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {'Content-Type': 'application/json; charset=UTF-8', if (token != null) 'Authorization': 'Bearer $token'};
  }


  /// Fetches the user's active reservation, if any.
  /// Returns null data if no reservation exists (404).
  Future<Map<String, dynamic>> getActiveReservation() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/reservations/active/'),
      headers: await _getAuthHeaders(),
    );
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    // A 404 is an expected response if there's no reservation, so handle it gracefully
    if (response.statusCode == 404) return {'success': true, 'data': null};
    return _handleResponse(response);
  }


  /// Fetches the user's active ride, if any.
  /// Returns null data if no ride exists (404).
  Future<Map<String, dynamic>> getActiveRide() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/rides/active/'),
      headers: await _getAuthHeaders(),
    );
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    if (response.statusCode == 404) return {'success': true, 'data': null};
    return _handleResponse(response);
  }


  /// Ends the current ride and submits ride stats (location, distance, calories).
  Future<Map<String, dynamic>> endRide(int rideId, Position position, double distance, double calories) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/rides/$rideId/end-ride/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode({
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'distance': distance.toString(),
        'calories': calories.toString(),
      }),
    );
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    return _handleResponse(response);
  }


  /// Registers a new user with the provided details.
  Future<Map<String, dynamic>> register({
    required String username, required String email, required String phoneNumber,
    required String nid, required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode({
        'username': username,
        'email': email,
        'phone_number': phoneNumber,
        'nid': nid,
        'password': password,
        'password2': password,
      }),
    );
    return _handleResponse(response);
  }


  /// Verifies the OTP code for the given email.
  Future<Map<String, dynamic>> verifyOtp({ required String email, required String otp }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/verify-otp/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    return _handleResponse(response);
  }


  /// Logs in the user and stores the authentication tokens.
  Future<Map<String, dynamic>> login({ required String email, required String password }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/token/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'auth_token', value: data['access']);
      await _storage.write(key: 'refresh_token', value: data['refresh']);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'error': jsonDecode(response.body)};
    }
  }


  /// Logs out the user by deleting all stored tokens.
  Future<void> logout() async => await _storage.deleteAll();

  /// Fetches the current user's profile.
  Future<User> getUserProfile() async {
    final response = await http.get(Uri.parse('$_baseUrl/users/me/'), headers: await _getAuthHeaders());
    if (response.statusCode == 200) return User.fromJson(jsonDecode(response.body));
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    throw Exception('Failed to load user profile');
  }


  /// Fetches weather data for the given [position] using WeatherAPI.
  Future<Weather> getWeather(Position position) async {
    final uri = Uri.parse('https://api.weatherapi.com/v1/current.json?key=$_weatherApiKey&q=${position.latitude},${position.longitude}');
    final response = await http.get(uri);
    if (response.statusCode == 200) return Weather.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load weather data');
  }


  /// Fetches a cycling route between [start] and [end] using OSRM API.
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = 'https://router.project-osrm.org/route/v1/cycling/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['routes'][0]['geometry']['coordinates'].map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();
    } else {
      throw Exception('Failed to load route');
    }
  }


  /// Fetches a list of nearby bikes for the given [position].
  Future<List<Bike>> getNearbyBikes(Position position) async {
    final uri = Uri.parse('$_baseUrl/bikes/').replace(queryParameters: {'lat': position.latitude.toString(), 'lon': position.longitude.toString()});
    final response = await http.get(uri, headers: await _getAuthHeaders());
    if (response.statusCode == 200) return (jsonDecode(response.body) as List).map((data) => Bike.fromJson(data)).toList();
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    throw Exception('Failed to load bikes: ${response.statusCode}');
  }


  /// Starts a new ride using the scanned [qrCode].
  Future<Map<String, dynamic>> startRide(String qrCode) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/rides/start-ride/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode({'qr_code': qrCode}),
    );
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    return _handleResponse(response);
  }


  /// Searches for parking zones matching the [query] string.
  Future<List<ParkingZone>> searchParkingZones(String query) async {
    final uri = Uri.parse('$_baseUrl/parking-zones/').replace(queryParameters: {'search': query});
    final response = await http.get(uri, headers: await _getAuthHeaders());
    if (response.statusCode == 200) return (jsonDecode(response.body) as List).map((data) => ParkingZone.fromJson(data)).toList();
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    throw Exception('Failed to search parking zones.');
  }


  /// Reserves a bike for the given [bikeId] and [duration] (in minutes).
  Future<Map<String, dynamic>> reserveBike(int bikeId, int duration) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/bikes/$bikeId/reserve/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode({'duration': duration}),
    );
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    return _handleResponse(response);
  }


  /// Cancels a reservation for the given [bikeId] and [originalDuration].
  Future<Map<String, dynamic>> cancelReservation(int bikeId, int originalDuration) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/bikes/$bikeId/cancel-reservation/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode({'original_duration': originalDuration}),
    );
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    return _handleResponse(response);
  }

  // --- NEW METHOD ---

  /// Fetches all bikes available in the specified parking zone [zoneId].
  Future<List<Bike>> getBikesInZone(int zoneId) async {
    final uri = Uri.parse('$_baseUrl/bikes/').replace(queryParameters: {'zone_id': zoneId.toString()});
    final response = await http.get(uri, headers: await _getAuthHeaders());
    if (response.statusCode == 200) return (jsonDecode(response.body) as List).map((data) => Bike.fromJson(data)).toList();
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    throw Exception('Failed to load bikes in zone.');
  }


  /// Fetches the user's wallet details (balance, transactions, etc).
  Future<Map<String, dynamic>> getWalletDetails() async {
    final response = await http.get(Uri.parse('$_baseUrl/wallet/'), headers: await _getAuthHeaders());
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    return _handleResponse(response);
  }


  /// Tops up the user's wallet with the specified [amount] and [paymentMethod].
  Future<Map<String, dynamic>> topUpWallet(double amount, String paymentMethod) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/wallet/top-up/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode({
        'amount': amount.toString(),
        'payment_method': paymentMethod,
      }),
    );
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    return _handleResponse(response);
  }



  /// Fetches all available passes for purchase.
  Future<List<Pass>> getAvailablePasses() async {
    final response = await http.get(Uri.parse('$_baseUrl/passes/'), headers: await _getAuthHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Pass.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Session expired');
    } else {
      throw Exception('Failed to load passes.');
    }
  }


  /// Purchases a pass with the given [passId].
  Future<Map<String, dynamic>> purchasePass(int passId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/wallet/purchase-pass/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode({'pass_id': passId}),
    );
    if (response.statusCode == 401) throw UnauthorizedException('Session expired');
    return _handleResponse(response);
  }



  /// Handles HTTP responses, returning a success or error map.
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': jsonDecode(response.body)};
    }
  }

  /// Fetches all parking zones from the backend.
  Future<List<ParkingZone>> getAllParkingZones() async {
    final uri = Uri.parse('$_baseUrl/parking-zones/');
    final response = await http.get(uri, headers: await _getAuthHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ParkingZone.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Session expired');
    } else {
      throw Exception('Failed to load parking zones.');
    }
  }
}
