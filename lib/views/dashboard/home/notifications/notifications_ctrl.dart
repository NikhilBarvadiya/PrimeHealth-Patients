import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_health_patients/models/notification_model.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/appointment_details.dart';

class NotificationsCtrl extends GetxController {
  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    notifications.value = [
      NotificationModel(
        id: '1',
        title: 'Appointment Confirmed! 🎉',
        message: 'Your Orthopedic Therapy with Dr. Sarah Johnson has been confirmed for Today at 10:00 AM',
        type: 'appointment',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        data: {'appointmentId': '1', 'action': 'view'},
      ),
      NotificationModel(
        id: '2',
        title: 'Payment Successful',
        message: 'Your payment of ₹1500 for Neuro Therapy has been processed successfully',
        type: 'payment',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        data: {'appointmentId': '2', 'amount': 1500},
      ),
      NotificationModel(
        id: '3',
        title: 'Appointment Reminder',
        message: 'Reminder: You have Sports Therapy with Dr. Emily Davis tomorrow at 11:00 AM',
        type: 'reminder',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: false,
        data: {'appointmentId': '3', 'date': 'Tomorrow', 'time': '11:00 AM'},
      ),
      NotificationModel(
        id: '4',
        title: 'New Service Available',
        message: 'Check out our new Pain Management service with advanced techniques',
        type: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        data: {'serviceId': '6', 'action': 'explore'},
      ),
      NotificationModel(
        id: '5',
        title: 'Therapist Response',
        message: 'Dr. Mike Wilson has responded to your appointment query',
        type: 'appointment',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        data: {'appointmentId': '2', 'therapistId': '2'},
      ),
      NotificationModel(
        id: '6',
        title: 'Appointment Rescheduled',
        message: 'Your session with Dr. Sarah Johnson has been rescheduled to 25th Jan, 03:00 PM',
        type: 'appointment',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        data: {'appointmentId': '1', 'newDate': '2024-01-25', 'newTime': '03:00 PM'},
      ),
      NotificationModel(
        id: '7',
        title: 'Session Feedback Request',
        message: 'How was your recent session with Dr. Emily Davis? Share your experience',
        type: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isRead: false,
        data: {'appointmentId': '3', 'action': 'review'},
      ),
    ];
    _updateUnreadCount();
    isLoading.value = false;
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((notification) => !notification.isRead).length;
  }

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    markAsRead(notification.id);
    switch (notification.type) {
      case 'appointment':
        _handleAppointmentNotification(notification);
        break;
      case 'payment':
        _handlePaymentNotification(notification);
        break;
    }
  }

  void _handleAppointmentNotification(NotificationModel notification) {
    final appointmentId = notification.data?['appointmentId'];
    if (appointmentId != null) {
      Get.to(() => AppointmentDetails(appointmentId: appointmentId));
    }
  }

  void _handlePaymentNotification(NotificationModel notification) {
    Get.snackbar('Payment Details', 'Your payment has been processed successfully', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
  }

  void addNewNotification(NotificationModel notification) {
    notifications.insert(0, notification);
    _updateUnreadCount();
  }
}
