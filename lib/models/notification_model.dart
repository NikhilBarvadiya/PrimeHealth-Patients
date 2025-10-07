class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({required this.id, required this.title, required this.message, required this.type, required this.createdAt, this.isRead = false, this.data});

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(id: id, title: title, message: message, type: type, createdAt: createdAt, isRead: isRead ?? this.isRead, data: data);
  }
}
