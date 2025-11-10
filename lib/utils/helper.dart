import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prime_health_patients/utils/network/api_config.dart';
import 'package:prime_health_patients/utils/toaster.dart';

class Helper {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({ImageSource? source}) async {
    try {
      final XFile? file = await _picker.pickImage(source: source ?? ImageSource.camera);
      if (file != null) {
        return File(file.path);
      }
      return null;
    } catch (err) {
      toaster.error("Error while clicking image!");
      return null;
    }
  }

  Future<String> getDeviceUniqueId() async {
    String deviceIdentifier = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceIdentifier = androidInfo.id;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceIdentifier = iosInfo.identifierForVendor!;
    }
    return deviceIdentifier;
  }

  getAWSImage(String url) {
    if (url.startsWith('/')) {
      url = url.substring(1);
    }
    return APIConfig.imageBaseURL + url;
  }
}

Helper helper = Helper();
