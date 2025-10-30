import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      final loginRequest = {'mobileNo': mobileCtrl.text.trim()};
      final loginResponse = await authService.login(loginRequest);
      if (loginResponse != null && loginResponse['patientId'] != null) {
        Get.toNamed(AppRouteNames.verifyOtp, arguments: {'mobileNo': mobileCtrl.text.trim(), 'patientId': loginResponse['patientId']});
      }
    } catch (err) {
      toaster.error('Login error: ${err.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() => Get.toNamed(AppRouteNames.register);
}
