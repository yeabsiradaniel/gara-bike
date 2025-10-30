// lib/models/support_ticket_model.dart

class SupportTicket {
  final int id;
  final String subject;
  final String message;
  final String status;
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'],
      subject: json['subject'],
      message: json['message'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}