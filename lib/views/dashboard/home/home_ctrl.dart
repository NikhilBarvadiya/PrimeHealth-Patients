import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_health_patients/models/doctor_model.dart';
import 'package:prime_health_patients/models/patient_request_model.dart';
import 'package:prime_health_patients/models/service_model.dart';
import 'package:prime_health_patients/utils/config/session.dart';
import 'package:prime_health_patients/utils/storage.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/appointment_details.dart';
import 'package:prime_health_patients/views/dashboard/dashboard_ctrl.dart';
import 'package:prime_health_patients/views/dashboard/doctors/ui/doctor_details.dart';
import 'package:prime_health_patients/views/dashboard/services/ui/service_details.dart';
import 'package:prime_health_patients/views/dashboard/services/ui/slot_selection.dart';

class HomeCtrl extends GetxController {
  var userName = ''.obs;

  var featuredDoctors = <DoctorModel>[].obs;

  var pendingAppointments = <PatientRequestModel>[
    PatientRequestModel(
      id: '1',
      patientId: '1',
      therapistId: '1',
      serviceName: 'Ortho Therapy',
      serviceId: '1',
      date: '2024-01-15',
      time: '10:00 AM',
      status: 'confirmed',
      patientNotes: 'Regular checkup for shoulder pain',
      requestedAt: DateTime.now().subtract(const Duration(days: 2)),
      therapistName: 'Dr. Sarah Johnson',
      therapistImage: '',
      duration: '45 mins',
      price: 1200.0,
    ),
    PatientRequestModel(
      id: '2',
      patientId: '1',
      therapistId: '2',
      serviceName: 'Neuro Therapy',
      serviceId: '2',
      date: '2024-01-18',
      time: '02:30 PM',
      status: 'pending',
      patientNotes: 'First session for coordination issues',
      requestedAt: DateTime.now().subtract(const Duration(days: 1)),
      therapistName: 'Dr. Mike Wilson',
      therapistImage: '',
      duration: '60 mins',
      price: 1500.0,
    ),
  ].obs;

  var regularServices = [
    ServiceModel(id: 1, name: 'Ortho Therapy', category: 'Orthopedic', description: 'Specialized treatment for bone and joint issues', icon: Icons.fitness_center, isActive: true, rate: 1200.0),
    ServiceModel(id: 2, name: 'Neuro Therapy', category: 'Neurology', description: 'Treatment for neurological conditions', icon: Icons.psychology, isActive: true, rate: 1500.0),
    ServiceModel(id: 3, name: 'Pain Management', category: 'Other', description: 'Advanced techniques to alleviate chronic pain', icon: Icons.healing_rounded, isActive: true, rate: 1400.0),
    ServiceModel(id: 4, name: 'Pediatric Therapy', category: 'Pediatrics', description: 'Therapy for children developmental milestones', icon: Icons.child_care_rounded, isActive: true, rate: 1100.0),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final userData = await read(AppSession.userData);
    if (userData != null) {
      userName.value = userData['name'] ?? 'Patient';
    }
    featuredDoctors.assignAll(sampleDoctors);
  }

  void cancelAppointment(String appointmentId) {
    final appointment = pendingAppointments.firstWhere((app) => app.id == appointmentId);
    final index = pendingAppointments.indexWhere((app) => app.id == appointmentId);
    pendingAppointments[index] = appointment.copyWith(status: 'cancelled');
    update();
  }

  void rescheduleAppointment(String appointmentId, String newDate, String newTime) {
    final appointment = pendingAppointments.firstWhere((app) => app.id == appointmentId);
    final index = pendingAppointments.indexWhere((app) => app.id == appointmentId);
    pendingAppointments[index] = appointment.copyWith(date: newDate, time: newTime, status: 'pending');
    update();
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
    Get.to(() => SlotSelection(service: service));
  }

  void viewDoctorProfile(DoctorModel doctor) {
    Get.to(() => DoctorDetails(doctor: doctor));
  }
}
