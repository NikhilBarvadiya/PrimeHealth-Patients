import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_health_patients/service/calling_service.dart';
import 'package:prime_health_patients/utils/routes/route_name.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';

class LoginCtrl extends GetxController {
  final mobileCtrl = TextEditingController();
  var isLoading = false.obs;

  AuthService get authService => Get.find<AuthService>();

  Future<void> login() async {
    if (mobileCtrl.text.isEmpty) {
      return toaster.warning('Please enter your mobile number');
    }
    if (!GetUtils.isPhoneNumber(mobileCtrl.text)) {
      return toaster.warning('Please enter a valid mobile number');
    }
    isLoading.value = true;
    try {
      String getToken = await CallingService().getToken() ?? "";
      final loginRequest = {'mobileNo': mobileCtrl.text.trim(), "fcm": getToken};
      final loginResponse = await authService.login(loginRequest);
      if (loginResponse != null && loginResponse['patient']?["id"] != null) {
        Get.toNamed(AppRouteNames.verifyOtp, arguments: {'mobileNo': mobileCtrl.text.trim(), 'patientId': loginResponse['patient']["id"]});
      }
    } catch (err) {
      toaster.error('Login error: ${err.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() => Get.toNamed(AppRouteNames.register);
}
