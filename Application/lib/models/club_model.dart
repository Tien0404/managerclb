class Club {
  final int id;
  final String name;
  final String? description;
  final String? shortDescription;
  final String? phone;
  final String? email;
  final String? website;
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? linkedin;
  final String? youtube;
  final String? address;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<dynamic>? backgroundImages;

  Club({
    required this.id,
    required this.name,
    this.description,
    this.shortDescription,
    this.phone,
    this.email,
    this.website,
    this.facebook,
    this.twitter,
    this.instagram,
    this.linkedin,
    this.youtube,
    this.address,
    required this.createdAt,
    this.updatedAt,
    this.backgroundImages,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    try {
      return Club(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Câu lạc bộ không tên',
        description: json['description'],
        shortDescription: json['short_description'],
        phone: json['phone'],
        email: json['email'],
        website: json['website'],
        facebook: json['facebook'],
        twitter: json['twitter'],
        instagram: json['instagram'],
        linkedin: json['linkedin'],
        youtube: json['youtube'],
        address: json['address'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString())
            : null,
        backgroundImages: json['background_images'] ?? [],
      );
    } catch (e) {
      print('Error in Club.fromJson: $e for data: $json');
      // Tạo một club mặc định để tránh crash
      return Club(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Lỗi dữ liệu',
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'short_description': shortDescription,
      'phone': phone,
      'email': email,
      'website': website,
      'facebook': facebook,
      'twitter': twitter,
      'instagram': instagram,
      'linkedin': linkedin,
      'youtube': youtube,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
