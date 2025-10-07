import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> requestAllPermissions() async {
    final cameraStatus = await requestCameraPermission();
    final micStatus = await requestMicrophonePermission();
    return cameraStatus && micStatus;
  }
}