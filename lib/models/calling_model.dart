enum CallType { voice, video }

enum CallStatus { calling, accepted, rejected, ended }

class User {
  final String id;
  final String name;
  final String fcmToken;

  User({required this.id, required this.name, required this.fcmToken});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'] ?? '', name: json['name'] ?? '', fcmToken: json['fcmToken'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'fcmToken': fcmToken};
  }
}

class CallData {
  final String senderId;
  final String senderName;
  final String senderFCMToken;
  final CallType callType;
  final CallStatus status;
  final String channelName;
  final String? startTime;
  final String? endTime;
  final double? duration;

  CallData({
    required this.senderId,
    required this.senderName,
    required this.senderFCMToken,
    required this.callType,
    required this.status,
    required this.channelName,
    this.startTime,
    this.endTime,
    this.duration,
  });

  factory CallData.fromJson(Map<String, dynamic> json) {
    return CallData(
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderFCMToken: json['senderFCMToken'] ?? '',
      callType: CallType.values[int.tryParse(json['callType'].toString()) ?? 0],
      status: CallStatus.values[int.tryParse(json['status'].toString()) ?? 0],
      channelName: json['channelName'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      duration: json['duration'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderFCMToken': senderFCMToken,
      'callType': callType.index,
      'status': status.index,
      'channelName': channelName,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
    };
  }
}
