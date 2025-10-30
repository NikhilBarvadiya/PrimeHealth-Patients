import 'package:get/get.dart';
import 'package:prime_health_patients/utils/config/session.dart';
import 'package:prime_health_patients/utils/network/api_index.dart';
import 'package:prime_health_patients/utils/network/api_manager.dart';
import 'package:prime_health_patients/utils/routes/route_name.dart';
import 'package:prime_health_patients/utils/storage.dart';
import 'package:prime_health_patients/utils/toaster.dart';

class AuthService extends GetxService {
  Future<AuthService> init() async => this;

  Future<bool> register(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.register, request, ApiType.post);
      if (response.status != 200) {
        toaster.warning(response.message ?? 'Registration failed');
        return false;
      }
      toaster.success(response.message ?? 'Registration successful!');
      return true;
    } catch (err) {
      toaster.error('Registration error: ${err.toString()}');
      return false;
    }
  }

  Future<Map<String, dynamic>?> login(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.login, request, ApiType.post);
      if (response.status != 200 || response.data == null) {
        toaster.warning(response.message ?? 'Failed to login');
        return null;
      }
      if (response.message == "OTP sent to your mobile number.") {
        return response.data;
      } else {
        await write(AppSession.token, response.data!["token"]);
        await write(AppSession.userData, response.data!["patient"]);
        Get.offAllNamed(AppRouteNames.dashboard);
      }
      return response.data;
    } catch (err) {
      toaster.error('Login error: ${err.toString()}');
      return null;
    }
  }

  Future<bool> sendOTP(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.sendOTP, request, ApiType.post);
      if (response.status == 200) {
        toaster.success('OTP sent successfully');
        return true;
      } else {
        toaster.warning(response.message ?? 'Failed to send OTP');
        return false;
      }
    } catch (err) {
      toaster.error('OTP sending failed: ${err.toString()}');
      return false;
    }
  }

  Future<bool> verifyOTP(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.verifyOTP, request, ApiType.post);
      if (response.status == 200 && response.data != null) {
        if (response.data?['token'] != null) {
          await write(AppSession.token, response.data!["token"]);
          await write(AppSession.userData, response.data!["patient"]);
        }
        return true;
      } else {
        toaster.warning(response.message ?? 'Invalid OTP');
        return false;
      }
    } catch (err) {
      toaster.error('Verification failed: ${err.toString()}');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await ApiManager().call(APIIndex.getProfile, {}, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to load profile');
        return null;
      }
    } catch (err) {
      toaster.error('Profile loading failed: ${err.toString()}');
      return null;
    }
  }

  Future<bool> updateProfile(dynamic request) async {
    try {
      final response = await ApiManager().call(APIIndex.updateProfile, request, ApiType.post);
      if (response.status == 200) {
        if (response.data != null) {
          await write(AppSession.userData, response.data);
        }
        toaster.success(response.message ?? 'Profile updated successfully');
        return true;
      } else {
        toaster.warning(response.message ?? 'Profile update failed');
        return false;
      }
    } catch (err) {
      toaster.error('Profile update failed: ${err.toString()}');
      return false;
    }
  }
}
