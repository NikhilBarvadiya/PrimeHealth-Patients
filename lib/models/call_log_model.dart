class CallLogModel {
  final String callLogId;
  final String channelName;
  final CallParticipant receiverDetails;
  final CallParticipant senderDetails;
  final String callType;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final int duration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String direction;
  final FcmTokens fcmTokens;

  CallLogModel({
    required this.callLogId,
    required this.channelName,
    required this.receiverDetails,
    required this.senderDetails,
    required this.callType,
    required this.status,
    this.startTime,
    this.endTime,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
    required this.direction,
    required this.fcmTokens,
  });

  factory CallLogModel.fromJson(Map<String, dynamic> json) {
    return CallLogModel(
      callLogId: json['callLogId'] ?? '',
      channelName: json['channelName'] ?? '',
      receiverDetails: CallParticipant.fromJson(json['receiverDetails'] ?? {}),
      senderDetails: CallParticipant.fromJson(json['senderDetails'] ?? {}),
      callType: json['callType'] ?? 'voice',
      status: json['status'] ?? 'ended',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration: int.tryParse(json['duration'].toString()) ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      direction: json['direction'] ?? 'outgoing',
      fcmTokens: FcmTokens.fromJson(json['fcmTokens'] ?? {}),
    );
  }

  bool get isVideoCall => callType == 'video';

  bool get isCompleted => status == 'ended';

  bool get isMissed => status == 'missed';

  bool get isRejected => status == 'rejected';
}

class CallParticipant {
  final String id;
  final String name;
  final String? profileImage;
  final String? mobileNo;
  final String? fcmToken;

  CallParticipant({required this.id, required this.name, this.profileImage, this.mobileNo, this.fcmToken});

  factory CallParticipant.fromJson(Map<String, dynamic> json) {
    return CallParticipant(id: json['id'] ?? '', name: json['name'] ?? 'Unknown', profileImage: json['profileImage'], mobileNo: json['mobileNo'], fcmToken: json['fcmToken']);
  }
}

class FcmTokens {
  final String senderFCM;
  final String receiverFCM;

  FcmTokens({required this.senderFCM, required this.receiverFCM});

  factory FcmTokens.fromJson(Map<String, dynamic> json) {
    return FcmTokens(senderFCM: json['senderFCM'] ?? '', receiverFCM: json['receiverFCM'] ?? '');
  }
}
