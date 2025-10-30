import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_health_patients/service/location_service.dart';
import 'package:prime_health_patients/utils/routes/route_name.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';

class RegisterCtrl extends GetxController {
  AuthService get authService => Get.find<AuthService>();

  LocationService get locationService => Get.find<LocationService>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final dateOfBirthCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final emergencyNameCtrl = TextEditingController();
  final emergencyMobileCtrl = TextEditingController();

  var isLoading = false.obs, isLocationLoading = false.obs;
  var selectedGender = 'male'.obs, selectedBloodGroup = 'O+'.obs;
  var selectedAllergies = <String>[].obs;
  var currentStep = 0.obs;

  final List<String> genderOptions = ['male', 'female', 'other'];
  final List<String> bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> commonAllergies = [
    'Peanuts',
    'Dust',
    'Pollen',
    'Shellfish',
    'Eggs',
    'Milk',
    'Soy',
    'Wheat',
    'Fish',
    'Tree Nuts',
    'Penicillin',
    'Sulfa Drugs',
    'Aspirin',
    'Insect Stings',
    'Latex',
  ];

  void setGender(String gender) => selectedGender.value = gender;

  void setBloodGroup(String bloodGroup) => selectedBloodGroup.value = bloodGroup;

  void toggleAllergy(String allergy) {
    if (selectedAllergies.contains(allergy)) {
      selectedAllergies.remove(allergy);
    } else {
      selectedAllergies.add(allergy);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      currentStep.value = step;
    }
  }

  void nextStep() {
    if (currentStep.value < 3) {
      if (_validateCurrentStep()) {
        currentStep.value++;
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  bool _validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
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
        if (mobileCtrl.text.isEmpty) {
          toaster.warning('Please enter your mobile number');
          return false;
        }
        if (!GetUtils.isPhoneNumber(mobileCtrl.text) || mobileCtrl.text.length != 10) {
          toaster.warning('Please enter a valid 10-digit mobile number');
          return false;
        }
        if (dateOfBirthCtrl.text.isEmpty) {
          toaster.warning('Please select your date of birth');
          return false;
        }
        return true;
      case 1:
        if (cityCtrl.text.isEmpty) {
          toaster.warning('Please enter your city');
          return false;
        }
        if (stateCtrl.text.isEmpty) {
          toaster.warning('Please enter your state');
          return false;
        }
        if (countryCtrl.text.isEmpty) {
          toaster.warning('Please enter your country');
          return false;
        }
        return true;
      case 2:
        if (emergencyNameCtrl.text.isEmpty) {
          toaster.warning('Please enter emergency contact name');
          return false;
        }
        if (emergencyMobileCtrl.text.isEmpty) {
          toaster.warning('Please enter emergency contact mobile number');
          return false;
        }
        if (!GetUtils.isPhoneNumber(emergencyMobileCtrl.text) || emergencyMobileCtrl.text.length != 10) {
          toaster.warning('Please enter a valid 10-digit emergency contact number');
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    mobileCtrl.dispose();
    dateOfBirthCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    countryCtrl.dispose();
    emergencyNameCtrl.dispose();
    emergencyMobileCtrl.dispose();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    try {
      isLocationLoading(true);
      final addressData = await locationService.getCurrentAddress();
      if (addressData != null) {
        countryCtrl.text = addressData['country'] ?? '';
        stateCtrl.text = addressData['state'] ?? '';
        cityCtrl.text = addressData['city'] ?? '';
        toaster.success('Location fetched successfully');
      }
    } catch (e) {
      toaster.error('Failed to fetch location: ${e.toString()}');
    } finally {
      isLocationLoading(false);
    }
  }

  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dateOfBirthCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> register() async {
    if (!_validateForm()) return;
    isLoading.value = true;
    try {
      final request = {
        "name": nameCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "mobileNo": mobileCtrl.text.trim(),
        "dateOfBirth": dateOfBirthCtrl.text.trim(),
        "gender": selectedGender.value,
        "address": {"country": countryCtrl.text.trim(), "city": cityCtrl.text.trim(), "state": stateCtrl.text.trim()},
        "emergencyContact": {"name": emergencyNameCtrl.text.trim(), "mobileNo": emergencyMobileCtrl.text.trim()},
        "bloodGroup": selectedBloodGroup.value,
        "allergies": selectedAllergies.toList(),
      };
      final success = await authService.register(request);
      if (success) {
        _clearForm();
        Get.back();
      }
    } catch (e) {
      toaster.error("Registration failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    return _validateCurrentStep();
  }

  void _clearForm() {
    nameCtrl.clear();
    emailCtrl.clear();
    mobileCtrl.clear();
    dateOfBirthCtrl.clear();
    countryCtrl.clear();
    cityCtrl.clear();
    stateCtrl.clear();
    emergencyNameCtrl.clear();
    emergencyMobileCtrl.clear();
    selectedAllergies.clear();
    selectedGender.value = 'male';
    selectedBloodGroup.value = 'O+';
    currentStep.value = 0;
  }

  void goToLogin() => Get.toNamed(AppRouteNames.login);
}
