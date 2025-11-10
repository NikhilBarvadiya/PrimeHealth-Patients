import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:prime_health_patients/models/user_model.dart';
import 'package:prime_health_patients/utils/config/session.dart';
import 'package:prime_health_patients/utils/helper.dart';
import 'package:prime_health_patients/utils/routes/route_name.dart';
import 'package:prime_health_patients/utils/storage.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';
import 'package:prime_health_patients/views/dashboard/home/home_ctrl.dart';

class ProfileCtrl extends GetxController {
  var user = UserModel(id: '', fcm: '', name: '', email: '', mobileNo: '').obs;
  var isLoading = false.obs;
  bool isEditMode = false;
  var avatar = Rx<File?>(null);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyMobileController = TextEditingController();

  AuthService get authService => Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    countryController.dispose();
    cityController.dispose();
    stateController.dispose();
    dateOfBirthController.dispose();
    bloodGroupController.dispose();
    emergencyNameController.dispose();
    emergencyMobileController.dispose();
    super.onClose();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final patientData = await authService.getProfile();
      if (patientData != null && patientData['patient'] != null) {
        user.value = UserModel.fromJson(patientData['patient']);
        await write(AppSession.userData, patientData['patient']);
        _updateControllers();
      } else {
        _loadFromLocalStorage();
      }
    } catch (e) {
      _loadFromLocalStorage();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadFromLocalStorage() async {
    final userData = await read(AppSession.userData);
    if (userData != null) {
      user.value = UserModel.fromJson(userData);
      _updateControllers();
    }
  }

  void _updateControllers() {
    nameController.text = user.value.name;
    emailController.text = user.value.email;
    cityController.text = user.value.city;
    stateController.text = user.value.state;
    countryController.text = user.value.country;
    dateOfBirthController.text = user.value.dateOfBirth ?? '';
    bloodGroupController.text = user.value.bloodGroup ?? '';
    emergencyNameController.text = user.value.emergencyName;
    emergencyMobileController.text = user.value.emergencyMobile;
    update();
  }

  void toggleEditMode() {
    isEditMode = !isEditMode;
    update();
  }

  Future<void> pickAvatar() async {
    final result = await helper.pickImage();
    if (result != null) {
      avatar.value = result;
      final formData = dio.FormData.fromMap({});
      formData.files.add(MapEntry('profileImage', await dio.MultipartFile.fromFile(avatar.value!.path, filename: 'profileImage.jpg')));
      final success = await authService.updateProfile(formData);
      if (success) {
        await loadUserData();
        final homeCtrl = Get.find<HomeCtrl>();
        homeCtrl.loadUserData();
        toaster.success('Profile updated successfully');
      }
      update();
    }
  }

  Future<void> saveProfile() async {
    if (!_validateForm()) return;
    try {
      isLoading.value = true;
      final request = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "dateOfBirth": dateOfBirthController.text.trim(),
        "gender": user.value.gender,
        "bloodGroup": bloodGroupController.text.trim(),
        "address": {"city": cityController.text.trim(), "state": stateController.text.trim(), "country": countryController.text.trim()},
        "emergencyContact": {"name": emergencyNameController.text.trim(), "mobileNo": emergencyMobileController.text.trim()},
        "allergies": user.value.allergies ?? [],
      };
      final success = await authService.updateProfile(request);
      if (success) {
        await loadUserData();
        isEditMode = false;
        update();
        final homeCtrl = Get.find<HomeCtrl>();
        homeCtrl.loadUserData();
        toaster.success('Profile updated successfully');
      }
    } catch (e) {
      toaster.error('Failed to update profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (nameController.text.isEmpty) {
      toaster.warning('Please enter your full name');
      return false;
    }
    if (emailController.text.isEmpty) {
      toaster.warning('Please enter your email');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text)) {
      toaster.warning('Please enter a valid email');
      return false;
    }
    if (cityController.text.isEmpty) {
      toaster.warning('Please enter your city');
      return false;
    }
    if (stateController.text.isEmpty) {
      toaster.warning('Please enter your state');
      return false;
    }
    if (countryController.text.isEmpty) {
      toaster.warning('Please enter your country');
      return false;
    }
    return true;
  }

  Future<void> logout() async {
    try {
      await clearStorage();
      Get.offAllNamed(AppRouteNames.login);
    } catch (e) {
      toaster.error('Failed to logout: ${e.toString()}');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await clearStorage();
      Get.offAllNamed(AppRouteNames.login);
    } catch (e) {
      toaster.error('Failed to logout: ${e.toString()}');
    }
  }
}
