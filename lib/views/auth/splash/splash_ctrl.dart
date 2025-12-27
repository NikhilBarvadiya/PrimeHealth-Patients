import 'package:get/get.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:prime_health_patients/utils/config/session.dart';
import 'package:prime_health_patients/utils/routes/route_name.dart';
import 'package:prime_health_patients/utils/storage.dart';

class SplashCtrl extends GetxController {
  @override
  void onInit() {
    super.onInit();
    verifyVersion();
  }

  void verifyVersion() async {
    try {
      NewVersionPlus newVersion = NewVersionPlus();
      final status = await newVersion.getVersionStatus();
      if (status != null && status.canUpdate) {
        newVersion.showUpdateDialog(
          context: Get.context!,
          versionStatus: status,
          dialogTitle: 'Update Available',
          dialogText: 'A new version of the app is available. Please update to continue.',
          updateButtonText: 'Update',
          allowDismissal: false,
        );
      } else {
        _navigateToHome();
      }
    } catch (e) {
      _navigateToHome();
    }
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    final token = await read(AppSession.token);
    if (token != null && token != "") {
      Get.offAllNamed(AppRouteNames.dashboard);
    } else {
      Get.offAllNamed(AppRouteNames.login);
    }
  }
}
