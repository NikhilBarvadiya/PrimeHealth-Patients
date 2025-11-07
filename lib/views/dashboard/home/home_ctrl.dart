import 'package:get/get.dart';
import 'package:prime_health_patients/models/patient_request_model.dart';
import 'package:prime_health_patients/models/popular_doctor_model.dart';
import 'package:prime_health_patients/models/service_model.dart';
import 'package:prime_health_patients/utils/config/session.dart';
import 'package:prime_health_patients/utils/storage.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/appointment_details.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/booking.dart';
import 'package:prime_health_patients/views/dashboard/dashboard_ctrl.dart';
import 'package:prime_health_patients/views/dashboard/doctors/doctor_details/doctor_details.dart';
import 'package:prime_health_patients/views/dashboard/services/ui/service_details.dart';

class HomeCtrl extends GetxController {
  var userName = ''.obs;
  var isLoading = false.obs;

  var featuredDoctors = <PopularDoctorModel>[].obs;
  var pendingAppointments = <PatientRequestModel>[].obs;
  var regularServices = <ServiceModel>[].obs;

  AuthService get authService => Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    getAPICalling();
  }

  getAPICalling() async {
    await loadServices();
    await loadPopularDoctors();
    await loadAppointments();
  }

  Future<void> loadUserData() async {
    final userData = await read(AppSession.userData);
    if (userData != null) {
      userName.value = userData['name'] ?? 'Patient';
    }
  }

  Future<void> loadServices() async {
    try {
      isLoading.value = true;
      final servicesData = await authService.getServices({"page": 1, "limit": 10});
      if (servicesData != null && servicesData['docs'] != null) {
        final List<dynamic> data = servicesData['docs'];
        regularServices.assignAll(data.map((item) => ServiceModel.fromApi(item)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load services: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPopularDoctors() async {
    try {
      isLoading.value = true;
      final doctorsData = await authService.getPopularDoctors({"page": 1, "limit": 10, "isAvailable": true});
      if (doctorsData != null && doctorsData['doctors'] != null) {
        final List<dynamic> data = doctorsData['doctors'];
        featuredDoctors.assignAll(data.map((item) => PopularDoctorModel.fromJson(item["doctor"])).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load doctors: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAppointments() async {
    try {
      // TODO: Add appointments API call when available
      // For now, keeping empty as per requirement to remove mock data
      pendingAppointments.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load appointments: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void viewAllServices() {
    DashboardCtrl ctrl = Get.put(DashboardCtrl());
    ctrl.changeTab(1);
  }

  void viewAllAppointments() {
    DashboardCtrl ctrl = Get.put(DashboardCtrl());
    ctrl.changeTab(2);
  }

  void viewAppointmentDetails(String appointmentId) {
    Get.to(() => AppointmentDetails(appointmentId: appointmentId));
  }

  void bookDetails(ServiceModel service) {
    Get.to(() => ServiceDetails(service: service));
  }

  void bookService(ServiceModel service) {
    Get.to(() => Booking(serviceId: service.id));
  }

  void viewDoctorProfile(PopularDoctorModel doctor) {
    Get.to(() => DoctorDetails(doctorId: doctor.id));
  }
}
