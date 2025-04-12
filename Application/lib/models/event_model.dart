import 'club_model.dart';

class Event {
  final int id;
  final int clubId;
  final String name;
  final String? description;
  final String? shortDescription;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? location;
  final int? maxParticipants;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<dynamic>? backgroundImages;
  final Club? club;

  Event({
    required this.id,
    required this.clubId,
    required this.name,
    this.description,
    this.shortDescription,
    this.startDate,
    this.endDate,
    this.location,
    this.maxParticipants,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.backgroundImages,
    this.club,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      return Event(
        id: json['id'] ?? 0,
        clubId: json['club_id'] ?? 0,
        name: json['name'] ?? 'Sự kiện không tên',
        description: json['description'],
        shortDescription: json['short_description'],
        startDate: json['start_date'] != null
            ? DateTime.parse(json['start_date'].toString())
            : null,
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'].toString())
            : null,
        location: json['location'],
        maxParticipants: json['max_participants'],
        status: json['status'] ?? 'unknown',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString())
            : null,
        backgroundImages: json['background_images'] ?? [],
        club: json['club'] != null ? Club.fromJson(json['club']) : null,
      );
    } catch (e) {
      print('Error in Event.fromJson: $e for data: $json');
      // Tạo một event mặc định để tránh crash
      return Event(
        id: json['id'] ?? 0,
        clubId: json['club_id'] ?? 0,
        name: json['name'] ?? 'Lỗi dữ liệu',
        status: 'error',
        createdAt: DateTime.now(),
      );
    }
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'club_id': clubId,
      'name': name,
      'description': description,
      'short_description': shortDescription,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'location': location,
      'max_participants': maxParticipants,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
