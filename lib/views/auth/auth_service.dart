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
      if (response.data != null && response.data!['token'] != null) {
        await write(AppSession.token, response.data!["token"]);
        await write(AppSession.userData, response.data!["patient"]);
        Get.offAllNamed(AppRouteNames.dashboard);
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
          Get.offAllNamed(AppRouteNames.dashboard);
        }
        toaster.success('OTP verified successfully');
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

  Future<Map<String, dynamic>?> getCategories() async {
    try {
      final response = await ApiManager().call(APIIndex.getCategories, {}, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to load categories');
        return null;
      }
    } catch (err) {
      toaster.error('Categories loading failed: ${err.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getServices(dynamic request) async {
    try {
      final response = await ApiManager().call(APIIndex.getServices, request, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to load services');
        return null;
      }
    } catch (err) {
      toaster.error('Services loading failed: ${err.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPopularDoctors(dynamic request) async {
    try {
      final response = await ApiManager().call(APIIndex.getPopularDoctors, request, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to load doctors');
        return null;
      }
    } catch (err) {
      toaster.error('Doctors loading failed: ${err.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> searchDoctors(dynamic request) async {
    try {
      final response = await ApiManager().call(APIIndex.searchDoctors, request, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to load doctors');
        return null;
      }
    } catch (err) {
      toaster.error('Doctors loading failed: ${err.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDoctorDetails(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.getDoctorDetails, request, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to load doctor details');
        return null;
      }
    } catch (err) {
      toaster.error('Doctor details loading failed: ${err.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDoctorSlots(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.getDoctorSlots, request, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to load doctor slots');
        return null;
      }
    } catch (err) {
      toaster.error('Doctor slots loading failed: ${err.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDoctorReviews(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.getDoctorReviews, request, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to load doctor reviews');
        return null;
      }
    } catch (err) {
      toaster.error('Doctor reviews loading failed: ${err.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> bookAppointment(Map<String, dynamic> bookingData) async {
    try {
      final response = await ApiManager().call(APIIndex.bookAppointment, bookingData, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to book doctor appointment');
        return null;
      }
    } catch (error) {
      toaster.error('Book appointment error: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getServiceDoctors(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.getServiceDoctors, request, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to get services & doctors');
        return null;
      }
    } catch (error) {
      toaster.error('Get services & doctors error: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUpcomingAppointments(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.getUpcomingAppointments, request, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to load upcoming appointments');
        return null;
      }
    } catch (err) {
      toaster.error('Upcoming appointments loading failed: ${err.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBookingDetails(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.getBookingDetails, request, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to load booking details');
        return null;
      }
    } catch (err) {
      toaster.error('Booking details loading failed: ${err.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> rescheduleAppointment(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.rescheduleAppointment, request, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to reschedule appointment');
        return null;
      }
    } catch (err) {
      toaster.error('Reschedule failed: ${err.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> cancelAppointment(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.cancelAppointment, request, ApiType.post);
      if (response.status == 200 && response.data != null) {
        return response.data;
      } else {
        toaster.warning(response.message ?? 'Failed to cancel appointment');
        return null;
      }
    } catch (err) {
      toaster.error('Cancel failed: ${err.toString()}');
      return null;
    }
  }
}
