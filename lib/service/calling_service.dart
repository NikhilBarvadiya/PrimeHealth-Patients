import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prime_health_patients/models/calling_model.dart';
import 'package:prime_health_patients/service/calling_init_method.dart';
import 'package:prime_health_patients/service/firebase_service.dart';

String? lastHandledMessageId;

class CallingService {
  static final CallingService _instance = CallingService._internal();
  factory CallingService() => _instance;

  CallingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Function(CallData)? onIncomingCall;
  Function(String)? onCallAccepted, onCallRejected, onCallEnded;

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true, provisional: false);
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    await _initializeLocalNotifications();
  }

  Future<String?> getToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
      if (Platform.isIOS) {
        return await FirebaseMessaging.instance.getAPNSToken();
      } else {
        return await FirebaseMessaging.instance.getToken();
      }
    } catch (err) {
      return null;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          if (data['type'] == CallStatus.calling.name) {
            final callData = CallData.fromJson(data);
            CallingInitMethod().showIncomingCallDialog(callData);
          }
        }
      },
    );
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });
    terminatedNotification();
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    _handleMessage(message);
  }

  void terminatedNotification() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  Future<void> _handleMessage(RemoteMessage? message) async {
    if (message != null && message.messageId != null && message.messageId != lastHandledMessageId) {
      lastHandledMessageId = message.messageId;
      final data = message.data;
      if (data.containsKey('status')) {
        var type = data['status'];
        switch (type) {
          case 'calling':
            final callData = CallData(
              senderId: data['senderId'] ?? '',
              senderName: data['senderName'] ?? '',
              senderFCMToken: data['senderFCMToken'] ?? '',
              callType: data['callType'] == "voice" ? CallType.voice : CallType.video,
              status: CallStatus.calling,
              channelName: data['channelName'] ?? '',
            );
            onIncomingCall?.call(callData);
            _showIncomingCallNotification(callData);
            break;
          case 'accepted':
            onCallAccepted?.call(data['senderName'] ?? '');
            break;
          case 'rejected':
            onCallRejected?.call(data['senderName'] ?? '');
            _showLocalNotification(title: 'Call Rejected', body: '${data['senderName']} rejected the call', payload: jsonEncode(data));
            break;
          case 'ended':
            onCallEnded?.call(data['senderName'] ?? '');
            _showLocalNotification(title: 'Call Ended', body: '${data['senderName']} ended the call', payload: jsonEncode(data));
            break;
          default:
            return;
        }
      }
    }
  }

  Future<void> _showLocalNotification({int? id, required String title, required String body, required String payload}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'call_channel',
      'Call Notifications',
      channelDescription: 'Notifications for call status updates',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.call,
    );
    const DarwinNotificationDetails iosPlatformChannelSpecifics = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iosPlatformChannelSpecifics);
    await _localNotifications.show(id ?? DateTime.now().millisecondsSinceEpoch % 100000, title, body, platformChannelSpecifics, payload: payload);
  }

  Future<void> _showIncomingCallNotification(CallData callData) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'call_channel',
      'Call Notifications',
      channelDescription: 'Notifications for incoming calls',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      autoCancel: false,
      ongoing: true,
    );
    const DarwinNotificationDetails iosPlatformChannelSpecifics = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iosPlatformChannelSpecifics);
    await _localNotifications.show(
      callData.senderId.hashCode,
      'Incoming ${callData.callType == CallType.video ? 'Video' : 'Voice'} Call',
      'From ${callData.senderName}',
      platformChannelSpecifics,
      payload: jsonEncode(callData.toJson()),
    );
  }

  closeNotification(int senderId) => _localNotifications.cancel(senderId);

  Future<void> sendNotification(String receiverToken, CallData callData) async {
    final body = {
      "message": {
        "token": receiverToken,
        "notification": {"title": "Incoming ${callData.callType == CallType.video ? 'Video' : 'Voice'} Call", "body": "From ${callData.senderName}"},
        "data": {
          "senderId": callData.senderId,
          "senderName": callData.senderName,
          "senderFCMToken": callData.senderFCMToken,
          "channelName": callData.channelName,
          "callType": callData.callType.name,
          "status": callData.status.name,
        },
      },
    };
    await firebaseService.sendNotification(body);
  }

  Future<void> makeCall(String receiverToken, CallData callData) async => await sendNotification(receiverToken, callData);
}
