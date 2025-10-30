// lib/models/bike_model.dart

class Bike {
  final int id;
  final String qrCode;
  final String status;
  final double latitude;
  final double longitude;
  final int batteryLevel;
  final double? distance;
  final int? reservedById;
  final String? reservationExpiresAt;

  Bike({
    required this.id,
    required this.qrCode,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.batteryLevel,
    this.distance,
    this.reservedById,
    this.reservationExpiresAt,
  });

  factory Bike.fromJson(Map<String, dynamic> json) {
    return Bike(
      id: json['id'],
      qrCode: json['qr_code'],
      status: json['status'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      batteryLevel: json['battery_level'],
      distance: json['distance']?.toDouble(),
      reservedById: json['reserved_by']?['id'],
      reservationExpiresAt: json['reservation_expires_at'],
    );
  }
}
