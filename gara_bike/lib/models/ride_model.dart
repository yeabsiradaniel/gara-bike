// lib/models/ride_model.dart

import 'package:gara_bike/models/user_model.dart';
import 'package:gara_bike/models/bike_model.dart';

class Ride {
  final int id;
  final Bike bike;
  final User user;
  final String startTime;
  final double startLatitude;
  final double startLongitude;

  final String? endTime;
  final double? cost;
  final double? endLatitude;
  final double? endLongitude;

  // --- NEWLY ADDED FIELDS ---
  final double? distanceMeters;
  final int? caloriesBurned;
  // --- END OF NEW FIELDS ---


  Ride({
    required this.id,
    required this.bike,
    required this.user,
    required this.startTime,
    required this.startLatitude,
    required this.startLongitude,
    this.endTime,
    this.cost,
    this.endLatitude,
    this.endLongitude,
    this.distanceMeters,
    this.caloriesBurned,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'],
      bike: Bike.fromJson(json['bike']),
      user: User.fromJson(json['user']),
      startTime: json['start_time'],
      startLatitude: double.parse(json['start_latitude'].toString()),
      startLongitude: double.parse(json['start_longitude'].toString()),
      endTime: json['end_time'],
      cost: json['cost'] != null ? double.parse(json['cost'].toString()) : null,
      endLatitude: json['end_latitude'] != null ? double.parse(json['end_latitude'].toString()) : null,
      endLongitude: json['end_longitude'] != null ? double.parse(json['end_longitude'].toString()) : null,

      // --- PARSE THE NEW FIELDS ---
      distanceMeters: json['distance_meters'] != null ? double.parse(json['distance_meters'].toString()) : null,
      caloriesBurned: json['calories_burned'],
      // --- END PARSING ---
    );
  }
}