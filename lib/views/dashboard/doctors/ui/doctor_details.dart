import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/appointment_model.dart';
import 'package:prime_health_patients/models/calling_model.dart';
import 'package:prime_health_patients/models/doctor_model.dart';
import 'package:prime_health_patients/models/service_model.dart';
import 'package:prime_health_patients/models/user_model.dart';
import 'package:prime_health_patients/service/calling_service.dart';
import 'package:prime_health_patients/utils/config/session.dart';
import 'package:prime_health_patients/utils/storage.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/calling_view.dart';
import 'package:prime_health_patients/views/dashboard/doctors/specialists_ctrl.dart';
import 'package:prime_health_patients/views/dashboard/services/ui/slot_selection.dart';

class DoctorDetails extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorDetails({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final SpecialistsCtrl ctrl = Get.isRegistered<SpecialistsCtrl>() ? Get.find<SpecialistsCtrl>() : Get.put(SpecialistsCtrl());

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    doctor.image,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppTheme.backgroundLight,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                        child: Icon(Icons.person, color: AppTheme.primaryTeal, size: 80),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.6), Colors.transparent]),
                    ),
                  ),
                ],
              ),
              title: Text(
                doctor.name,
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ),
            pinned: true,
            leading: IconButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
              ),
              icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
              onPressed: () => Get.back(),
            ),
            actions: [
              Obx(() {
                if (ctrl.isLoading.value == true) return SizedBox.shrink();
                final isFavorite = ctrl.doctors.firstWhere((d) => d.id == doctor.id).isFavorite;
                return IconButton(
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                    backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
                  ),
                  icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFavorite ? AppTheme.emergencyRed : AppTheme.textSecondary, size: 20),
                  onPressed: () => ctrl.toggleFavorite(doctor.id),
                );
              }),
              SizedBox(width: 6),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                  _buildEducationSection(),
                  const SizedBox(height: 24),
                  _buildServicesSection(),
                  const SizedBox(height: 24),
                  _buildAvailabilitySection(),
                  const SizedBox(height: 24),
                  _buildStatsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: Row(
          spacing: 10.0,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => onCallAction(context, CallType.voice),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryTeal,
                  side: BorderSide(color: AppTheme.primaryTeal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Icon(Icons.call),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                onPressed: () => onCallAction(context, CallType.video),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryTeal,
                  side: BorderSide(color: AppTheme.primaryTeal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Icon(Icons.video_call_rounded),
              ),
            ),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  ServiceModel serviceModel = ServiceModel(
                    id: doctor.id.length,
                    name: doctor.name,
                    description: doctor.patientsTreatedText,
                    icon: Icons.healing,
                    isActive: false,
                    rate: 1400.0,
                    category: "",
                  );
                  Get.to(() => SlotSelection(service: serviceModel));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Book Appointment', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onCallAction(BuildContext context, CallType callType) async {
    AppointmentModel appointmentModel = AppointmentModel(id: doctor.id, doctorName: doctor.name, fcmToken: doctor.fcmToken);
    if (appointmentModel.fcmToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token is missing...!')));
      return;
    }
    final userData = await read(AppSession.userData);
    if (userData != null) {
      UserModel userModel = UserModel(id: "1", name: userData["name"] ?? 'Dr. John Smith', fcmToken: userData["fcmToken"] ?? '', email: '', mobile: '', password: '', city: '', state: '', address: '');
      String channelName = "${userModel.id}_${doctor.id}_${DateTime.now().millisecondsSinceEpoch}";
      CallData callData = CallData(senderId: userModel.id, senderName: userModel.name, senderFCMToken: userModel.fcmToken, callType: callType, status: CallStatus.calling, channelName: channelName);
      CallingService().makeCall(appointmentModel.fcmToken, callData);
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CallingView(channelName: channelName, callType: callType, receiver: appointmentModel, sender: userModel);
            },
          ),
        );
      }
    }
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          doctor.name,
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          doctor.specialization,
          style: GoogleFonts.inter(fontSize: 16, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildInfoItem(Icons.star_rounded, Colors.amber, doctor.rating.toString()),
            _buildInfoItem(Icons.work_outline_rounded, AppTheme.textSecondary, doctor.experienceText),
            _buildInfoItem(Icons.people_outline_rounded, AppTheme.textSecondary, '${doctor.totalReviews} reviews'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: AppTheme.textLight, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(doctor.clinicAddress, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, Color color, String text) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Doctor',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        Text(doctor.about, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [_buildChip('Languages: ${doctor.languagesText}'), _buildChip(doctor.treatmentApproachesText)]),
      ],
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryTeal, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Education & Certification',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        if (doctor.education.isNotEmpty) ...[Column(crossAxisAlignment: CrossAxisAlignment.start, children: doctor.education.map((edu) => _buildListItem(edu)).toList()), const SizedBox(height: 8)],
        if (doctor.certifications.isNotEmpty) ...[
          Text(
            'Certifications:',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Wrap(spacing: 8, runSpacing: 4, children: doctor.certifications.map((cert) => _buildChip(cert)).toList()),
        ],
      ],
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: AppTheme.primaryTeal, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services Offered',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: doctor.services.map((service) => _buildServiceChip(service)).toList()),
      ],
    );
  }

  Widget _buildServiceChip(String service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Text(
        service,
        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        if (doctor.availableDays.isEmpty) ...[
          Text('No availability scheduled', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
        ] else ...[
          Column(children: doctor.availableDays.map((day) => _buildDayAvailability(day)).toList()),
        ],
      ],
    );
  }

  Widget _buildDayAvailability(String day) {
    final slots = doctor.getTimeSlotsForDay(day);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              day,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ),
          Expanded(child: Wrap(spacing: 8, runSpacing: 4, children: slots.map((slot) => _buildTimeSlot(slot)).toList())),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(
        time,
        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryTeal, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.1)),
      ),
      child: Column(
        spacing: 10.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatItem(doctor.successRateText, 'Success Rate'),
          _buildStatItem(doctor.patientsTreatedText, 'Patients Treated'),
          _buildStatItem('${doctor.stats['surgeriesPerformed'] ?? 0}+', 'Surgeries'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}
