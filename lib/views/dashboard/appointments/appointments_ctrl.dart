import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prime_health_patients/models/booking_model.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';
import 'package:prime_health_patients/views/dashboard/appointments/booking_details/booking_details.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/reschedule_dialog.dart';

class AppointmentsCtrl extends GetxController {
  var selectedFilter = 'All'.obs;
  var isLoading = false.obs, isRefreshing = false.obs, hasMore = true.obs;
  var currentPage = 1.obs;
  var scrollController = ScrollController();

  final filters = ['All', 'Scheduled', 'Confirmed', 'Completed', 'Cancelled', 'Rescheduled'];

  DateTime? startDate, endDate;

  var bookings = <BookingModel>[].obs;

  AuthService get authService => Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _setupScrollController();
    loadBookings();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        loadMore();
      }
    });
  }

  Future<void> loadBookings({bool loadMore = false}) async {
    if (isLoading.value && !loadMore) return;
    try {
      if (!loadMore) {
        isLoading.value = true;
        currentPage.value = 1;
        hasMore.value = true;
        bookings.clear();
      } else {
        if (!hasMore.value) return;
        currentPage.value++;
      }
      final request = _buildRequest();
      Map<String, dynamic>? response = await authService.getBookingHistory(request);
      if (response != null && response.isNotEmpty && response['docs'] != null) {
        _handleResponse(response, loadMore);
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      toaster.error('Failed to load appointments: ${e.toString()}');
      hasMore.value = false;
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Map<String, dynamic> _buildRequest() {
    Map<String, dynamic> request = {'page': currentPage.value, 'limit': 10};
    if (selectedFilter.value != 'All') {
      request['status'] = _convertFilterToApiStatus(selectedFilter.value);
    }
    if (startDate != null) {
      request['startDate'] = DateFormat('yyyy-MM-dd').format(startDate!);
    }
    if (endDate != null) {
      request['endDate'] = DateFormat('yyyy-MM-dd').format(endDate!);
    }
    return request;
  }

  String _convertFilterToApiStatus(String filter) {
    final statusMap = {'Scheduled': 'scheduled', 'Confirmed': 'confirmed', 'Completed': 'completed', 'Cancelled': 'cancelled', 'Rescheduled': 'rescheduled'};
    return statusMap[filter] ?? filter.toLowerCase();
  }

  void _handleResponse(Map<String, dynamic> response, bool loadMore) {
    final List<dynamic> data = response['docs'];
    final newBookings = data.map((item) => BookingModel.fromJson(item)).toList();
    if (loadMore) {
      bookings.addAll(newBookings);
    } else {
      bookings.assignAll(newBookings);
    }
    final totalPages = int.tryParse(response['totalPages'].toString()) ?? 1;
    hasMore.value = currentPage.value < totalPages;
  }

  Future<void> refreshBookings() async {
    isRefreshing.value = true;
    await loadBookings();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    loadBookings();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate = start;
    endDate = end;
    loadBookings();
  }

  void clearDateFilter() {
    startDate = null;
    endDate = null;
    loadBookings();
  }

  List<BookingModel> get filteredBookings {
    return bookings.toList();
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      final response = await authService.cancelAppointment({'bookingId': bookingId, 'reason': 'Patient requested cancellation'});
      if (response != null) {
        final index = bookings.indexWhere((booking) => booking.id == bookingId);
        if (index != -1) {
          bookings[index].status = 'cancelled';
          bookings[index].cancelledBy = 'patient';
          bookings[index].cancelledAt = DateTime.now();
          update();
        }
        toaster.success('Appointment cancelled successfully');
      }
    } catch (e) {
      toaster.error('Failed to cancel appointment: ${e.toString()}');
    }
  }

  void showRescheduleDialog(BookingModel booking) {
    Get.dialog(RescheduleDialog(booking: booking, onRescheduleSuccess: refreshBookings), barrierDismissible: false);
  }

  Future<void> addReview(String bookingId, double rating, String comment) async {
    try {
      final index = bookings.indexWhere((booking) => booking.id == bookingId);
      if (index != -1) {
        // bookings[index] = bookings[index].copyWith(rating: rating, review: comment);
      }
      toaster.success('Review submitted successfully');
    } catch (e) {
      toaster.error('Failed to submit review: ${e.toString()}');
    }
  }

  void viewBookingDetails(String bookingId) {
    Get.to(() => BookingDetails(bookingId: bookingId));
  }

  void loadMore() {
    if (!isLoading.value && hasMore.value) {
      loadBookings(loadMore: true);
    }
  }

  bool shouldShowLoadMore(int index) {
    return index == bookings.length && hasMore.value;
  }

  bool shouldShowEndOfList(int index) {
    return index == bookings.length && !hasMore.value && bookings.isNotEmpty;
  }
}
