import 'package:get/get.dart';
import 'package:prime_health_patients/models/booking_model.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/reschedule_dialog.dart';

class BookingDetailsCtrl extends GetxController {
  final String bookingId;

  BookingDetailsCtrl(this.bookingId);

  var isLoading = false.obs;
  var booking = Rxn<BookingModel>();

  AuthService get authService => Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    loadBookingDetails();
  }

  Future<void> loadBookingDetails() async {
    try {
      isLoading.value = true;
      final bookingData = await authService.getBookingDetails({"bookingId": bookingId});
      if (bookingData != null && bookingData['booking'] != null) {
        booking.value = BookingModel.fromJson(bookingData['booking']);
      }
    } catch (e) {
      toaster.error('Failed to load booking details: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBooking() async {
    await loadBookingDetails();
  }

  Future<void> cancelBooking() async {
    try {
      isLoading.value = true;
      final bookingData = await authService.cancelAppointment({"bookingId": bookingId});
      if (bookingData != null && bookingData['booking'] != null) {
        booking.value = BookingModel.fromJson(bookingData['booking']);
      }
    } catch (e) {
      toaster.error('Failed to cancel booking details: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void showRescheduleDialog() {
    if (booking.value == null) return;
    Get.dialog(RescheduleDialog(booking: booking.value!, onRescheduleSuccess: () => refreshBooking()), barrierDismissible: false);
  }

  void addReview(double rating, String comment) {
    // TODO: Implement add review API
    Get.snackbar('Success', 'Review submitted successfully');
  }
}
