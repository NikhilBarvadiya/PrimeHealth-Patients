import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/booking_model.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/reschedule_dialog.dart';

class UpcomingAppointmentsCtrl extends GetxController {
  var isLoading = false.obs;
  var appointments = <BookingModel>[].obs;

  AuthService get authService => Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    try {
      isLoading.value = true;
      final appointmentsData = await authService.getUpcomingAppointments({"page": 1, "limit": 20});
      if (appointmentsData != null && appointmentsData['docs'] != null) {
        final List<dynamic> data = appointmentsData['docs'];
        appointments.assignAll(data.map((item) => BookingModel.fromJson(item)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load appointments: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelBooking(int index) async {
    try {
      isLoading.value = true;
      final bookingData = await authService.cancelAppointment({"bookingId": appointments[index].id});
      if (bookingData != null && bookingData['booking'] != null) {
        appointments[index] = BookingModel.fromJson(bookingData['booking']);
      }
    } catch (e) {
      toaster.error('Failed to cancel booking details: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void showCancelDialog(int index) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.emergencyRed.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.cancel_rounded, color: AppTheme.emergencyRed, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Cancel Booking?',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to cancel this booking? This action cannot be undone.',
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: BorderSide(color: AppTheme.borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Keep Booking', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        cancelBooking(index);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.emergencyRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Cancel', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void showRescheduleDialog(BookingModel booking) {
    Get.dialog(RescheduleDialog(booking: booking, onRescheduleSuccess: () => loadAppointments()), barrierDismissible: false);
  }
}
