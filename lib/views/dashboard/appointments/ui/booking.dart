import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prime_health_patients/models/doctor_model.dart';
import 'package:prime_health_patients/models/service_model.dart';
import 'package:prime_health_patients/models/slot_model.dart';
import 'package:prime_health_patients/utils/config/session.dart';
import 'package:prime_health_patients/utils/helper.dart';
import 'package:prime_health_patients/utils/storage.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';
import 'package:shimmer/shimmer.dart';

class Booking extends StatefulWidget {
  final String? serviceId;
  final DoctorModel? doctor;

  const Booking({super.key, this.serviceId, this.doctor});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  final AuthService _authService = Get.find<AuthService>();

  bool _isProcessing = false;
  DateTime? _selectedDate;
  SlotModel? _selectedSlot;
  DoctorModel? _selectedDoctor;
  ServiceModel? _selectedService;

  List<SlotModel> _availableSlots = [];
  List<DoctorModel> _availableDoctors = [];
  List<ServiceModel> _availableServices = [];

  bool _isLoadingSlots = false, _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);
    try {
      final response = await _authService.getServiceDoctors({"serviceId": widget.serviceId, "doctorId": widget.doctor?.id});
      if (response != null) {
        if (response['services'] != null) {
          final servicesList = List<Map<String, dynamic>>.from(response['services']).map((serviceData) => ServiceModel.fromApi(serviceData)).toList();
          setState(() => _availableServices = servicesList);
          if (_availableServices.length == 1) {
            _selectedService = _availableServices.first;
          } else if (widget.serviceId != null) {
            _selectedService = _availableServices.firstWhere((service) => service.id == widget.serviceId, orElse: () => _availableServices.first);
          }
        }
        if (response['doctors'] != null) {
          final doctorsList = List<Map<String, dynamic>>.from(response['doctors']).map((doctorData) => DoctorModel.fromJson(doctorData)).toList();
          setState(() => _availableDoctors = doctorsList);
          if (widget.doctor != null) {
            _selectedDoctor = widget.doctor;
          } else if (_availableDoctors.length == 1) {
            _selectedDoctor = _availableDoctors.first;
          }
        } else if (widget.doctor != null) {
          _availableDoctors.add(widget.doctor!);
          _selectedDoctor = _availableDoctors.first;
        }
        if (_selectedDoctor != null) {
          _loadAvailableSlots();
        }
      }
    } catch (error) {
      toaster.error('Error loading data: $error');
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedDoctor == null) return;
    setState(() => _isLoadingSlots = true);
    try {
      final request = {'doctorId': _selectedDoctor!.id, 'date': _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : DateFormat('yyyy-MM-dd').format(DateTime.now())};
      final response = await _authService.getDoctorSlots(request);
      if (response != null && response['slots'] != null) {
        final slotsList = List<Map<String, dynamic>>.from(response['slots']).map((slotData) => SlotModel.fromJson(slotData)).toList();
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

  Future<void> _bookAppointment() async {
    if (_selectedDate == null || _selectedSlot == null || _selectedDoctor == null || _selectedService == null) {
      toaster.error('Please complete all required fields');
      return;
    }
    try {
      setState(() => _isProcessing = true);
      final userData = await read(AppSession.userData);
      final bookingData = {
        'doctorId': _selectedDoctor!.id,
        'slotId': _selectedSlot!.id,
        'serviceId': _selectedService!.id,
        'appointmentDate': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'appointmentTime': _formatTimeForAPI(_selectedSlot!.startTime),
        'consultationType': 'in-person',
        'notes': 'Appointment booked by ${userData["name"]}',
        'symptoms': [],
      };
      final response = await _authService.bookAppointment(bookingData);
      if (response != null) {
        _showBookingSuccess();
      }
    } catch (error) {
      toaster.error('Booking error: $error');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  String _formatTimeForAPI(DateTime time) {
    return DateFormat('HH:MM').format(time.toLocal());
  }

  void _showBookingSuccess() {
    Get.back();
    toaster.success(
      'Appointment Booked Successfully! 🎉\n'
      '${_selectedService!.name} with ${_selectedDoctor!.name}\n'
      'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}\n'
      'Time: ${_formatTimeSlot(_selectedSlot!.startTime, _selectedSlot!.endTime)}',
    );
  }

  String _formatTimeSlot(DateTime startTime, DateTime endTime) {
    final startFormat = DateFormat('hh:mm a');
    final endFormat = DateFormat('hh:mm a');
    return '${startFormat.format(startTime.toLocal())} - ${endFormat.format(endTime.toLocal())}';
  }

  void _onDoctorSelected(DoctorModel? doctor) {
    setState(() {
      _selectedService = ServiceModel.fromApi(doctor?.service);
      if (_selectedService != null) {
        _availableServices = [_selectedService!];
      }
      _selectedDoctor = doctor;
      _selectedSlot = null;
      _availableSlots = [];
    });
    if (doctor != null) {
      _loadAvailableSlots();
    }
  }

  void _onServiceSelected(ServiceModel? service) {
    setState(() => _selectedService = service);
  }

  double get _totalAmount {
    return _selectedDoctor?.consultationFee ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Book Appointment',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
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
      body: _isProcessing || _isLoadingData
          ? _buildLoadingState()
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDoctorSelection(),
                  const SizedBox(height: 20),
                  _buildServiceSelection(),
                  const SizedBox(height: 20),
                  _buildDateSelection(),
                  if (_selectedDoctor != null) ...[const SizedBox(height: 20), _buildTimeSelection()],
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: _buildBookButton(),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildDoctorSelectionShimmer(),
          const SizedBox(height: 20),
          _buildServiceSelectionShimmer(),
          const SizedBox(height: 20),
          _buildDateSelectionShimmer(),
          const SizedBox(height: 20),
          _buildTimeSelectionShimmer(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildServiceSelectionShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 100,
                  height: 18,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSelectionShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 100,
                  height: 18,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectionShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 80,
                  height: 18,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelectionShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 120,
                  height: 18,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                6,
                (index) => Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services_rounded, color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select Service',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.emergencyRed.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(
                  'Required',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.emergencyRed),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_availableServices.isEmpty) _buildEmptyState('No services available', Icons.medical_services_outlined),
          if (_availableServices.isNotEmpty) _buildServiceSelector(),
        ],
      ),
    );
  }

  Widget _buildServiceSelector() {
    return _availableServices.length == 1 ? _buildSelectedServiceCard(_availableServices.first) : _buildServiceDropdown();
  }

  Widget _buildServiceDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _selectedService != null ? AppTheme.primaryTeal.withOpacity(0.3) : AppTheme.borderColor, width: _selectedService != null ? 2 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showServiceSelectionDialog(),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.medical_services_rounded, color: _selectedService != null ? AppTheme.primaryTeal : AppTheme.textLight, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedService != null ? _selectedService!.name : 'Choose a service',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: _selectedService != null ? AppTheme.textPrimary : AppTheme.textLight),
                      ),
                      if (_selectedService != null) ...[const SizedBox(height: 4), Text(_selectedService!.category, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary))],
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded, color: _selectedService != null ? AppTheme.primaryTeal : AppTheme.textSecondary, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showServiceSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services_rounded, color: AppTheme.primaryTeal, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Select Service',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _availableServices.length,
                    itemBuilder: (context, index) {
                      final service = _availableServices[index];
                      final isSelected = _selectedService?.id == service.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryTeal.withOpacity(0.1) : AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AppTheme.primaryTeal : Colors.transparent, width: 2),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _onServiceSelected(service);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: isSelected ? AppTheme.primaryTeal : AppTheme.backgroundLight, borderRadius: BorderRadius.circular(8)),
                                    child: Icon(Icons.medical_services_rounded, color: isSelected ? Colors.white : AppTheme.primaryTeal, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.name,
                                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(service.category, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  if (isSelected) Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedServiceCard(ServiceModel service) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.medical_services_rounded, color: AppTheme.primaryTeal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(service.category, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_rounded, color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select Doctor',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.emergencyRed.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(
                  'Required',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.emergencyRed),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_availableDoctors.isEmpty) _buildEmptyState('No doctors available', Icons.person_outline_rounded),
          if (_availableDoctors.isNotEmpty) _buildDoctorSelector(),
        ],
      ),
    );
  }

  Widget _buildDoctorSelector() {
    return _availableDoctors.length == 1 ? _buildSelectedDoctorCard(_availableDoctors.first) : _buildDoctorDropdown();
  }

  Widget _buildDoctorDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _selectedDoctor != null ? AppTheme.primaryTeal.withOpacity(0.3) : AppTheme.borderColor, width: _selectedDoctor != null ? 2 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showDoctorSelectionDialog(),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
                  ),
                  child: ClipOval(
                    child: _selectedDoctor != null && _selectedDoctor!.profileImage != null && _selectedDoctor!.profileImage!.isNotEmpty
                        ? Image.network(helper.getAWSImage(_selectedDoctor!.profileImage!), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildDefaultDoctorImage())
                        : _buildDefaultDoctorImage(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedDoctor != null ? _selectedDoctor!.name : 'Choose a doctor',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: _selectedDoctor != null ? AppTheme.textPrimary : AppTheme.textLight),
                      ),
                      if (_selectedDoctor != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '₹${_selectedDoctor!.consultationFee.toStringAsFixed(0)} consultation fee',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded, color: _selectedDoctor != null ? AppTheme.primaryTeal : AppTheme.textSecondary, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDoctorSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_rounded, color: AppTheme.primaryTeal, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Select Doctor',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _availableDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _availableDoctors[index];
                      final isSelected = _selectedDoctor?.id == doctor.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryTeal.withOpacity(0.1) : AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AppTheme.primaryTeal : Colors.transparent, width: 2),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _onDoctorSelected(doctor);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
                                    ),
                                    child: ClipOval(
                                      child: doctor.profileImage != null && doctor.profileImage!.isNotEmpty
                                          ? Image.network(helper.getAWSImage(doctor.profileImage!), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildDefaultDoctorImage())
                                          : _buildDefaultDoctorImage(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doctor.name,
                                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₹${doctor.consultationFee.toStringAsFixed(0)} consultation fee',
                                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected) Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDoctorCard(DoctorModel doctor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
            ),
            child: ClipOval(
              child: doctor.profileImage != null && doctor.profileImage!.isNotEmpty
                  ? Image.network(helper.getAWSImage(doctor.profileImage!), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildDefaultDoctorImage())
                  : _buildDefaultDoctorImage(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${doctor.consultationFee.toStringAsFixed(0)} consultation fee',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultDoctorImage() {
    return Container(
      color: AppTheme.backgroundLight,
      child: const Icon(Icons.person, color: AppTheme.textLight, size: 24),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppTheme.textLight),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select Date',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.emergencyRed.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(
                  'Required',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.emergencyRed),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                if (_selectedDoctor != null) {
                  _loadAvailableSlots();
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedDate != null ? AppTheme.primaryTeal.withOpacity(0.3) : AppTheme.borderColor, width: _selectedDate != null ? 2 : 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: _selectedDate != null ? AppTheme.primaryTeal : AppTheme.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Appointment Date', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                        const SizedBox(height: 2),
                        Text(
                          _selectedDate != null ? DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate!) : 'Choose a date',
                          style: GoogleFonts.inter(fontSize: 14, color: _selectedDate != null ? AppTheme.textPrimary : AppTheme.textLight, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.calendar_month_rounded, color: _selectedDate != null ? AppTheme.primaryTeal : AppTheme.textSecondary, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select Time Slot',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.emergencyRed.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(
                  'Required',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.emergencyRed),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedDate == null) _buildEmptyState('Please select a date first', Icons.calendar_today_rounded),
          if (_selectedDate != null && _isLoadingSlots) _buildLoadingSlots(),
          if (_selectedDate != null && !_isLoadingSlots && _availableSlots.isEmpty) _buildEmptyState('No available slots for selected date', Icons.schedule_rounded),
          if (_selectedDate != null && !_isLoadingSlots && _availableSlots.isNotEmpty) _buildSlotsGrid(),
        ],
      ),
    );
  }

  Widget _buildLoadingSlots() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal)),
            const SizedBox(height: 8),
            Text('Loading available slots...', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available time slots for ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
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

        // Selected Slot Info
        if (_selectedSlot != null) ...[
          const SizedBox(height: 16),
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

  Widget _buildBookButton() {
    final isFormValid = _selectedDate != null && _selectedSlot != null && _selectedDoctor != null && _selectedService != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Amount', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  Text(
                    '₹${_totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isFormValid ? _bookAppointment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.textLight.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shadowColor: AppTheme.primaryTeal.withOpacity(0.3),
                ),
                child: _isProcessing
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text('Confirm Booking', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
