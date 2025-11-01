class SlotModel {
  final String id;
  final String doctorId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final bool isRecurring;

  SlotModel({required this.id, required this.doctorId, required this.startTime, required this.endTime, required this.status, required this.isRecurring});

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['_id']?.toString() ?? '',
      doctorId: json['doctorId'] is Map ? json['doctorId']['_id']?.toString() ?? '' : json['doctorId']?.toString() ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: json['status']?.toString() ?? 'available',
      isRecurring: json['isRecurring'] ?? false,
    );
  }
}
