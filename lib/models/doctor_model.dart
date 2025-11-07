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
  final double rating;
  final String? clinicName;
  final double? followUpFee;

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
    this.rating = 4.5,
    this.clinicName,
    this.followUpFee,
  });

  String get specialization => specialty;

  bool get isAvailable => availableSlots != null && availableSlots! > 0;

  String get displayClinicName => clinicName ?? 'Medical Center';

  String get experienceText => '$experience${experience == 1 ? ' year' : ' years'} exp.';

  String get formattedFee => '\$${consultationFee.toStringAsFixed(0)}';

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    String specialtyName = 'General Medicine';
    if (json['specialty'] is Map) {
      specialtyName = json['specialty']['name']?.toString() ?? 'General Medicine';
    } else if (json['specialty'] is String) {
      specialtyName = json['specialty'] ?? 'General Medicine';
    }
    double consultationFee = 0.0;
    double? followUpFee;
    if (json['pricing'] is Map) {
      consultationFee = double.tryParse(json['pricing']['consultationFee']?.toString() ?? '0') ?? 0.0;
      followUpFee = double.tryParse(json['pricing']['followUpFee']?.toString() ?? '0') ?? 0.0;
    } else {
      consultationFee = double.tryParse(json['consultationFee']?.toString() ?? '0') ?? 0.0;
    }
    List<String> servicesList = [];
    if (json['services'] is List) {
      servicesList = List<String>.from(
        json['services'].map((s) {
          if (s is Map) return s['name']?.toString() ?? '';
          return s.toString();
        }),
      );
    } else if (json['services'] is Map) {
      servicesList = [json['services']['name']?.toString() ?? ''];
    }
    return DoctorModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Doctor',
      email: json['email']?.toString() ?? '',
      mobileNo: json['mobileNo']?.toString() ?? '',
      license: json['license']?.toString() ?? '',
      specialty: specialtyName,
      bio: json['bio']?.toString() ?? 'No bio available',
      profileImage: json['profileImage']?.toString(),
      consultationFee: consultationFee,
      followUpFee: followUpFee,
      experience: int.tryParse(json['experience']?.toString() ?? '0') ?? 0,
      isActive: json['isActive'] ?? true,
      isDeleted: json['isDeleted'] ?? false,
      services: servicesList,
      certifications: List<dynamic>.from(json['certifications'] ?? []),
      availableSlots: json['availableSlots'] != null ? int.tryParse(json['availableSlots'].toString()) : null,
      consultationCount: json['consultationCount'] != null ? int.tryParse(json['consultationCount'].toString()) : null,
      distance: double.tryParse(json['distance']?.toString() ?? '0'),
      rating: double.tryParse(json['rating']?.toString() ?? '4.5') ?? 4.5,
      clinicName: json['clinicName']?.toString(),
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
    double? rating,
    String? clinicName,
    double? followUpFee,
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
      rating: rating ?? this.rating,
      clinicName: clinicName ?? this.clinicName,
      followUpFee: followUpFee ?? this.followUpFee,
    );
  }
}
