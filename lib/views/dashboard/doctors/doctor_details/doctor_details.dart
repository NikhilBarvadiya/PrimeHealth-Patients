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
import 'package:prime_health_patients/views/dashboard/doctors/doctor_details_ctrl.dart';
import 'package:prime_health_patients/views/dashboard/services/ui/slot_selection.dart';
import 'package:intl/intl.dart';

class DoctorDetails extends StatelessWidget {
  final String doctorId;

  const DoctorDetails({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    final DoctorDetailsCtrl ctrl = Get.put(DoctorDetailsCtrl());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return _buildLoadingState();
        }
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(ctrl),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfo(ctrl),
                    const SizedBox(height: 24),
                    _buildTabBar(ctrl),
                    const SizedBox(height: 20),
                    _buildTabContent(ctrl),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomBar(ctrl),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  SliverAppBar _buildAppBar(DoctorDetailsCtrl ctrl) {
    return SliverAppBar(
      expandedHeight: 300,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Obx(() => Image.network(
              ctrl.doctor.value.image.isNotEmpty ? ctrl.doctor.value.image : 'https://via.placeholder.com/300',
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
            )),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
      pinned: true,
      leading: IconButton(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
          backgroundColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.9)),
        ),
        icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.9)),
          ),
          icon: Obx(() => Icon(
            ctrl.doctor.value.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: ctrl.doctor.value.isFavorite ? AppTheme.emergencyRed : AppTheme.textSecondary,
            size: 20,
          )),
          onPressed: () {
            // Implement favorite functionality
          },
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildBasicInfo(DoctorDetailsCtrl ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ctrl.doctor.value.name,
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          ctrl.doctor.value.specialization,
          style: GoogleFonts.inter(fontSize: 16, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildInfoItem(Icons.star_rounded, Colors.amber, ctrl.doctor.value.rating.toStringAsFixed(1)),
            _buildInfoItem(Icons.work_outline_rounded, AppTheme.textSecondary, '${ctrl.doctor.value.experience} yrs'),
            _buildInfoItem(Icons.people_outline_rounded, AppTheme.textSecondary, '${ctrl.totalReviews.value} reviews'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: AppTheme.textLight, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                ctrl.doctor.value.clinicName,
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ctrl.doctor.value.isAvailable ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.emergencyRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: ctrl.doctor.value.isAvailable ? AppTheme.successGreen : AppTheme.emergencyRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ctrl.doctor.value.isAvailable ? 'Available Today' : 'Not Available',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ctrl.doctor.value.isAvailable ? AppTheme.successGreen : AppTheme.emergencyRed,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              '\$${ctrl.doctor.value.consultationFee?.toStringAsFixed(0) ?? '0'}',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
            ),
            Text(
              '/consultation',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
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

  Widget _buildTabBar(DoctorDetailsCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab(ctrl, 0, 'About'),
          _buildTab(ctrl, 1, 'Availability'),
          _buildTab(ctrl, 2, 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildTab(DoctorDetailsCtrl ctrl, int index, String text) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ctrl.changeTab(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: ctrl.selectedTab.value == index ? AppTheme.primaryTeal : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ctrl.selectedTab.value == index ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(DoctorDetailsCtrl ctrl) {
    return Obx(() {
      switch (ctrl.selectedTab.value) {
        case 0:
          return _buildAboutTab(ctrl);
        case 1:
          return _buildAvailabilityTab(ctrl);
        case 2:
          return _buildReviewsTab(ctrl);
        default:
          return _buildAboutTab(ctrl);
      }
    });
  }

  Widget _buildAboutTab(DoctorDetailsCtrl ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ctrl.doctor.value.bio.isNotEmpty) ...[
          Text(
            'About',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            ctrl.doctor.value.bio,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 20),
        ],
        if (ctrl.doctor.value.services.isNotEmpty) ...[
          Text(
            'Services',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ctrl.doctor.value.services.map((service) => _buildServiceChip(service)).toList(),
          ),
          const SizedBox(height: 20),
        ],
        _buildStatsSection(ctrl),
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

  Widget _buildStatsSection(DoctorDetailsCtrl ctrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${ctrl.doctor.value.consultationCount ?? 0}+', 'Patients'),
          _buildStatItem('${ctrl.doctor.value.experience}+', 'Years Exp'),
          _buildStatItem(ctrl.doctor.value.rating.toStringAsFixed(1), 'Rating'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildAvailabilityTab(DoctorDetailsCtrl ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Slots',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (ctrl.availableSlots.isEmpty) {
            return _buildEmptyState('No available slots for today');
          }
          return Column(
            children: ctrl.availableSlots.map((slot) => _buildSlotItem(ctrl, slot)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildSlotItem(DoctorDetailsCtrl ctrl, SlotModel slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: AppTheme.primaryTeal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(slot.startTime),
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  ctrl.formatTimeSlot(slot.startTime, slot.endTime),
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Available',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(DoctorDetailsCtrl ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ctrl.averageRating.value.toStringAsFixed(1),
                  style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${ctrl.totalReviews.value} reviews',
                      style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            _buildRatingProgress(ctrl),
          ],
        ),
        const SizedBox(height: 20),
        Obx(() {
          if (ctrl.reviews.isEmpty) {
            return _buildEmptyState('No reviews yet');
          }
          return Column(
            children: ctrl.reviews.map((review) => _buildReviewItem(review)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildRatingProgress(DoctorDetailsCtrl ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // You can add rating distribution here if available from API
        Text(
          'Overall Rating',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              ctrl.averageRating.value.toStringAsFixed(1),
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: review.patientImage.isNotEmpty
                    ? NetworkImage(review.patientImage)
                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.patientName,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(review.date),
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (review.review.isNotEmpty) ...[
            Text(
              review.review,
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.info_outline_rounded, size: 60, color: AppTheme.textLight),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(DoctorDetailsCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _onCallAction(context, CallType.voice, ctrl),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                side: BorderSide(color: AppTheme.primaryTeal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Icon(Icons.call),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _onCallAction(context, CallType.video, ctrl),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                side: BorderSide(color: AppTheme.primaryTeal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Icon(Icons.video_call_rounded),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                ServiceModel serviceModel = ServiceModel(
                  id: ctrl.doctor.value.id,
                  name: ctrl.doctor.value.name,
                  description: ctrl.doctor.value.specialization,
                  icon: Icons.healing,
                  isActive: true,
                  rate: ctrl.doctor.value.consultationFee ?? 0.0,
                  category: ctrl.doctor.value.specialization,
                );
                Get.to(() => SlotSelection(service: serviceModel));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Book Appointment', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _onCallAction(BuildContext context, CallType callType, DoctorDetailsCtrl ctrl) async {
    // Implement your calling logic here
    // This is similar to your existing onCallAction method
  }

  @override
  void onInit() {
    final DoctorDetailsCtrl ctrl = Get.find<DoctorDetailsCtrl>();
    ctrl.loadDoctorDetails(doctorId);
    super.onInit();
  }
}