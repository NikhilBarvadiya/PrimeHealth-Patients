import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prime_health_patients/models/doctor_model.dart';
import 'package:prime_health_patients/models/slot_model.dart';
import 'package:prime_health_patients/models/review_model.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/booking.dart';

class DoctorDetailsCtrl extends GetxController {
  var isLoading = true.obs;
  var doctor = DoctorModel(
    id: '',
    fcm: '',
    name: '',
    email: '',
    mobileNo: '',
    license: '',
    specialty: '',
    bio: '',
    consultationFee: 0.0,
    experience: 0,
    isActive: true,
    isDeleted: false,
    services: [],
    certifications: [],
  ).obs;

  var availableSlots = <SlotModel>[].obs;
  var reviews = <ReviewModel>[].obs;
  var selectedTab = 0.obs, totalReviews = 0.obs;
  var averageRating = 0.0.obs;

  final AuthService _authService = Get.find<AuthService>();

  Future<void> loadDoctorDetails(String doctorId) async {
    try {
      isLoading.value = true;
      final request = {'doctorId': doctorId};
      final response = await _authService.getDoctorDetails(request);
      if (response != null && response['doctor'] != null) {
        doctor.value = DoctorModel.fromJson(response['doctor']);
        await Future.wait([loadDoctorSlots(doctorId), loadDoctorReviews(doctorId)]);
      }
    } catch (error) {
      toaster.error('Error loading doctor details: $error');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDoctorSlots(String doctorId) async {
    try {
      final request = {'doctorId': doctorId, 'date': DateTime.now().toIso8601String().split('T')[0]};
      final response = await _authService.getDoctorSlots(request);
      if (response != null && response['slots'] != null && response['slots'] != []) {
        final slotsList = List<Map<String, dynamic>>.from(response['slots']).map((slotData) => SlotModel.fromJson(slotData)).toList();
        availableSlots.assignAll(slotsList);
      }
    } catch (error) {
      toaster.error('Error loading doctor slots: $error');
    }
  }

  Future<void> loadDoctorReviews(String doctorId) async {
    try {
      final request = {'doctorId': doctorId, 'page': 1, 'limit': 10};
      final response = await _authService.getDoctorReviews(request);
      if (response != null) {
        if (response['reviews'] != null && response['reviews']['docs'] != null && response['reviews']['docs'] != []) {
          final reviewsList = List<Map<String, dynamic>>.from(response['reviews']['docs']).map((reviewData) => ReviewModel.fromJson(reviewData)).toList();
          reviews.assignAll(reviewsList);
        }
        averageRating.value = double.tryParse(response['averageRating'] ?? 0.0) ?? 0.0;
        totalReviews.value = int.tryParse(response['totalReviews'] ?? 0) ?? 0;
      }
    } catch (error) {
      toaster.error('Error loading doctor reviews: $error');
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  String formatTimeSlot(DateTime startTime, DateTime endTime) {
    final startFormat = DateFormat('hh:mm a');
    final endFormat = DateFormat('hh:mm a');
    return '${startFormat.format(startTime)} - ${endFormat.format(endTime)}';
  }

  void bookService() {
    if (doctor.value.id.isNotEmpty) {
      Get.to(() => Booking(doctor: doctor.value));
    }
  }
}
