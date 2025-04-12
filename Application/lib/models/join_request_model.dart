import 'club_model.dart';
import 'event_model.dart';
import 'user_model.dart';

class JoinRequest {
  final int id;
  final int userId;
  final int? clubId;
  final int? eventId;
  final String type;
  final String status;
  final String? message;
  final String? responseMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? respondedAt;
  final User? user;
  final Club? club;
  final Event? event;

  JoinRequest({
    required this.id,
    required this.userId,
    this.clubId,
    this.eventId,
    required this.type,
    required this.status,
    this.message,
    this.responseMessage,
    required this.createdAt,
    this.updatedAt,
    this.respondedAt,
    this.user,
    this.club,
    this.event,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    try {
      return JoinRequest(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? 0,
        clubId: json['club_id'],
        eventId: json['event_id'],
        type: json['type'] ?? 'unknown',
        status: json['status'] ?? 'pending',
        message: json['message'],
        responseMessage: json['response_message'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString())
            : null,
        respondedAt: json['responded_at'] != null
            ? DateTime.parse(json['responded_at'].toString())
            : null,
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        club: json['club'] != null ? Club.fromJson(json['club']) : null,
        event: json['event'] != null ? Event.fromJson(json['event']) : null,
      );
    } catch (e) {
      print('Error in JoinRequest.fromJson: $e for data: $json');
      // Tạo một join request mặc định để tránh crash
      return JoinRequest(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? 0,
        type: json['type'] ?? 'unknown',
        status: 'error',
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'club_id': clubId,
      'event_id': eventId,
      'type': type,
      'status': status,
      'message': message,
      'response_message': responseMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
    };
  }
}
