import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prime_health_patients/models/booking_model.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/dashboard/appointments/appointments_ctrl.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/date_filter_dialog.dart';
import 'package:prime_health_patients/views/dashboard/dashboard_ctrl.dart';
import 'package:shimmer/shimmer.dart';

class Appointments extends StatelessWidget {
  Appointments({super.key});

  final AppointmentsCtrl ctrl = Get.put(AppointmentsCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () async => await ctrl.refreshBookings(),
        child: CustomScrollView(
          controller: ctrl.scrollController,
          physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              elevation: 0,
              toolbarHeight: 75,
              backgroundColor: AppTheme.backgroundWhite,
              pinned: true,
              floating: true,
              automaticallyImplyLeading: false,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Appointments',
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text('${ctrl.filteredBookings.length} ${ctrl.selectedFilter.value.toLowerCase()} appointments', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary))),
                ],
              ),
              actions: [
                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                    backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
                  ),
                  icon: Icon(Icons.filter_alt_rounded, color: Colors.black87, size: 20),
                  onPressed: _showFilterDialog,
                ),
                const SizedBox(width: 10),
              ],
              bottom: PreferredSize(preferredSize: const Size.fromHeight(65), child: _buildFilterSection()),
            ),
            _buildBookingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 9, bottom: 8),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: ctrl.filters.length,
              itemBuilder: (context, index) {
                final filter = ctrl.filters[index];
                return Obx(
                  () => Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                      selected: ctrl.selectedFilter.value == filter,
                      onSelected: (selected) => ctrl.changeFilter(filter),
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.primaryTeal.withOpacity(0.1),
                      checkmarkColor: AppTheme.primaryTeal,
                      labelStyle: TextStyle(color: ctrl.selectedFilter.value == filter ? AppTheme.primaryTeal : AppTheme.textSecondary),
                      side: BorderSide(color: ctrl.selectedFilter.value == filter ? AppTheme.primaryTeal : AppTheme.borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildDateFilterChip(),
        ],
      ),
    );
  }

  Widget _buildDateFilterChip() {
    return Row(
      children: [
        if (ctrl.startDate != null || ctrl.endDate != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryTeal),
            ),
            child: Row(
              children: [
                Text(
                  _getDateFilterText(),
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryTeal, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: ctrl.clearDateFilter,
                  child: Icon(Icons.close_rounded, size: 14, color: AppTheme.primaryTeal),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getDateFilterText() {
    if (ctrl.startDate != null && ctrl.endDate != null) {
      return '${DateFormat('MMM dd').format(ctrl.startDate!)} - ${DateFormat('MMM dd, yyyy').format(ctrl.endDate!)}';
    } else if (ctrl.startDate != null) {
      return 'From ${DateFormat('MMM dd, yyyy').format(ctrl.startDate!)}';
    } else if (ctrl.endDate != null) {
      return 'Until ${DateFormat('MMM dd, yyyy').format(ctrl.endDate!)}';
    }
    return '';
  }

  Widget _buildBookingsList() {
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.bookings.isEmpty) {
        return SliverList(delegate: SliverChildBuilderDelegate((context, index) => _buildBookingShimmerCard(), childCount: 6));
      }
      if (ctrl.bookings.isEmpty && !ctrl.isLoading.value) {
        return SliverFillRemaining(child: _buildEmptyState());
      }
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (ctrl.shouldShowLoadMore(index)) {
            return _buildLoadMoreIndicator();
          }
          if (ctrl.shouldShowEndOfList(index)) {
            return _buildEndOfList();
          }
          final booking = ctrl.bookings[index];
          return _buildBookingCard(booking);
        }, childCount: ctrl.bookings.length + (ctrl.hasMore.value || ctrl.bookings.isNotEmpty ? 1 : 0)),
      );
    });
  }

  Widget _buildBookingShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final statusColor = _getStatusColor(booking.status);
    final statusIcon = _getStatusIcon(booking.status);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => ctrl.viewBookingDetails(booking.id!),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(statusIcon, color: statusColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.serviceName ?? 'Service',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.doctorName ?? 'Doctor',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        booking.statusDisplay.toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(booking),
                if (booking.status == 'completed') ...[const SizedBox(height: 12), _buildReviewSection(booking)],
                if (_showActionButtons(booking)) ...[const SizedBox(height: 12), const Divider(color: AppTheme.borderColor), const SizedBox(height: 8), _buildActionButtons(booking)],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          _buildDetailItem(Icons.calendar_today_rounded, booking.formattedDate, AppTheme.textSecondary),
          _buildDetailItem(Icons.access_time_rounded, booking.formattedTime, AppTheme.textSecondary),
          _buildDetailItem(Icons.currency_rupee_rounded, '₹${booking.amount}', AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 12, color: color, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(BookingModel booking) {
    final hasReview = booking.review != null && booking.review!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasReview ? AppTheme.successGreen.withOpacity(0.05) : AppTheme.warningAmber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hasReview ? AppTheme.successGreen.withOpacity(0.2) : AppTheme.warningAmber.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(hasReview ? Icons.star_rounded : Icons.star_outline_rounded, color: hasReview ? AppTheme.successGreen : AppTheme.warningAmber, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasReview ? 'Thank you for your review!' : 'How was your experience?',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: hasReview ? AppTheme.successGreen : AppTheme.warningAmber),
                ),
                if (hasReview) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildStarRating(booking.rating ?? 0.0),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.review!,
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!hasReview) ...[
            ElevatedButton(
              onPressed: () => _showAddReviewDialog(ctrl, booking),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Add Review', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500)),
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.edit_rounded, size: 16, color: AppTheme.primaryTeal),
              onPressed: () => _showEditReviewDialog(ctrl, booking),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(index < rating.floor() ? Icons.star_rounded : (index < rating.ceil() ? Icons.star_half_rounded : Icons.star_outline_rounded), color: AppTheme.warningAmber, size: 14);
      }),
    );
  }

  Widget _buildActionButtons(BookingModel booking) {
    final canCancel = booking.canCancel;
    final canReschedule = booking.canReschedule;
    return Row(
      children: [
        if (canCancel) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(booking),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.emergencyRed,
                side: const BorderSide(color: AppTheme.emergencyRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text('Cancel', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (canReschedule)
          Expanded(
            child: ElevatedButton(
              onPressed: () => ctrl.showRescheduleDialog(booking),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text('Reschedule', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(
      () => ctrl.isLoading.value
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildEndOfList() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text('No more appointments', style: TextStyle(fontSize: 14, color: Colors.grey)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_today_outlined, size: 80, color: AppTheme.textLight),
        const SizedBox(height: 20),
        Text(
          'No Appointments Found',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'You don\'t have any ${ctrl.selectedFilter.value.toLowerCase()} appointments at the moment',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            DashboardCtrl dashboardCtrl = Get.put(DashboardCtrl());
            dashboardCtrl.changeTab(1);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text('Book Appointment', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  bool _showActionButtons(BookingModel booking) {
    return booking.canCancel || booking.canReschedule;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'scheduled':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
      case 'no-show':
        return const Color(0xFFEF4444);
      case 'completed':
        return AppTheme.primaryTeal;
      case 'rescheduled':
        return const Color(0xFF8B5CF6);
      default:
        return AppTheme.textLight;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'scheduled':
        return Icons.schedule_rounded;
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'completed':
        return Icons.verified_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'no-show':
        return Icons.no_accounts_rounded;
      case 'rescheduled':
        return Icons.calendar_today_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  void _showFilterDialog() {
    Get.dialog(DateFilterDialog(onFilterApplied: (start, end) => ctrl.setDateRange(start, end), initialStartDate: ctrl.startDate, initialEndDate: ctrl.endDate));
  }

  void _showAddReviewDialog(AppointmentsCtrl ctrl, BookingModel booking) {
    double rating = 0.0;
    final commentController = TextEditingController();
    Get.dialog(_buildReviewDialog(ctrl, booking, rating, commentController, isEdit: false), barrierDismissible: false);
  }

  void _showEditReviewDialog(AppointmentsCtrl ctrl, BookingModel booking) {
    double rating = booking.rating ?? 0.0;
    final commentController = TextEditingController(text: booking.review ?? '');
    Get.dialog(_buildReviewDialog(ctrl, booking, rating, commentController, isEdit: true), barrierDismissible: false);
  }

  Widget _buildReviewDialog(AppointmentsCtrl ctrl, BookingModel booking, double rating, TextEditingController commentController, {bool isEdit = false}) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        child: StatefulBuilder(
          builder: (context, setState) {
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.star_rounded, color: AppTheme.primaryTeal, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  isEdit ? 'Edit Your Review' : 'Rate Your Experience',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                Text('How was your session with ${booking.doctorName}?', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: RatingStars(
                    axis: Axis.horizontal,
                    value: rating,
                    onValueChanged: (v) => setState(() => rating = v),
                    starCount: 5,
                    starSize: 20,
                    valueLabelColor: AppTheme.textSecondary,
                    valueLabelTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12.0),
                    valueLabelRadius: 10,
                    maxValue: 5,
                    starSpacing: 10,
                    maxValueVisibility: true,
                    valueLabelVisibility: true,
                    animationDuration: const Duration(milliseconds: 1000),
                    valueLabelPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                    starOffColor: AppTheme.borderColor,
                    starColor: AppTheme.warningAmber,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: commentController,
                  minLines: 1,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'Your Review (Optional)',
                    labelStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.close(1),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: BorderSide(color: AppTheme.borderColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Cancel', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: rating > 0
                            ? () async {
                                Get.close(1);
                                if (isEdit) {
                                  await ctrl.updateReview(booking.id!, rating, commentController.text);
                                } else {
                                  await ctrl.addReview(booking.id!, rating, commentController.text);
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(isEdit ? 'Update Review' : 'Submit Review', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCancelDialog(BookingModel booking) {
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
                      onPressed: () => Get.close(1),
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
                        ctrl.cancelBooking(booking.id!);
                        Get.close(1);
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
}
