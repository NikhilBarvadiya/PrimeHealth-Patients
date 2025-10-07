import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/patient_request_model.dart';
import 'package:prime_health_patients/views/dashboard/appointments/appointments_ctrl.dart';

class AppointmentDetails extends StatelessWidget {
  final String appointmentId;

  AppointmentDetails({super.key, required this.appointmentId});

  final AppointmentsCtrl ctrl = Get.find();

  PatientRequestModel get appointment => ctrl.appointments.firstWhere((appt) => appt.id == appointmentId);

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(appointment.status);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Appointment Details',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        leading: IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(_getStatusIcon(appointment.status), color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.serviceName,
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(appointment.therapistName, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      appointment.status.toUpperCase(),
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointment Details',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem('Date', appointment.date, Icons.calendar_today_outlined),
                  _buildDetailItem('Time', appointment.time, Icons.access_time_outlined),
                  _buildDetailItem('Duration', appointment.duration, Icons.timer_outlined),
                  _buildDetailItem('Price', '₹${appointment.price}', Icons.currency_rupee_outlined),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (appointment.patientNotes.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Notes',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Text(appointment.patientNotes, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (appointment.status == 'completed') _buildReviewSection(appointment),
            if (appointment.status == 'pending' || appointment.status == 'confirmed') ...[
              Row(
                children: [
                  if (appointment.status == 'pending') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showCancelDialog(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFFEF4444),
                          side: BorderSide(color: Color(0xFFEF4444)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showRescheduleDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Reschedule', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildReviewSection(PatientRequestModel appointment) {
    final hasReview = appointment.review != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: hasReview ? Color(0xFF10B981).withOpacity(0.05) : Color(0xFFF59E0B).withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasReview ? 'You reviewed this session' : 'Rate your experience',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                _buildStarRating(appointment.review?.rating ?? 0.0),
                const SizedBox(height: 4),
                Text(appointment.review?.comment ?? "", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
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
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return ClipRRect(
              child: Padding(
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
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showCancelDialog() {
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
                      child: Text('Keep', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl.cancelAppointment(appointmentId);
                        Get.close(2);
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
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
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

  void _showRescheduleDialog() {
    final dateController = TextEditingController(text: appointment.date);
    final timeController = TextEditingController(text: appointment.time);
    Get.dialog(
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  'Reschedule Appointment',
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
                        child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (dateController.text.isNotEmpty && timeController.text.isNotEmpty) {
                            ctrl.rescheduleAppointment(appointmentId, dateController.text, timeController.text);
                            Get.close(2);
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
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
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
