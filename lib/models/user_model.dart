class UserModel {
  final String id;
  final String fcm;
  final String name;
  final String email;
  final String mobileNo;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final List<String>? allergies;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? emergencyContact;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.fcm,
    required this.name,
    required this.email,
    required this.mobileNo,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.allergies,
    this.address,
    this.emergencyContact,
    this.profileImage,
  });

  String get city => address?['city'] ?? '';

  String get state => address?['state'] ?? '';

  String get country => address?['country'] ?? '';

  String get emergencyName => emergencyContact?['name'] ?? '';

  String get emergencyMobile => emergencyContact?['mobileNo'] ?? '';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      fcm: json['fcm'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],
      allergies: json['allergies'] != null ? List<String>.from(json['allergies']) : [],
      address: json['address'] != null ? Map<String, dynamic>.from(json['address']) : null,
      emergencyContact: json['emergencyContact'] != null ? Map<String, dynamic>.from(json['emergencyContact']) : null,
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'fcm': fcm,
      'email': email,
      'mobileNo': mobileNo,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'address': address,
      'emergencyContact': emergencyContact,
    };
  }
}
