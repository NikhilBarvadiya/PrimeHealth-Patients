import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:prime_health_patients/service/calling_service.dart';
import 'package:prime_health_patients/utils/config/session.dart';
import 'package:prime_health_patients/utils/routes/route_name.dart';
import 'package:prime_health_patients/utils/storage.dart';
import 'package:prime_health_patients/utils/toaster.dart';

class RegisterCtrl extends GetxController {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  var isLoading = false.obs, isPasswordVisible = false.obs, isGettingLocation = false.obs;
  var coordinates = '["0.0", "0.0"]'.obs, locationStatus = 'Fetching location...'.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  @override
  void onInit() {
    super.onInit();
    _fetchCurrentLocation();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    mobileCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    addressCtrl.dispose();
    super.onClose();
  }

  Future<void> _fetchCurrentLocation() async {
    isGettingLocation.value = true;
    locationStatus.value = 'Checking location permissions...';

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationStatus.value = 'Location services disabled';
        toaster.warning('Please enable location services for better experience');
        isGettingLocation.value = false;
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        locationStatus.value = 'Requesting location permission...';
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationStatus.value = 'Location permission denied';
          toaster.warning('Location permission is required for better service');
          isGettingLocation.value = false;
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        locationStatus.value = 'Location permission permanently denied';
        toaster.warning('Please enable location permissions in app settings');
        isGettingLocation.value = false;
        return;
      }
      locationStatus.value = 'Getting your location...';
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 15));
      coordinates.value = '["${position.latitude}", "${position.longitude}"]';
      locationStatus.value = 'Location fetched successfully!';
    } catch (e) {
      locationStatus.value = 'Failed to get location';
      toaster.error('Location error: ${e.toString()}');
    } finally {
      isGettingLocation.value = false;
    }
  }

  Future<void> retryLocation() async {
    await _fetchCurrentLocation();
  }

  Future<void> register() async {
    if (!_validateForm()) return;
    isLoading.value = true;
    try {
      String? getToken = await CallingService().getToken();
      final request = {
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
        'mobile': mobileCtrl.text.trim(),
        'city': cityCtrl.text.trim(),
        'state': stateCtrl.text.trim(),
        'coordinates': coordinates.value,
        'address': addressCtrl.text.trim(),
        'fcmToken': getToken ?? "",
        'createdAt': DateTime.now().toIso8601String(),
      };
      await Future.delayed(const Duration(seconds: 2));
      await write(AppSession.token, 'patient_token_${DateTime.now().millisecondsSinceEpoch}');
      await write(AppSession.userData, request);
      toaster.success("Welcome to HealSync! Your account has been created successfully.");
      _clearForm();
      Get.offAllNamed(AppRouteNames.dashboard);
    } catch (e) {
      toaster.error("Registration failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (nameCtrl.text.isEmpty) {
      toaster.warning('Please enter your full name');
      return false;
    }
    if (emailCtrl.text.isEmpty) {
      toaster.warning('Please enter your email');
      return false;
    }
    if (!GetUtils.isEmail(emailCtrl.text)) {
      toaster.warning('Please enter a valid email address');
      return false;
    }
    if (passwordCtrl.text.isEmpty) {
      toaster.warning('Please enter your password');
      return false;
    }
    if (passwordCtrl.text.length < 6) {
      toaster.warning('Password must be at least 6 characters long');
      return false;
    }
    if (mobileCtrl.text.isEmpty) {
      toaster.warning('Please enter your mobile number');
      return false;
    }
    if (!GetUtils.isPhoneNumber(mobileCtrl.text) || mobileCtrl.text.length != 10) {
      toaster.warning('Please enter a valid 10-digit mobile number');
      return false;
    }
    if (cityCtrl.text.isEmpty) {
      toaster.warning('Please enter your city');
      return false;
    }
    if (stateCtrl.text.isEmpty) {
      toaster.warning('Please enter your state');
      return false;
    }
    if (addressCtrl.text.isEmpty) {
      toaster.warning('Please enter your address');
      return false;
    }
    return true;
  }

  void _clearForm() {
    nameCtrl.clear();
    emailCtrl.clear();
    passwordCtrl.clear();
    mobileCtrl.clear();
    cityCtrl.clear();
    stateCtrl.clear();
    addressCtrl.clear();
  }

  void goToLogin() => Get.toNamed(AppRouteNames.login);
}
