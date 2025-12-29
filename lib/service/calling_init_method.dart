import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_health_patients/models/appointment_model.dart';
import 'package:prime_health_patients/models/calling_model.dart';
import 'package:prime_health_patients/models/user_model.dart';
import 'package:prime_health_patients/service/calling_service.dart';
import 'package:prime_health_patients/service/permission_service.dart';
import 'package:prime_health_patients/utils/config/session.dart';
import 'package:prime_health_patients/utils/storage.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/calling_view.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/incoming_call_dialog.dart';

class CallingInitMethod {
  static final CallingInitMethod _instance = CallingInitMethod._internal();

  factory CallingInitMethod() => _instance;

  CallingInitMethod._internal();

  CallData? _incomingCall;
  bool _isCallingViewOpen = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get context => navigatorKey.currentContext;

  Future<void> initData() async {
    final hasPermissions = await PermissionService.requestAllPermissions();
    if (!hasPermissions && context != null && context!.mounted) {
      ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(content: Text('Camera and microphone permissions required')));
    }
    await CallingService().initialize();
    _setupFCMListeners();
  }

  void _setupFCMListeners() {
    CallingService().onIncomingCall = (callData) {
      _incomingCall = callData;
      showIncomingCallDialog(callData);
    };

    CallingService().onCallAccepted = (channelName) {
      if (_isCallingViewOpen) Get.close(1);
      _navigateToCalling(
        channelName,
        _incomingCall?.callType ?? CallType.video,
        AppointmentModel(id: _incomingCall?.senderId ?? "", doctorName: _incomingCall?.senderName ?? "", fcmToken: _incomingCall?.senderFCMToken ?? ""),
      );
    };

    CallingService().onCallRejected = (callId) {
      if (_isCallingViewOpen) {
        Get.close(1);
      } else {
        BuildContext? context = navigatorKey.currentContext;
        if (context != null) {
          Navigator.pop(context);
        }
      }
      _incomingCall = null;
      if (context != null) {
        ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(content: Text('Call was rejected')));
      }
    };

    CallingService().onCallEnded = (senderName) {
      if (_isCallingViewOpen) Get.close(1);
      _incomingCall = null;
      if (context != null) {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(content: Text('$senderName ended the call')));
      }
    };
  }

  void showIncomingCallDialog(CallData callData) {
    if (context == null) return;
    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (context) {
        return IncomingCallDialog(
          callData: callData,
          onAccept: () {
            Get.close(1);
            _navigateToCalling(callData.channelName, callData.callType, AppointmentModel(id: callData.senderId, doctorName: callData.senderName, fcmToken: callData.senderFCMToken));
          },
          onReject: () async {
            CallingService().closeNotification(callData.senderId.hashCode);
            final userData = await read(AppSession.userData);
            if (userData != null) {
              UserModel userModel = UserModel(
                id: userData["_id"] ?? "",
                fcm: userData["fcm"] ?? "",
                name: userData["name"] ?? 'Dr. John Smith',
                email: userData["email"] ?? 'john.smith@example.com',
                mobileNo: userData["mobile"] ?? '+91 98765 43210',
                address: {},
              );
              CallingService().makeCall(
                AppointmentModel(id: callData.senderId, doctorName: callData.senderName, fcmToken: callData.senderFCMToken),
                CallData(
                  senderId: userModel.id,
                  senderName: userModel.name,
                  senderFCMToken: userModel.fcm,
                  callType: callData.callType,
                  status: CallStatus.rejected,
                  channelName: callData.channelName,
                ),
              );
            }
            Get.close(1);
            _incomingCall = null;
            _isCallingViewOpen = false;
          },
        );
      },
    );
  }

  Future<void> _navigateToCalling(String channelName, CallType callType, AppointmentModel receiver) async {
    _isCallingViewOpen = true;
    final userData = await read(AppSession.userData);
    if (userData == null) return;
    UserModel userModel = UserModel(
      id: userData["_id"] ?? "",
      fcm: userData["fcm"] ?? "",
      name: userData["name"] ?? 'Dr. John Smith',
      email: userData["email"] ?? 'john.smith@example.com',
      mobileNo: userData["mobile"] ?? '+91 98765 43210',
      address: {},
    );
    if (context != null && context!.mounted) {
      await Navigator.of(context!).push(
        MaterialPageRoute(
          builder: (context) {
            return CallingView(channelName: channelName, callType: callType, receiver: receiver, sender: userModel);
          },
        ),
      );
      _isCallingViewOpen = false;
    }
  }
}
