import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/booking_model.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/dashboard/appointments/booking_details/booking_details.dart';
import 'package:prime_health_patients/views/dashboard/appointments/upcoming_appointments/upcoming_appointments_ctrl.dart';
import 'package:prime_health_patients/views/dashboard/dashboard_ctrl.dart';
import 'package:shimmer/shimmer.dart';

class UpcomingAppointments extends StatelessWidget {
  UpcomingAppointments({super.key});

  final UpcomingAppointmentsCtrl ctrl = Get.put(UpcomingAppointmentsCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryLight,
        title: Text(
          'Upcoming Appointments',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        leading: IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
          ),
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryLight, size: 20),
          onPressed: () => Get.close(1),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.appointments.isEmpty) {
          return _buildLoadingState();
        }
        if (ctrl.appointments.isEmpty && !ctrl.isLoading.value) {
          return _buildEmptyState();
        }
        return _buildAppointmentsList();
      }),
    );
  }

  Widget _buildLoadingState() {
    return RefreshIndicator(
      onRefresh: () async => await ctrl.refreshAppointments(),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => _buildAppointmentShimmerCard(), childCount: 6)),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              const Divider(color: Colors.transparent),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async => await ctrl.refreshAppointments(),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: SizedBox(
          height: MediaQuery.of(Get.context!).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined, size: 80, color: AppTheme.textLight),
              const SizedBox(height: 20),
              Text(
                'No Upcoming Appointments',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'You don\'t have any upcoming appointments scheduled',
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  DashboardCtrl dashboardCtrl = Get.put(DashboardCtrl());
                  dashboardCtrl.changeTab(1);
                  Get.close(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 2,
                  shadowColor: AppTheme.primaryTeal.withOpacity(0.3),
                ),
                child: Text('Book Appointment', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return RefreshIndicator(
      onRefresh: () async => await ctrl.refreshAppointments(),
      child: CustomScrollView(
        controller: ctrl.scrollController,
        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (ctrl.shouldShowLoadMore(index)) {
                  return _buildLoadMoreIndicator();
                }
                if (ctrl.shouldShowEndOfList(index)) {
                  return _buildEndOfList();
                }
                final appointment = ctrl.appointments[index];
                return _buildAppointmentCard(appointment, index);
              }, childCount: ctrl.appointments.length + (ctrl.hasMore.value || ctrl.appointments.isNotEmpty ? 1 : 0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(
      () => ctrl.isLoadingMore.value
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

  Widget _buildAppointmentCard(BookingModel appointment, int index) {
    final statusColor = _getStatusColor(appointment.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            BookingModel? bookingModel = await Get.to(() => BookingDetails(bookingId: appointment.id!));
            if (bookingModel != null) {
              ctrl.appointments[index] = bookingModel;
              ctrl.update();
            }
          },
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
                      child: Icon(_getStatusIcon(appointment.status), color: statusColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.doctorName ?? 'Doctor',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(appointment.serviceName ?? 'Service', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        appointment.statusDisplay.toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(appointment),
                if (appointment.canCancel || appointment.canReschedule) ...[
                  const SizedBox(height: 12),
                  const Divider(color: AppTheme.borderColor),
                  const SizedBox(height: 8),
                  _buildActionButtons(appointment, index),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BookingModel appointment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          _buildDetailItem(Icons.calendar_today_rounded, appointment.formattedDate, AppTheme.textSecondary),
          _buildDetailItem(Icons.access_time_rounded, appointment.formattedTime, AppTheme.textSecondary),
          _buildDetailItem(Icons.medical_services_rounded, appointment.consultationType == 'in-person' ? 'In-Person' : 'Virtual', AppTheme.textSecondary),
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

  Widget _buildActionButtons(BookingModel appointment, int index) {
    return Row(
      children: [
        if (appointment.canCancel) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => ctrl.showCancelDialog(index),
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
        if (appointment.canReschedule)
          Expanded(
            child: ElevatedButton(
              onPressed: () => ctrl.showRescheduleDialog(appointment),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                elevation: 2,
                shadowColor: AppTheme.primaryTeal.withOpacity(0.3),
              ),
              child: Text('Reschedule', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'scheduled':
        return AppTheme.successGreen;
      case 'pending':
        return AppTheme.warningAmber;
      case 'cancelled':
      case 'no-show':
        return AppTheme.emergencyRed;
      case 'completed':
        return AppTheme.primaryTeal;
      case 'rescheduled':
        return AppTheme.warningAmber;
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
}
