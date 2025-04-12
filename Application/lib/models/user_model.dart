class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? role;
  final bool emailVerified;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<dynamic>? backgroundImages;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.role,
    this.emailVerified = false,
    this.emailVerifiedAt,
    required this.createdAt,
    this.updatedAt,
    this.backgroundImages,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      role: json['role'],
      emailVerified:
          json['email_verified'] == 1 || json['email_verified'] == true,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      backgroundImages: json['background_images'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'email_verified': emailVerified,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
