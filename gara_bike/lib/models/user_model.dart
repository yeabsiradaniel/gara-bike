// lib/models/user_model.dart

class User {
  final int id;
  final String username;
  final String email;
  final String phoneNumber;
  final String nid;

  // Lifetime Stats
  final double totalDistanceMeters;
  final int totalCaloriesBurned;
  final int totalDurationMinutes;

  // --- NEWLY ADDED FAVORITE LOCATION FIELDS ---
  final String? homeAddressName;
  final double? homeAddressLat;
  final double? homeAddressLon;
  
  final String? workAddressName;
  final double? workAddressLat;
  final double? workAddressLon;
 
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.nid,
    required this.totalDistanceMeters,
    required this.totalCaloriesBurned,
    required this.totalDurationMinutes,
    // --- Add to constructor ---
    this.homeAddressName,
    this.homeAddressLat,
    this.homeAddressLon,
    this.workAddressName,
    this.workAddressLat,
    this.workAddressLon,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      nid: json['nid'],
      totalDistanceMeters: json['total_distance_meters'] != null ? double.parse(json['total_distance_meters'].toString()) : 0.0,
      totalCaloriesBurned: json['total_calories_burned'] ?? 0,
      totalDurationMinutes: json['total_duration_minutes'] ?? 0,
      // --- Parse new fields from JSON (handle nulls) ---
      homeAddressName: json['home_address_name'],
      homeAddressLat: json['home_address_lat'] != null ? double.parse(json['home_address_lat'].toString()) : null,
      homeAddressLon: json['home_address_lon'] != null ? double.parse(json['home_address_lon'].toString()) : null,
      workAddressName: json['work_address_name'],
      workAddressLat: json['work_address_lat'] != null ? double.parse(json['work_address_lat'].toString()) : null,
      workAddressLon: json['work_address_lon'] != null ? double.parse(json['work_address_lon'].toString()) : null,
    );
  }

  String get capitalizedUsername {
    if (username.isEmpty) return '';
    return username[0].toUpperCase() + username.substring(1);
  }
}
