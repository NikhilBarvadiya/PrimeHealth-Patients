class PopularDoctorModel {
  final String? profileImage;
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final Services services;
  final dynamic avgRating;
  final int totalBookings;
  final int totalReviews;

  PopularDoctorModel({
    required this.profileImage,
    required this.id,
    required this.name,
    required this.specialty,
    required this.bio,
    required this.services,
    required this.avgRating,
    required this.totalBookings,
    required this.totalReviews,
  });

  /// Factory to parse nested `doctor` object from API
  factory PopularDoctorModel.fromJson(Map<String, dynamic> json) {
    return PopularDoctorModel(
      profileImage: json['profileImage']?.toString(),
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Doctor',
      specialty: _extractSpecialty(json['specialty']),
      bio: json['bio']?.toString() ?? 'No bio available',
      services: Services.fromJson(json['services'] ?? {}),
      avgRating: _parseDouble(json['avgRating'] ?? json['rating'] ?? 0),
      totalBookings: _parseInt(json['totalBookings'] ?? 0),
      totalReviews: _parseInt(json['totalReviews'] ?? 0),
    );
  }

  // Helper: extract specialty name if it's an ObjectId or populated object
  static String _extractSpecialty(dynamic specialty) {
    if (specialty is Map) {
      return specialty['name']?.toString() ?? 'General Medicine';
    }
    if (specialty is String) {
      return specialty;
    }
    return 'General Medicine';
  }

  // Safe int parser
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Safe double parser (for avgRating)
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class Services {
  final String id;
  final String name;

  Services({required this.id, required this.name});

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(id: json['_id']?.toString() ?? '', name: json['name']?.toString() ?? 'Service');
  }

  @override
  String toString() => name;
}
