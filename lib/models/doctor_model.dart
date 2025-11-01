class DoctorModel {
  final String id;
  final String name;
  final String email;
  final String mobileNo;
  final String license;
  final String specialty;
  final String bio;
  final String? profileImage;
  final double consultationFee;
  final int experience;
  final bool isActive;
  final bool isDeleted;
  final List<String> services;
  final List<dynamic> certifications;
  final int? availableSlots;
  final int? consultationCount;
  final double? distance;

  DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNo,
    required this.license,
    required this.specialty,
    required this.bio,
    this.profileImage,
    required this.consultationFee,
    required this.experience,
    required this.isActive,
    required this.isDeleted,
    required this.services,
    required this.certifications,
    this.availableSlots,
    this.consultationCount,
    this.distance,
  });

  // Helper getters
  String get specialization => specialty;

  double get rating => 4.5; // You might want to calculate this from reviews

  bool get isAvailable => availableSlots != null && availableSlots! > 0;

  String get clinicName => 'Medical Center'; // Update based on your data

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Doctor',
      email: json['email']?.toString() ?? '',
      mobileNo: json['mobileNo']?.toString() ?? '',
      license: json['license']?.toString() ?? '',
      specialty: json['specialty'] is Map ? json['specialty']['name']?.toString() ?? 'General Medicine' : json['specialty']?.toString() ?? 'General Medicine',
      bio: json['bio']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
      consultationFee: double.tryParse(json['pricing']?['consultationFee']?.toString() ?? '0') ?? double.tryParse(json['consultationFee']?.toString() ?? '0') ?? 0.0,
      experience: int.tryParse(json['experience']?.toString() ?? '0') ?? 0,
      isActive: json['isActive'] ?? true,
      isDeleted: json['isDeleted'] ?? false,
      services: List<String>.from(json['services']?.map((s) => s['name']?.toString() ?? '') ?? []),
      certifications: List<dynamic>.from(json['certifications'] ?? []),
      availableSlots: json['availableSlots'] != null ? int.tryParse(json['availableSlots'].toString()) : null,
      consultationCount: json['consultationCount'] != null ? int.tryParse(json['consultationCount'].toString()) : null,
      distance: double.tryParse(json['distance']?.toString() ?? '0'),
    );
  }

  DoctorModel copyWith({
    String? id,
    String? name,
    String? email,
    String? mobileNo,
    String? license,
    String? specialty,
    String? bio,
    String? profileImage,
    double? consultationFee,
    int? experience,
    bool? isActive,
    bool? isDeleted,
    List<String>? services,
    List<dynamic>? certifications,
    int? availableSlots,
    int? consultationCount,
    double? distance,
    bool? isFavorite,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobileNo: mobileNo ?? this.mobileNo,
      license: license ?? this.license,
      specialty: specialty ?? this.specialty,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      consultationFee: consultationFee ?? this.consultationFee,
      experience: experience ?? this.experience,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      services: services ?? this.services,
      certifications: certifications ?? this.certifications,
      availableSlots: availableSlots ?? this.availableSlots,
      consultationCount: consultationCount ?? this.consultationCount,
      distance: distance ?? this.distance,
    );
  }
}
