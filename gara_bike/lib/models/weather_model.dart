// lib/models/weather_model.dart

class Weather {
  final String locationName;
  final double temperature;
  final String condition;
  final String iconUrl; // We will get the full URL directly now

  Weather({
    required this.locationName,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
  });

  // This factory is updated to parse the JSON response from WeatherAPI.com
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      locationName: json['location']['name'],
      temperature: (json['current']['temp_c'] as num).toDouble(),
      condition: json['current']['condition']['text'],
      // The API gives a URL but might start with //, so we add https:
      iconUrl: 'https:${json['current']['condition']['icon']}',
    );
  }
}
