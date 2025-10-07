import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_health_patients/models/patient_request_model.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/appointment_details.dart';

class AppointmentsCtrl extends GetxController {
  var selectedFilter = 'All'.obs;
  final filters = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];

  var appointments = <PatientRequestModel>[
    PatientRequestModel(
      id: '1',
      patientId: '1',
      therapistId: '1',
      serviceName: 'Orthopedic Therapy',
      serviceId: '1',
      date: '2024-01-15',
      time: '10:00 AM',
      status: 'completed',
      patientNotes: 'Regular checkup for shoulder pain',
      requestedAt: DateTime.now().subtract(Duration(days: 2)),
      therapistName: 'Dr. Sarah Johnson',
      therapistImage: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150',
      duration: '45 mins',
      price: 1500.0,
      review: ReviewModel(
        id: 'rev1',
        appointmentId: '1',
        patientId: '1',
        therapistId: '1',
        rating: 4.5,
        comment: 'Dr. Sarah was very professional and helped me with my shoulder pain effectively.',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        patientName: 'John Doe',
      ),
    ),
    PatientRequestModel(
      id: '2',
      patientId: '1',
      therapistId: '2',
      serviceName: 'Neuro Rehabilitation',
      serviceId: '2',
      date: '2024-01-18',
      time: '02:30 PM',
      status: 'completed',
      patientNotes: 'First session for coordination issues',
      requestedAt: DateTime.now().subtract(Duration(days: 1)),
      therapistName: 'Dr. Mike Wilson',
      therapistImage: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=150',
      duration: '60 mins',
      price: 2000.0,
    ),
    PatientRequestModel(
      id: '3',
      patientId: '1',
      therapistId: '3',
      serviceName: 'Sports Therapy',
      serviceId: '3',
      date: '2024-01-20',
      time: '11:00 AM',
      status: 'completed',
      patientNotes: 'Ankle injury recovery session',
      requestedAt: DateTime.now().subtract(Duration(days: 5)),
      therapistName: 'Dr. Emily Davis',
      therapistImage: 'https://images.unsplash.com/photo-1594824947933-d0501ba2fe65?w=150',
      duration: '45 mins',
      price: 1800.0,
      review: ReviewModel(
        id: 'rev3',
        appointmentId: '3',
        patientId: '1',
        therapistId: '3',
        rating: 5.0,
        comment: 'Excellent service! My ankle feels much better after just one session.',
        createdAt: DateTime.now().subtract(Duration(days: 4)),
        patientName: 'John Doe',
      ),
    ),
    PatientRequestModel(
      id: '4',
      patientId: '1',
      therapistId: '1',
      serviceName: 'Pain Management',
      serviceId: '4',
      date: '2024-01-22',
      time: '03:00 PM',
      status: 'cancelled',
      patientNotes: 'Back pain treatment',
      requestedAt: DateTime.now().subtract(Duration(days: 3)),
      therapistName: 'Dr. Sarah Johnson',
      therapistImage: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150',
      duration: '30 mins',
      price: 1000.0,
    ),
    PatientRequestModel(
      id: '5',
      patientId: '1',
      therapistId: '2',
      serviceName: 'Neuro Therapy',
      serviceId: '2',
      date: '2024-01-25',
      time: '09:30 AM',
      status: 'confirmed',
      patientNotes: 'Follow-up session',
      requestedAt: DateTime.now().subtract(Duration(hours: 12)),
      therapistName: 'Dr. Mike Wilson',
      therapistImage: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=150',
      duration: '60 mins',
      price: 1500.0,
    ),
  ].obs;

  List<PatientRequestModel> get filteredAppointments {
    if (selectedFilter.value == 'All') {
      return appointments;
    }
    return appointments.where((appointment) => appointment.status == selectedFilter.value.toLowerCase()).toList();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  void cancelAppointment(String appointmentId) {
    final appointment = appointments.firstWhere((app) => app.id == appointmentId);
    final index = appointments.indexWhere((app) => app.id == appointmentId);
    appointments[index] = appointment.copyWith(status: 'cancelled');
    update();
  }

  void rescheduleAppointment(String appointmentId, String newDate, String newTime) {
    final appointment = appointments.firstWhere((app) => app.id == appointmentId);
    final index = appointments.indexWhere((app) => app.id == appointmentId);
    appointments[index] = appointment.copyWith(date: newDate, time: newTime, status: 'pending');
    update();
  }

  void addReview(String appointmentId, double rating, String comment) {
    final appointment = appointments.firstWhere((app) => app.id == appointmentId);
    final index = appointments.indexWhere((app) => app.id == appointmentId);
    final review = ReviewModel(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      appointmentId: appointmentId,
      patientId: appointment.patientId,
      therapistId: appointment.therapistId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      patientName: 'You',
    );
    appointments[index] = appointment.copyWith(review: review);
    update();
    Get.snackbar('Review Submitted!', 'Thank you for your feedback', backgroundColor: Color(0xFF10B981), colorText: Colors.white);
  }

  void updateReview(String appointmentId, double rating, String comment) {
    final appointment = appointments.firstWhere((app) => app.id == appointmentId);
    final index = appointments.indexWhere((app) => app.id == appointmentId);
    if (appointment.review != null) {
      final updatedReview = appointment.review!.copyWith(rating: rating, comment: comment);
      appointments[index] = appointment.copyWith(review: updatedReview);
      update();
      Get.snackbar('Review Updated!', 'Your feedback has been updated', backgroundColor: Color(0xFF10B981), colorText: Colors.white);
    }
  }

  void viewAppointmentDetails(String appointmentId) {
    Get.to(() => AppointmentDetails(appointmentId: appointmentId));
  }
}
