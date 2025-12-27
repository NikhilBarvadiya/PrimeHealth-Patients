import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prime_health_patients/models/appointment_model.dart';
import 'package:prime_health_patients/models/calling_model.dart';
import 'package:prime_health_patients/models/slot_model.dart';
import 'package:prime_health_patients/models/review_model.dart';
import 'package:prime_health_patients/models/user_model.dart';
import 'package:prime_health_patients/service/calling_service.dart';
import 'package:prime_health_patients/utils/config/session.dart';
import 'package:prime_health_patients/utils/helper.dart';
import 'package:prime_health_patients/utils/storage.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/dashboard/appointments/ui/calling_view.dart';
import 'package:prime_health_patients/views/dashboard/doctors/doctor_details/doctor_details_ctrl.dart';
import 'package:shimmer/shimmer.dart';

class DoctorDetails extends StatefulWidget {
  final String doctorId;

  const DoctorDetails({super.key, required this.doctorId});

  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> {
  final DoctorDetailsCtrl ctrl = Get.put(DoctorDetailsCtrl());

  @override
  void initState() {
    super.initState();
    ctrl.loadDoctorDetails(widget.doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return _buildLoadingState();
        }
        return CustomScrollView(
          physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildBasicInfo(), const SizedBox(height: 24), _buildTabBar(), const SizedBox(height: 20), _buildTabContent(), const SizedBox(height: 32)],
                ),
              ),
            ),
            _buildBookButton(),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        _buildAppBarShimmer(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildBasicInfoShimmer(), const SizedBox(height: 24), _buildTabBarShimmer(), const SizedBox(height: 20), _buildTabContentShimmer(), const SizedBox(height: 32)],
            ),
          ),
        ),
        _buildBookButtonShimmer(),
      ],
    );
  }

  SliverAppBar _buildAppBarShimmer() {
    return SliverAppBar(
      expandedHeight: 300,
      flexibleSpace: FlexibleSpaceBar(
        background: Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Container(color: Colors.white),
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
        onPressed: () => Get.close(1),
      ),
      actions: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Obx(
              () => Image.network(
                helper.getAWSImage(ctrl.doctor.value.profileImage.toString()),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade50,
                    child: Container(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    child: Icon(Icons.person, color: AppTheme.primaryTeal, size: 80),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.6), Colors.transparent]),
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
          backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
        ),
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryLight, size: 20),
        onPressed: () => Get.close(1),
      ),
      actions: [
        IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
          ),
          icon: Icon(CupertinoIcons.phone, color: AppTheme.primaryLight, size: 20),
          onPressed: () => _onCallAction(context, CallType.voice),
        ),
        IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
          ),
          icon: Icon(Icons.videocam_rounded, color: AppTheme.primaryLight, size: 20),
          onPressed: () => _onCallAction(context, CallType.video),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildBasicInfoShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 28,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 18,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 100,
                height: 32,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ctrl.doctor.value.name,
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          ctrl.doctor.value.email,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: ctrl.doctor.value.isAvailable ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.emergencyRed.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: ctrl.doctor.value.isAvailable ? AppTheme.successGreen : AppTheme.emergencyRed, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ctrl.doctor.value.isAvailable ? 'Available' : 'Not Available',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: ctrl.doctor.value.isAvailable ? AppTheme.successGreen : AppTheme.emergencyRed),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              '₹${ctrl.doctor.value.consultationFee.toStringAsFixed(0)}',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
            ),
            Text('/consultation', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBarShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        height: 48,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [_buildTab(0, 'About'), _buildTab(1, 'Availability'), _buildTab(2, 'Reviews')]),
    );
  }

  Widget _buildTabContentShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 20,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 14,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 24),
          Container(
            width: 80,
            height: 20,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              4,
              (index) => Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String text) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ctrl.changeTab(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: ctrl.selectedTab.value == index ? AppTheme.primaryTeal : Colors.transparent, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                text,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: ctrl.selectedTab.value == index ? Colors.white : AppTheme.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Obx(() {
      switch (ctrl.selectedTab.value) {
        case 0:
          return _buildAboutTab();
        case 1:
          return _buildAvailabilityTab();
        case 2:
          return _buildReviewsTab();
        default:
          return _buildAboutTab();
      }
    });
  }

  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ctrl.doctor.value.bio.isNotEmpty) ...[
          Text(
            'About',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(ctrl.doctor.value.bio, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
          const SizedBox(height: 20),
        ],
        if (ctrl.doctor.value.services.isNotEmpty) ...[
          Text(
            'Services',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: ctrl.doctor.value.services.map((service) => _buildServiceChip(service)).toList()),
          const SizedBox(height: 20),
        ],
        _buildStatsSection(),
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

  Widget _buildStatsSection() {
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
          _buildStatItem('${ctrl.doctor.value.consultationCount}+', 'Patients'),
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

  Widget _buildAvailabilityTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Slots',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (ctrl.isLoading.value) {
            return _buildSlotsShimmer();
          }
          if (ctrl.availableSlots.isEmpty) {
            return _buildEmptyState('No available slots for today');
          }
          return Column(children: ctrl.availableSlots.map((slot) => _buildSlotItem(slot)).toList());
        }),
      ],
    );
  }

  Widget _buildSlotsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
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
                  width: 70,
                  height: 24,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlotItem(SlotModel slot) {
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
                Text(ctrl.formatTimeSlot(slot.startTime, slot.endTime), style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(
              'Available',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
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
                    Text('${ctrl.totalReviews.value} reviews', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
            const Spacer(),
            _buildRatingProgress(),
          ],
        ),
        const SizedBox(height: 20),
        Obx(() {
          if (ctrl.isLoading.value) {
            return _buildReviewsShimmer();
          }
          if (ctrl.reviews.isEmpty) {
            return _buildEmptyState('No reviews yet');
          }
          return Column(children: ctrl.reviews.map((review) => _buildReviewItem(review)).toList());
        }),
      ],
    );
  }

  Widget _buildReviewsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 14,
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
                      height: 12,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 200,
                  height: 14,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
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
      decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: review.patientImage.isNotEmpty ? NetworkImage(helper.getAWSImage(review.patientImage)) : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
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
                        Text(review.rating.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              Text(DateFormat('MMM dd, yyyy').format(review.date), style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
            ],
          ),
          const SizedBox(height: 8),
          if (review.review.isNotEmpty) ...[Text(review.review, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.4))],
        ],
      ),
    );
  }

  Widget _buildBookButtonShimmer() {
    return SliverToBoxAdapter(
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          height: 56,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => ctrl.bookService(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
              shadowColor: AppTheme.primaryTeal.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 18),
                const SizedBox(width: 8),
                Text('Book Appointment', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
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

  _onCallAction(BuildContext context, CallType callType) async {
    if (ctrl.doctor.value.fcm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token is missing...!')));
      return;
    }
    final userData = await read(AppSession.userData);
    if (userData != null) {
      UserModel userModel = UserModel(id: userData["_id"] ?? '', fcm: userData["fcm"] ?? '', name: userData["name"] ?? 'Dr. John Smith', email: '', mobileNo: '', address: {});
      String channelName = "${userModel.id}_${ctrl.doctor.value.id}_${DateTime.now().millisecondsSinceEpoch}";
      CallData callData = CallData(senderId: userModel.id, senderName: userModel.name, senderFCMToken: userModel.fcm, callType: callType, status: CallStatus.calling, channelName: channelName);
      if (context.mounted) {
        final receiver = AppointmentModel(id: ctrl.doctor.value.id, fcmToken: ctrl.doctor.value.fcm, doctorName: ctrl.doctor.value.name);
        CallingService().makeCall(receiver, callData);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CallingView(channelName: channelName, callType: callType, receiver: receiver, sender: userModel);
            },
          ),
        );
      }
    }
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
}
