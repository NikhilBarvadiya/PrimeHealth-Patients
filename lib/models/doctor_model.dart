class DoctorModel {
  final String id;
  final String name;
  final String specialization;
  final double rating;
  final int experience;
  final String image;
  final bool isAvailable;
  final List<String> services;
  final String clinicName;
  final String clinicAddress;
  final double? consultationFee;
  final List<String> languages;
  final String about;
  final List<String> education;
  final List<String> certifications;
  final Map<String, List<String>> availability;
  final int totalReviews;
  final double distance;
  final bool isFavorite;
  final String phoneNumber;
  final String email;
  final String fcmToken;
  final List<String> treatmentApproaches;
  final Map<String, dynamic> stats;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.experience,
    required this.image,
    required this.isAvailable,
    required this.services,
    this.clinicName = '',
    this.clinicAddress = '',
    this.consultationFee = 0.0,
    this.languages = const ['English'],
    this.about = '',
    this.education = const [],
    this.certifications = const [],
    this.availability = const {},
    this.totalReviews = 0,
    this.distance = 0.0,
    this.isFavorite = false,
    this.phoneNumber = '',
    this.email = '',
    this.fcmToken = '',
    this.treatmentApproaches = const [],
    this.stats = const {},
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'rating': rating,
      'experience': experience,
      'image': image,
      'isAvailable': isAvailable,
      'services': services,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'consultationFee': consultationFee,
      'languages': languages,
      'about': about,
      'education': education,
      'certifications': certifications,
      'availability': availability,
      'totalReviews': totalReviews,
      'distance': distance,
      'isFavorite': isFavorite,
      'phoneNumber': phoneNumber,
      'email': email,
      'fcmToken': fcmToken,
      'treatmentApproaches': treatmentApproaches,
      'stats': stats,
    };
  }

  // Create from Map
  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      specialization: map['specialization'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      experience: (map['experience'] ?? 0).toInt(),
      image: map['image'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
      services: List<String>.from(map['services'] ?? []),
      clinicName: map['clinicName'] ?? '',
      clinicAddress: map['clinicAddress'] ?? '',
      consultationFee: (map['consultationFee'] ?? 0.0).toDouble(),
      languages: List<String>.from(map['languages'] ?? ['English']),
      about: map['about'] ?? '',
      education: List<String>.from(map['education'] ?? []),
      certifications: List<String>.from(map['certifications'] ?? []),
      availability: Map<String, List<String>>.from(map['availability'] ?? {}),
      totalReviews: (map['totalReviews'] ?? 0).toInt(),
      distance: (map['distance'] ?? 0.0).toDouble(),
      isFavorite: map['isFavorite'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
      treatmentApproaches: List<String>.from(map['treatmentApproaches'] ?? []),
      stats: Map<String, dynamic>.from(map['stats'] ?? {}),
    );
  }

  // Copy with method for immutability
  DoctorModel copyWith({
    String? id,
    String? name,
    String? specialization,
    double? rating,
    int? experience,
    String? image,
    bool? isAvailable,
    List<String>? services,
    String? clinicName,
    String? clinicAddress,
    double? consultationFee,
    List<String>? languages,
    String? about,
    List<String>? education,
    List<String>? certifications,
    Map<String, List<String>>? availability,
    int? totalReviews,
    double? distance,
    bool? isFavorite,
    String? phoneNumber,
    String? email,
    String? fcmToken,
    List<String>? treatmentApproaches,
    Map<String, dynamic>? stats,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      rating: rating ?? this.rating,
      experience: experience ?? this.experience,
      image: image ?? this.image,
      isAvailable: isAvailable ?? this.isAvailable,
      services: services ?? this.services,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      consultationFee: consultationFee ?? this.consultationFee,
      languages: languages ?? this.languages,
      about: about ?? this.about,
      education: education ?? this.education,
      certifications: certifications ?? this.certifications,
      availability: availability ?? this.availability,
      totalReviews: totalReviews ?? this.totalReviews,
      distance: distance ?? this.distance,
      isFavorite: isFavorite ?? this.isFavorite,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      fcmToken: fcmToken ?? this.fcmToken,
      treatmentApproaches: treatmentApproaches ?? this.treatmentApproaches,
      stats: stats ?? this.stats,
    );
  }

  // Helper methods
  String get experienceText {
    if (experience == 1) return '$experience year';
    return '$experience years';
  }

  String get ratingText => '$rating • $totalReviews reviews';

  String get feeText => '₹$consultationFee';

  bool get isSeniorDoctor => experience >= 10;

  List<String> get availableDays => availability.keys.toList();

  // Check if doctor is available on a specific day
  bool isAvailableOnDay(String day) {
    return availability.containsKey(day) && availability[day]!.isNotEmpty;
  }

  // Get available time slots for a specific day
  List<String> getTimeSlotsForDay(String day) {
    return availability[day] ?? [];
  }

  // Calculate distance text
  String get distanceText {
    if (distance < 1) {
      return '${(distance * 1000).round()} m away';
    }
    return '${distance.toStringAsFixed(1)} km away';
  }

  // Get first available slot
  String? get firstAvailableSlot {
    for (final day in availableDays) {
      final slots = getTimeSlotsForDay(day);
      if (slots.isNotEmpty) return '${slots.first} • $day';
    }
    return null;
  }

  // Get treatment approaches as formatted string
  String get treatmentApproachesText {
    if (treatmentApproaches.isEmpty) return 'Not specified';
    if (treatmentApproaches.length <= 2) {
      return treatmentApproaches.join(', ');
    }
    return '${treatmentApproaches.take(2).join(', ')} +${treatmentApproaches.length - 2} more';
  }

  // Get languages as formatted string
  String get languagesText {
    if (languages.isEmpty) return 'English';
    return languages.join(', ');
  }

  // Get education as formatted string
  String get educationText {
    if (education.isEmpty) return 'Education not specified';
    return education.join(' • ');
  }

  // Get certifications count
  String get certificationsText {
    if (certifications.isEmpty) return 'No certifications';
    return '${certifications.length} certifications';
  }

  // Get stats information
  String get successRateText {
    final rate = stats['successRate'] ?? 0;
    return '$rate% Success Rate';
  }

  String get patientsTreatedText {
    final patients = stats['patientsTreated'] ?? 0;
    return '$patients+ Patients Treated';
  }

  @override
  String toString() {
    return 'DoctorModel(id: $id, name: $name, specialization: $specialization, rating: $rating, experience: $experience, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

// Sample data for testing
List<DoctorModel> sampleDoctors = [
  DoctorModel(
    id: '1',
    name: 'Dr. Sarah Johnson',
    specialization: 'Orthopedic Specialist',
    rating: 4.8,
    experience: 8,
    image: 'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg',
    isAvailable: true,
    services: ['Ortho Therapy', 'Pain Management', 'Joint Replacement'],
    clinicName: 'Prime Health Ortho Center',
    clinicAddress: '123 Health Street, Medical Complex, Mumbai',
    consultationFee: 1200.0,
    languages: ['English', 'Hindi', 'Marathi'],
    about:
        'Dr. Sarah Johnson is a renowned orthopedic specialist with 8 years of experience in treating bone and joint disorders. She specializes in minimally invasive surgeries and has successfully treated over 5000 patients.',
    education: ['MBBS - AIIMS Delhi', 'MS Orthopedics - Harvard Medical School'],
    certifications: ['Fellowship in Joint Replacement', 'Diploma in Sports Medicine'],
    availability: {
      'Monday': ['10:00 AM', '02:00 PM', '04:00 PM'],
      'Tuesday': ['09:00 AM', '11:00 AM', '03:00 PM'],
      'Wednesday': ['10:00 AM', '02:00 PM', '05:00 PM'],
      'Friday': ['09:00 AM', '01:00 PM', '04:00 PM'],
    },
    totalReviews: 234,
    distance: 2.5,
    isFavorite: true,
    phoneNumber: '+91 9876543210',
    email: 'sarah.johnson@primehealth.com',
    treatmentApproaches: ['Minimally Invasive Surgery', 'Physical Therapy', 'Pain Management'],
    stats: {'successRate': 95, 'patientsTreated': 5000, 'surgeriesPerformed': 1200},
  ),
  DoctorModel(
    id: '2',
    name: 'Dr. Mike Wilson',
    specialization: 'Neurology Expert',
    rating: 4.9,
    experience: 12,
    image: 'https://images.pexels.com/photos/5452201/pexels-photo-5452201.jpeg',
    isAvailable: true,
    services: ['Neuro Therapy', 'Coordination Therapy', 'Stroke Rehabilitation'],
    clinicName: 'Neuro Care Center',
    clinicAddress: '456 Brain Avenue, Science Park, Delhi',
    consultationFee: 1500.0,
    languages: ['English', 'Hindi'],
    about: 'Dr. Mike Wilson is a senior neurologist with 12 years of experience in treating neurological disorders. He has pioneered several innovative treatments for stroke rehabilitation.',
    education: ['MBBS - Johns Hopkins', 'DM Neurology - Mayo Clinic'],
    certifications: ['Board Certified Neurologist', 'Fellowship in Stroke Management'],
    availability: {
      'Monday': ['11:00 AM', '03:00 PM'],
      'Wednesday': ['10:00 AM', '02:00 PM', '04:00 PM'],
      'Thursday': ['09:00 AM', '01:00 PM'],
      'Saturday': ['10:00 AM', '12:00 PM'],
    },
    totalReviews: 189,
    distance: 1.8,
    isFavorite: false,
    phoneNumber: '+91 9876543211',
    email: 'mike.wilson@primehealth.com',
    treatmentApproaches: ['Cognitive Therapy', 'Motor Skills Training', 'Medication Management'],
    stats: {'successRate': 92, 'patientsTreated': 3500, 'rehabilitationSuccess': 88},
  ),
  DoctorModel(
    id: '3',
    name: 'Dr. Emily Chen',
    specialization: 'Pediatric Care',
    rating: 4.7,
    experience: 6,
    image: 'https://images.pexels.com/photos/4173251/pexels-photo-4173251.jpeg',
    isAvailable: false,
    services: ['Pediatric Therapy', 'Child Development', 'Vaccination'],
    clinicName: 'Little Stars Pediatric Center',
    clinicAddress: '789 Child Care Road, Kids Zone, Bangalore',
    consultationFee: 1000.0,
    languages: ['English', 'Hindi', 'Kannada'],
    about: 'Dr. Emily Chen specializes in pediatric care and child development. She has a gentle approach that makes children comfortable during treatments.',
    education: ['MBBS - CMC Vellore', 'MD Pediatrics - AIIMS Delhi'],
    certifications: ['Pediatric Advanced Life Support', 'Child Development Specialist'],
    availability: {
      'Tuesday': ['10:00 AM', '02:00 PM'],
      'Thursday': ['09:00 AM', '11:00 AM', '03:00 PM'],
      'Friday': ['10:00 AM', '01:00 PM'],
    },
    totalReviews: 156,
    distance: 3.2,
    isFavorite: true,
    phoneNumber: '+91 9876543212',
    email: 'emily.chen@primehealth.com',
    treatmentApproaches: ['Play Therapy', 'Behavioral Therapy', 'Developmental Assessment'],
    stats: {'successRate': 94, 'patientsTreated': 2800, 'developmentCases': 1200},
  ),
];
