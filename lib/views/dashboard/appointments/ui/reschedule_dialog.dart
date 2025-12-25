import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prime_health_patients/models/booking_model.dart';
import 'package:prime_health_patients/models/slot_model.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';
import 'package:shimmer/shimmer.dart';

class RescheduleDialog extends StatefulWidget {
  final BookingModel booking;
  final Function() onRescheduleSuccess;

  const RescheduleDialog({super.key, required this.booking, required this.onRescheduleSuccess});

  @override
  State<RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<RescheduleDialog> {
  final AuthService _authService = Get.find<AuthService>();

  DateTime? _selectedDate;
  SlotModel? _selectedSlot;
  List<SlotModel> _availableSlots = [];
  bool _isLoadingSlots = false, _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedDate == null) return;
    setState(() => _isLoadingSlots = true);
    try {
      final request = {'doctorId': widget.booking.doctorId, 'date': DateFormat('yyyy-MM-dd').format(_selectedDate!)};
      final response = await _authService.getDoctorSlots(request);
      if (response != null && response['slots'] != null) {
        final slotsList = List<Map<String, dynamic>>.from(response['slots']).map((slotData) => SlotModel.fromJson(slotData)).where((slot) => slot.status == 'available').toList();
        setState(() {
          _availableSlots = slotsList;
          _selectedSlot = null;
        });
      }
    } catch (error) {
      toaster.error('Error loading available slots: $error');
    } finally {
      setState(() => _isLoadingSlots = false);
    }
  }

  Future<void> _rescheduleAppointment() async {
    if (_selectedDate == null || _selectedSlot == null) {
      toaster.error('Please select a date and time slot');
      return;
    }
    try {
      setState(() => _isProcessing = true);
      final rescheduleData = {'bookingId': widget.booking.id, 'newSlotId': _selectedSlot!.id, 'reason': 'Patient requested reschedule'};
      final response = await _authService.rescheduleAppointment(rescheduleData);
      if (response != null && response['booking'] != null) {
        toaster.success('Appointment rescheduled successfully!');
        widget.onRescheduleSuccess();
        Get.close(1);
      }
    } catch (error) {
      toaster.error('Reschedule failed: $error');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  String _formatTimeSlot(DateTime startTime, DateTime endTime) {
    final startFormat = DateFormat('hh:mm a');
    final endFormat = DateFormat('hh:mm a');
    return '${startFormat.format(startTime.toLocal())} - ${endFormat.format(endTime.toLocal())}';
  }

  String _formatDuration(DateTime startTime, DateTime endTime) {
    final difference = endTime.difference(startTime);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85, maxWidth: MediaQuery.of(context).size.width - 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildCurrentAppointmentInfo(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [_buildDateSelection(), const SizedBox(height: 24), _buildTimeSelection(), const SizedBox(height: 16)]),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.primaryTeal.withOpacity(0.08), AppTheme.primaryTeal.withOpacity(0.04)]),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.calendar_today_rounded, color: AppTheme.primaryTeal, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Reschedule Appointment',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Choose new date and time for your appointment', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildCurrentAppointmentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningAmber.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: AppTheme.borderColor.withOpacity(0.5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.warningAmber, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Appointment',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.warningAmber),
                ),
                const SizedBox(height: 2),
                Text('${DateFormat('MMM dd, yyyy').format(widget.booking.appointmentDate)} • ${widget.booking.formattedTime}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: AppTheme.primaryTeal, size: 18),
            const SizedBox(width: 8),
            Text(
              'Select New Date',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final DateTime now = DateTime.now();
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? now,
              firstDate: now,
              lastDate: DateTime(now.year + 1, now.month, now.day),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: AppTheme.primaryTeal,
                    colorScheme: ColorScheme.light(primary: AppTheme.primaryTeal),
                    buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                    dialogBackgroundColor: Colors.white,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && picked != _selectedDate) {
              setState(() {
                _selectedDate = picked;
                _selectedSlot = null;
              });
              _loadAvailableSlots();
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Date',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedDate != null ? DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate!) : 'Choose a date',
                        style: GoogleFonts.inter(fontSize: 14, color: _selectedDate != null ? AppTheme.textPrimary : AppTheme.textLight, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.calendar_month_rounded, color: AppTheme.primaryTeal, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time_rounded, color: AppTheme.primaryTeal, size: 18),
            const SizedBox(width: 8),
            Text(
              'Available Time Slots',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedDate == null) _buildEmptyState('Please select a date first', Icons.calendar_today_rounded),
        if (_selectedDate != null) ...[
          if (_isLoadingSlots) _buildSlotsShimmer(),
          if (!_isLoadingSlots) ...[if (_availableSlots.isEmpty) _buildEmptyState('No available slots for selected date', Icons.schedule_rounded), if (_availableSlots.isNotEmpty) _buildSlotsGrid()],
        ],
      ],
    );
  }

  Widget _buildSlotsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              2,
              (index) => Container(
                width: Get.width * .4,
                height: 60,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available time slots for ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableSlots.map((slot) {
            final isSelected = _selectedSlot?.id == slot.id;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedSlot = slot);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryTeal : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppTheme.primaryTeal : AppTheme.borderColor, width: isSelected ? 2 : 1),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppTheme.primaryTeal.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
                        : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTimeSlot(slot.startTime, slot.endTime),
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(_formatDuration(slot.startTime, slot.endTime), style: GoogleFonts.inter(fontSize: 11, color: isSelected ? Colors.white.withOpacity(0.8) : AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedSlot != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Time',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimeSlot(_selectedSlot!.startTime, _selectedSlot!.endTime),
                        style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppTheme.textLight),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderColor.withOpacity(0.5))),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isProcessing ? null : () => Get.close(1),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: BorderSide(color: AppTheme.borderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.white,
              ),
              child: Text('Cancel', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: (_selectedSlot != null && !_isProcessing) ? _rescheduleAppointment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 2,
                shadowColor: AppTheme.primaryTeal.withOpacity(0.3),
              ),
              child: _isProcessing
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text('Reschedule', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
