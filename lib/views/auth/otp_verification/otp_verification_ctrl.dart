import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_health_patients/utils/routes/route_name.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';

class OtpVerificationCtrl extends GetxController {
  final String mobileNo;
  final String patientId;

  final List<TextEditingController> otpControllers = List.generate(4, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());
  var isLoading = false.obs, canResend = false.obs;
  int timerSeconds = 60;
  Timer? _timer;

  OtpVerificationCtrl({required this.mobileNo, required this.patientId});

  AuthService get authService => Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    canResend.value = false;
    timerSeconds = 60;
    update();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds > 0) {
        timerSeconds--;
        update();
      } else {
        canResend.value = true;
        timer.cancel();
        update();
      }
    });
  }

  void onOtpChanged(String value, int index) {
    if (value.length == 1 && RegExp(r'^\d$').hasMatch(value)) {
      if (index < 3) {
        FocusScope.of(Get.context!).requestFocus(focusNodes[index + 1]);
      } else {
        FocusScope.of(Get.context!).unfocus();
        verifyOtp();
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(Get.context!).requestFocus(focusNodes[index - 1]);
    }
  }

  String getOtpCode() {
    return otpControllers.map((controller) => controller.text).join();
  }

  Future<void> verifyOtp() async {
    final otpCode = getOtpCode();
    if (otpCode.length != 4) {
      return toaster.warning('Please enter complete OTP code');
    }
    isLoading.value = true;
    try {
      final request = {'mobileNo': mobileNo, 'otpCode': otpCode, 'patientId': patientId};
      final success = await authService.verifyOTP(request);
      if (success) {
        toaster.success('Login successful!');
        Get.offAllNamed(AppRouteNames.dashboard);
      }
    } catch (err) {
      toaster.error('Verification failed: ${err.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    try {
      final request = {'mobileNo': mobileNo, 'patientId': patientId};
      final otpSent = await authService.sendOTP(request);
      if (otpSent) {
        toaster.success('OTP sent successfully');
        for (var controller in otpControllers) {
          controller.dispose();
        }
        _startTimer();
      }
    } catch (err) {
      toaster.error('Failed to resend OTP: ${err.toString()}');
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.onClose();
  }
}
