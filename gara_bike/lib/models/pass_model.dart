// lib/models/pass_model.dart

class Pass {
  final int id;
  final String name;
  final double price;
  final int durationDays;

  Pass({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
  });

  factory Pass.fromJson(Map<String, dynamic> json) {
    return Pass(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      durationDays: json['duration_days'],
    );
  }
}
