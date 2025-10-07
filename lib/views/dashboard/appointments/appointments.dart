import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/patient_request_model.dart';
import 'package:prime_health_patients/views/dashboard/appointments/appointments_ctrl.dart';

class Appointments extends StatelessWidget {
  Appointments({super.key});

  final AppointmentsCtrl ctrl = Get.put(AppointmentsCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            toolbarHeight: 65,
            backgroundColor: Colors.white,
            pinned: true,
            floating: true,
            automaticallyImplyLeading: false,
            title: Text(
              'My Appointments',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.all(20), child: _buildFilterChips()),
          ),
          Obx(
            () => ctrl.filteredAppointments.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final appointment = ctrl.filteredAppointments[index];
                        return _buildAppointmentCard(appointment);
                      }, childCount: ctrl.filteredAppointments.length),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    if (ctrl.filters.isEmpty) {
      return SizedBox.shrink();
    }
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ctrl.filters.length,
        itemBuilder: (context, index) {
          final filter = ctrl.filters[index];
          return Obx(
            () => FilterChip(
              label: Text(filter),
              selected: ctrl.selectedFilter.value == filter,
              onSelected: (selected) => ctrl.changeFilter(filter),
              selectedColor: Color(0xFF2563EB),
              checkmarkColor: Colors.white,
              labelStyle: GoogleFonts.poppins(color: ctrl.selectedFilter.value == filter ? Colors.white : Colors.grey[700], fontWeight: FontWeight.w500),
              backgroundColor: Colors.white,
            ).paddingOnly(right: 8),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(PatientRequestModel appointment) {
    final statusColor = _getStatusColor(appointment.status);
    final statusIcon = _getStatusIcon(appointment.status);
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
          onTap: () => ctrl.viewAppointmentDetails(appointment.id),
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
                            appointment.serviceName,
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          const SizedBox(height: 2),
                          Text(appointment.therapistName, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        appointment.status.toUpperCase(),
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(appointment),
                if (appointment.status == 'completed') ...[const SizedBox(height: 12), _buildReviewSection(appointment)],
                if (appointment.status == 'pending' || appointment.status == 'confirmed') ...[
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 8),
                  _buildActionButtons(appointment.id, appointment.status),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(PatientRequestModel appointment) {
    return Row(
      children: [
        Expanded(child: _buildDetailItem(Icons.calendar_today_outlined, appointment.date)),
        Expanded(child: _buildDetailItem(Icons.access_time_outlined, appointment.time)),
        Expanded(child: _buildDetailItem(Icons.timer_outlined, appointment.duration)),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(PatientRequestModel appointment) {
    final hasReview = appointment.review != null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasReview ? Color(0xFF10B981).withOpacity(0.05) : Color(0xFFF59E0B).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasReview ? Color(0xFF10B981).withOpacity(0.2) : Color(0xFFF59E0B).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasReview ? 'You reviewed this session' : 'Rate your experience',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: hasReview ? Color(0xFF10B981) : Color(0xFFF59E0B)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStarRating(appointment.review?.rating ?? 0.0),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.review?.comment ?? "",
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!hasReview) ...[
            ElevatedButton(
              onPressed: () => _showAddReviewDialog(appointment.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Add Review', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500)),
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
        return Icon(index < rating.floor() ? Icons.star_rounded : (index < rating.ceil() ? Icons.star_half_rounded : Icons.star_outline_rounded), color: Color(0xFFF59E0B), size: 14);
      }),
    );
  }

  void _showAddReviewDialog(String appointmentId) {
    final appointment = ctrl.appointments.firstWhere((appt) => appt.id == appointmentId);
    double rating = 0.0;
    final commentController = TextEditingController();
    Get.dialog(
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Color(0xFF2563EB).withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.star_rounded, color: Color(0xFF2563EB), size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rate Your Experience',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How was your session with ${appointment.therapistName}?',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text('Tap to rate', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: RatingStars(
                        axis: Axis.horizontal,
                        value: rating,
                        onValueChanged: (v) => setState(() => rating = v),
                        starCount: 5,
                        starSize: 20,
                        valueLabelColor: const Color(0xff9b9b9b),
                        valueLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontStyle: FontStyle.normal, fontSize: 12.0),
                        valueLabelRadius: 10,
                        maxValue: 5,
                        starSpacing: 10,
                        maxValueVisibility: true,
                        valueLabelVisibility: true,
                        animationDuration: Duration(milliseconds: 1000),
                        valueLabelPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                        valueLabelMargin: const EdgeInsets.only(right: 8),
                        starOffColor: const Color(0xffe7e8ea),
                        starColor: Color(0xFFF59E0B),
                        angle: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: commentController,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Your Review (Optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: rating > 0
                                ? () {
                                    ctrl.addReview(appointmentId, rating, commentController.text);
                                    Get.back();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Submit Review',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildActionButtons(String appointmentId, String status) {
    return Row(
      children: [
        if (status == 'pending') ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(appointmentId),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFFEF4444),
                side: BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showRescheduleDialog(appointmentId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text('Reschedule', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 20),
        Text(
          'No Appointments Found',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'You don\'t have any ${ctrl.selectedFilter.value.toLowerCase()} appointments at the moment',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Color(0xFFF59E0B);
      case 'confirmed':
        return Color(0xFF10B981);
      case 'completed':
        return Color(0xFF3B82F6);
      case 'cancelled':
        return Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_outlined;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.verified_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.calendar_today_outlined;
    }
  }

  void _showCancelDialog(String appointmentId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Color(0xFFEF4444).withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.cancel_outlined, color: Color(0xFFEF4444), size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Cancel Appointment?',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to cancel this appointment? This action cannot be undone.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Keep', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl.cancelAppointment(appointmentId);
                        Get.back();
                        Get.snackbar(
                          'Appointment Cancelled',
                          'Your appointment has been cancelled successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Color(0xFF10B981),
                          colorText: Colors.white,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEF4444),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 12),
                      ),
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

  void _showRescheduleDialog(String appointmentId) {
    final appointment = ctrl.appointments.firstWhere((appt) => appt.id == appointmentId);
    final dateController = TextEditingController(text: appointment.date);
    final timeController = TextEditingController(text: appointment.time);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Color(0xFF2563EB).withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.schedule_outlined, color: Color(0xFF2563EB), size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'Appointment',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose new date and time for your appointment',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime? picked = await showDatePicker(context: Get.context!, initialDate: now, firstDate: now, lastDate: DateTime(now.year + 1, now.month, now.day));
                    if (picked != null) {
                      dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    prefixIcon: Icon(Icons.access_time_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(context: Get.context!, initialTime: TimeOfDay.now());
                    if (picked != null) {
                      timeController.text = "${picked.hourOfPeriod}:${picked.minute.toString().padLeft(2, '0')} ${picked.period == DayPeriod.am ? 'AM' : 'PM'}";
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (dateController.text.isNotEmpty && timeController.text.isNotEmpty) {
                            ctrl.rescheduleAppointment(appointmentId, dateController.text, timeController.text);
                            Get.back();
                            Get.snackbar(
                              'Appointment Rescheduled',
                              'Your appointment has been rescheduled successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Color(0xFF10B981),
                              colorText: Colors.white,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Reschedule',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
