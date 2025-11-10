import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prime_health_patients/models/appointment_model.dart';
import 'package:prime_health_patients/models/calling_model.dart';
import 'package:prime_health_patients/service/calling_init_method.dart';
import 'package:prime_health_patients/utils/config/session.dart';
import 'package:prime_health_patients/utils/network/api_index.dart';
import 'package:prime_health_patients/utils/network/api_manager.dart';
import 'package:prime_health_patients/utils/storage.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:vibration/vibration.dart';

String? lastHandledMessageId;

class CallingService {
  static final CallingService _instance = CallingService._internal();

  factory CallingService() => _instance;

  CallingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Function(CallData)? onIncomingCall;
  Function(String)? onCallAccepted, onCallRejected, onCallEnded;
  AudioPlayer player = AudioPlayer();

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true, provisional: false);
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    await _initializeLocalNotifications();
  }

  _whistle(String sound) async {
    Vibration.vibrate(pattern: [150, 200, 300, 200, 150]);
    await player.setSource(AssetSource(sound)).then((value) {
      player.play(AssetSource(sound));
    });
    player.onPlayerStateChanged.listen((PlayerState s) async {
      if (s == PlayerState.completed) {
        await player.play(AssetSource(sound));
      }
    });
  }

  Future<String?> getToken() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          final result = await Permission.notification.request();
          if (!result.isGranted) {
            return null;
          }
        }
      }
      final token = await FirebaseMessaging.instance.getToken();
      return token;
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
          case '0':
            /* calling */
            final callData = CallData(
              senderId: data['senderId'] ?? '',
              senderName: data['senderName'] ?? '',
              senderFCMToken: data['senderFCMToken'] ?? '',
              callType: data['callType'] == "0" ? CallType.voice : CallType.video,
              status: CallStatus.calling,
              channelName: data['channelName'] ?? '',
            );
            _whistle("ringtone.mp3");
            onIncomingCall?.call(callData);
            _showIncomingCallNotification(callData);
            break;
          case '1':
            /* accepted */
            onCallAccepted?.call(data['senderName'] ?? '');
            break;
          case '2':
            /* rejected */
            onCallRejected?.call(data['senderName'] ?? '');
            _showLocalNotification(title: 'Call Rejected', body: '${data['senderName']} rejected the call', payload: jsonEncode(data));
            break;
          case '3':
            /* ended */
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

  Future<void> sendNotification(AppointmentModel receiver, CallData callData) async {
    final userData = await read(AppSession.userData);
    if (userData != null) {
      final callReq = {
        "channelName": callData.channelName,
        "senderId": callData.senderId,
        "senderName": callData.senderName,
        "senderFCMToken": callData.senderFCMToken,
        "receiverId": receiver.id,
        "receiverName": receiver.doctorName,
        "receiverFCMToken": receiver.fcmToken,
        "callType": callData.callType == CallType.video ? 'video' : 'voice',
        "status": callData.status.name,
        "startTime": callData.startTime,
        "endTime": callData.endTime,
        "duration": callData.duration,
      };
      await ApiManager().call(APIIndex.createCallLog, callReq, ApiType.post);
    }
    final body = {"receiverToken": receiver.fcmToken, "callData": callData.toJson()};
    try {
      final response = await ApiManager().call(APIIndex.sendNotification, body, ApiType.post);
      if (response.status != 200 || response.data == null) {
        toaster.warning(response.message ?? 'Failed to send notification');
      }
    } catch (err) {
      toaster.error('Notification send failed: ${err.toString()}');
    }
  }

  Future<void> makeCall(AppointmentModel receiver, CallData callData) async => await sendNotification(receiver, callData);
}
