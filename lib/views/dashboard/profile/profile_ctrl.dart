import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_health_patients/models/user_model.dart';
import 'package:prime_health_patients/utils/config/session.dart';
import 'package:prime_health_patients/utils/helper.dart';
import 'package:prime_health_patients/utils/storage.dart';
import 'package:prime_health_patients/utils/toaster.dart';

class ProfileCtrl extends GetxController {
  var user = UserModel(
    id: '1',
    name: 'Patient Name',
    email: 'patient@example.com',
    mobile: '+91 98765 43210',
    password: '********',
    address: '123, Patient Address, City, State, 395009',
    city: 'Surat',
    state: 'Gujarat',
    fcmToken: '',
  ).obs;
  bool isEditMode = false;
  var avatar = Rx<File?>(null);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  @override
  void onInit() {
    _loadUserData();
    super.onInit();
  }

  Future<void> _loadUserData() async {
    final userData = await read(AppSession.userData);
    if (userData != null) {
      user.value = UserModel(
        id: "1",
        name: userData["name"] ?? 'Patient Name',
        email: userData["email"] ?? 'patient@example.com',
        mobile: userData["mobile"] ?? '+91 98765 43210',
        password: userData["password"] ?? '********',
        address: userData["address"] ?? '123, Patient Address, City, State, 395009',
        city: userData["city"] ?? 'Surat',
        state: userData["state"] ?? 'Gujarat',
        fcmToken: userData["fcmToken"] ?? '',
      );
    }
    nameController.text = user.value.name;
    emailController.text = user.value.email;
    mobileController.text = user.value.mobile;
    cityController.text = user.value.city;
    stateController.text = user.value.state;
    addressController.text = user.value.address;
  }

  void toggleEditMode() {
    isEditMode = !isEditMode;
    if (!isEditMode) {
      _loadUserData();
    }
    update();
  }

  Future<void> pickAvatar() async {
    final result = await helper.pickImage();
    if (result != null) {
      avatar.value = result;
      update();
    }
  }

  void saveProfile() {
    if (_validateForm()) {
      updateProfile(name: nameController.text, email: emailController.text, mobile: mobileController.text, city: cityController.text, state: stateController.text, address: addressController.text);
      isEditMode = false;
      update();
      toaster.success('Profile updated successfully');
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
    if (mobileController.text.isEmpty) {
      toaster.warning('Please enter your mobile number');
      return false;
    }
    if (!GetUtils.isPhoneNumber(mobileController.text)) {
      toaster.warning('Please enter a valid mobile number');
      return false;
    }
    if (addressController.text.isEmpty) {
      toaster.warning('Please enter your address');
      return false;
    }
    return true;
  }

  void updateProfile({required String name, required String email, required String mobile, required String city, required String state, required String address}) async {
    try {
      user.value = UserModel(id: user.value.id, name: name, email: email, mobile: mobile, password: user.value.password, city: city, state: state, address: address, fcmToken: user.value.fcmToken);
      final request = {'name': name, 'email': email, 'password': user.value.password, 'mobile': mobile, 'city': city, 'state': state, 'address': address};
      await write(AppSession.userData, request);
      update();
    } catch (e) {
      toaster.error('Failed to update profile: $e');
    }
  }

  void logout() async {
    try {
      await clearStorage();
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void deleteAccount() async {
    try {
      await clearStorage();
      user.value = UserModel(id: '', name: '', email: '', mobile: '', password: '', address: '', city: '', state: '', fcmToken: '');
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
