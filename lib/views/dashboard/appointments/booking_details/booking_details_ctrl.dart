import 'package:get/get.dart';
import 'package:prime_health_patients/models/booking_model.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';

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

  void cancelBooking() {
    // TODO: Implement cancel booking API
    Get.snackbar('Coming Soon', 'Cancel booking feature will be available soon');
  }

  void rescheduleBooking() {
    // TODO: Implement reschedule booking API
    Get.snackbar('Coming Soon', 'Reschedule feature will be available soon');
  }

  void addReview(double rating, String comment) {
    // TODO: Implement add review API
    Get.snackbar('Success', 'Review submitted successfully');
  }
}
