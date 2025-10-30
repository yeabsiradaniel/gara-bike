// lib/models/statistics_model.dart

class Statistics {
  final String duration;
  final String distance;
  final String calories;
  final String carbon;

  Statistics({
    required this.duration,
    required this.distance,
    required this.calories,
    required this.carbon,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      duration: json['duration'] ?? '0 mins',
      distance: json['distance'] ?? '0 m',
      calories: json['calories'] ?? '0 cal',
      carbon: json['carbon'] ?? '0.00 oz',
    );
  }
}