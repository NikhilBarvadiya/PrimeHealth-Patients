class BookingModel {
  String? id;
  String bookingId;
  String patientId;
  String doctorId;
  String slotId;
  String serviceId;
  DateTime appointmentDate;
  String appointmentTime;
  String status;
  String consultationType;
  String? notes;
  String? prescription;
  String? diagnosis;
  bool followUpRequired;
  DateTime? followUpDate;
  String paymentStatus;
  double amount;
  String paymentMethod;
  String? cancellationReason;
  String? cancelledBy;
  DateTime? cancelledAt;
  String? rescheduledFrom;
  String? rescheduledTo;
  double? rating;
  String? review;
  DateTime createdAt;
  DateTime updatedAt;
  String? doctorName;
  String? doctorSpecialty;
  String? doctorProfileImage;
  String? doctorMobileNo;
  String? serviceName;
  String? serviceDescription;

  BookingModel({
    this.id,
    required this.bookingId,
    required this.patientId,
    required this.doctorId,
    required this.slotId,
    required this.serviceId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.consultationType = 'in-person',
    this.notes,
    this.prescription,
    this.diagnosis,
    this.followUpRequired = false,
    this.followUpDate,
    required this.paymentStatus,
    required this.amount,
    this.paymentMethod = 'cash',
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledAt,
    this.rescheduledFrom,
    this.rescheduledTo,
    this.rating,
    this.review,
    required this.createdAt,
    required this.updatedAt,
    this.doctorName,
    this.doctorSpecialty,
    this.doctorProfileImage,
    this.doctorMobileNo,
    this.serviceName,
    this.serviceDescription,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id']?.toString(),
      bookingId: json['bookingId']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      doctorId: json['doctorId'] is Map ? json['doctorId']['_id'].toString() : json['doctorId'],
      slotId: json['slotId']?.toString() ?? '',
      serviceId: json['serviceId'] is Map ? json['serviceId']['_id'].toString() : json['serviceId'],
      appointmentDate: DateTime.parse(json['appointmentDate']?.toString() ?? DateTime.now().toString()),
      appointmentTime: json['appointmentTime']?.toString() ?? '',
      status: json['status']?.toString() ?? 'scheduled',
      consultationType: json['consultationType']?.toString() ?? 'in-person',
      notes: json['notes']?.toString(),
      prescription: json['prescription']?.toString(),
      diagnosis: json['diagnosis']?.toString(),
      followUpRequired: json['followUpRequired'] ?? false,
      followUpDate: json['followUpDate'] != null ? DateTime.parse(json['followUpDate'].toString()) : null,
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'cash',
      cancellationReason: json['cancellationReason']?.toString(),
      cancelledBy: json['cancelledBy']?.toString(),
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt'].toString()) : null,
      rescheduledFrom: json['rescheduledFrom']?.toString(),
      rescheduledTo: json['rescheduledTo']?.toString(),
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      review: json['review']?.toString(),
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toString()),
      doctorName: json['doctorId'] is Map ? json['doctorId']['name']?.toString() : null,
      doctorSpecialty: json['doctorId'] is Map ? json['doctorId']['specialty']?.toString() : null,
      doctorProfileImage: json['doctorId'] is Map ? json['doctorId']['profileImage']?.toString() : null,
      doctorMobileNo: json['doctorId'] is Map ? json['doctorId']['mobileNo']?.toString() : null,
      serviceName: json['serviceId'] is Map ? json['serviceId']['name']?.toString() : null,
      serviceDescription: json['serviceId'] is Map ? json['serviceId']['description']?.toString() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'patientId': patientId,
      'doctorId': doctorId,
      'slotId': slotId,
      'serviceId': serviceId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'appointmentTime': appointmentTime,
      'status': status,
      'consultationType': consultationType,
      'notes': notes,
      'prescription': prescription,
      'diagnosis': diagnosis,
      'followUpRequired': followUpRequired,
      'followUpDate': followUpDate?.toIso8601String(),
      'paymentStatus': paymentStatus,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'cancellationReason': cancellationReason,
      'cancelledBy': cancelledBy,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'rescheduledFrom': rescheduledFrom,
      'rescheduledTo': rescheduledTo,
      'rating': rating,
      'review': review,
    };
  }

  String get statusDisplay {
    final statusMap = {'scheduled': 'Scheduled', 'confirmed': 'Confirmed', 'completed': 'Completed', 'cancelled': 'Cancelled', 'no-show': 'No Show', 'rescheduled': 'Rescheduled'};
    return statusMap[status] ?? status;
  }

  String get formattedDate {
    return '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}';
  }

  String get formattedTime {
    return appointmentTime;
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final appointmentDateTime = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
    return appointmentDateTime.isAfter(now) || appointmentDateTime.isAtSameMomentAs(now);
  }

  bool get canCancel {
    return ['scheduled', 'confirmed'].contains(status) && isUpcoming;
  }

  bool get canReschedule {
    return ['scheduled', 'confirmed'].contains(status) && isUpcoming;
  }
}
