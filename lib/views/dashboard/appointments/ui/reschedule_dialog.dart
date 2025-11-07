import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prime_health_patients/models/booking_model.dart';
import 'package:prime_health_patients/models/slot_model.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';

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
        Get.back();
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reschedule Appointment',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text('Choose new date and time for your appointment', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warningAmber.withOpacity(0.05),
                  border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppTheme.warningAmber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Current: ${DateFormat('MMM dd, yyyy').format(widget.booking.appointmentDate)} at ${widget.booking.formattedTime}',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [_buildDateSelection(), const SizedBox(height: 20), _buildTimeSelection(), const SizedBox(height: 24)]),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppTheme.borderColor)),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: BorderSide(color: AppTheme.borderColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isProcessing
                            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : Text('Reschedule', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
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
                  child: Text(
                    _selectedDate != null ? DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate!) : 'Choose a date',
                    style: GoogleFonts.inter(fontSize: 14, color: _selectedDate != null ? AppTheme.textPrimary : AppTheme.textLight, fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded, color: AppTheme.textSecondary),
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
        if (_selectedDate == null) _buildEmptyState('Please select a date first'),
        if (_selectedDate != null && _isLoadingSlots) _buildLoadingState(),
        if (_selectedDate != null && !_isLoadingSlots && _availableSlots.isEmpty) _buildEmptyState('No available slots for selected date'),
        if (_selectedDate != null && !_isLoadingSlots && _availableSlots.isNotEmpty) _buildSlotsGrid(),
      ],
    );
  }

  Widget _buildSlotsGrid() {
    return Column(
      children: [
        Text('Available time slots for ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSlots.map((slot) {
            final isSelected = _selectedSlot?.id == slot.id;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedSlot = slot);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryTeal : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppTheme.primaryTeal : AppTheme.borderColor, width: isSelected ? 2 : 1),
                  boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryTeal.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTimeSlot(slot.startTime, slot.endTime),
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(_formatDuration(slot.startTime, slot.endTime), style: GoogleFonts.inter(fontSize: 10, color: isSelected ? Colors.white.withOpacity(0.8) : AppTheme.textSecondary)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal)),
          const SizedBox(height: 8),
          Text('Loading available slots...', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Icon(Icons.schedule_rounded, size: 40, color: AppTheme.textLight),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
