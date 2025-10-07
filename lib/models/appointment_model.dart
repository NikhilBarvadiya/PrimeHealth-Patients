class AppointmentModel {
  final String id;
  final String doctorName;
  final String fcmToken;

  AppointmentModel({required this.id, required this.doctorName, required this.fcmToken});

  AppointmentModel copyWith({String? id, String? doctorName, String? fcmToken}) {
    return AppointmentModel(id: id ?? this.id, doctorName: doctorName ?? this.doctorName, fcmToken: fcmToken ?? this.fcmToken);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'doctorName': doctorName, 'fcmToken': fcmToken};
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(id: map['id'] ?? '', doctorName: map['doctorName'] ?? '', fcmToken: map['fcmToken'] ?? '');
  }
}
