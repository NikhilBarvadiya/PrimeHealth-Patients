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
        toaster.success('Booking cancelled successfully');
      }
    } catch (e) {
      toaster.error('Failed to cancel booking: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void showRescheduleDialog() {
    if (booking.value == null) return;
    Get.dialog(RescheduleDialog(booking: booking.value!, onRescheduleSuccess: () => refreshBooking()), barrierDismissible: false);
  }

  Future<void> addReview(double rating, String review) async {
    try {
      isLoading.value = true;
      final requestData = {"bookingId": bookingId, "rating": rating, "review": review};
      final bookingData = await authService.addRatingReview(requestData);
      if (bookingData != null && bookingData['booking'] != null) {
        booking.value = BookingModel.fromJson(bookingData['booking']);
        toaster.success('Review submitted successfully');
      }
    } catch (e) {
      toaster.error('Failed to submit review: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateReview(double rating, String review) async {
    try {
      isLoading.value = true;
      final requestData = {"bookingId": bookingId, "rating": rating, "review": review};
      final bookingData = await authService.updateRatingReview(requestData);
      if (bookingData != null && bookingData['booking'] != null) {
        booking.value = BookingModel.fromJson(bookingData['booking']);
        toaster.success('Review updated successfully');
      }
    } catch (e) {
      toaster.error('Failed to update review: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
