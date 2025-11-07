import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/doctor_model.dart';
import 'package:prime_health_patients/utils/network/api_config.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/dashboard/doctors/doctor_details/doctor_details.dart';
import 'package:prime_health_patients/views/dashboard/doctors/specialists_ctrl.dart';

class SpecialistsList extends StatefulWidget {
  const SpecialistsList({super.key});

  @override
  State<SpecialistsList> createState() => _SpecialistsListState();
}

class _SpecialistsListState extends State<SpecialistsList> {
  final SpecialistsCtrl ctrl = Get.put(SpecialistsCtrl());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      ctrl.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll is ScrollEndNotification && scroll.metrics.pixels == scroll.metrics.maxScrollExtent) {
            ctrl.loadMore();
          }
          return false;
        },
        child: CustomScrollView(controller: _scrollController, physics: const BouncingScrollPhysics(), slivers: [_buildAppBar(), _buildSearchFilter(), _buildContent()]),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      elevation: 0,
      toolbarHeight: 80,
      backgroundColor: Colors.white,
      pinned: true,
      floating: true,
      leading: IconButton(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
          backgroundColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.9)),
        ),
        icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Specialists',
              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text('${ctrl.filteredDoctors.length} ${ctrl.filteredDoctors.length == 1 ? 'doctor' : 'doctors'} available', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
              backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
            ),
            icon: const Icon(Icons.refresh, color: Colors.black87, size: 22),
            onPressed: () => ctrl.retry(),
            tooltip: 'Refresh doctors',
          ),
        ),
      ],
    );
  }

  Widget _buildSearchFilter() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: TextField(
                onChanged: ctrl.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search doctors, specialties...',
                  hintStyle: GoogleFonts.inter(color: AppTheme.textLight),
                  prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                  suffixIcon: Obx(
                    () => ctrl.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                            onPressed: () => ctrl.onSearchChanged(''),
                            tooltip: 'Clear search',
                          )
                        : const SizedBox.shrink(),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: GoogleFonts.inter(fontSize: 13),
                textInputAction: TextInputAction.search,
              ),
            ),
            Obx(() {
              if (ctrl.categories.isEmpty) {
                return SizedBox.shrink();
              }
              return SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: ctrl.categories.length,
                  itemBuilder: (context, index) {
                    final cat = ctrl.categories[index];
                    final isSelected = ctrl.selectedCategoryId.value == cat.id;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                        selected: isSelected,
                        onSelected: (_) {
                          ctrl.filterByCategory(cat.id);
                          setState(() {});
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppTheme.primaryTeal.withOpacity(0.1),
                        checkmarkColor: AppTheme.primaryTeal,
                        labelStyle: TextStyle(color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary),
                        side: BorderSide(color: isSelected ? AppTheme.primaryTeal : AppTheme.borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                ),
              ).paddingOnly(top: 16);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.doctors.isEmpty) {
        return SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
      }
      if (ctrl.filteredDoctors.isEmpty) {
        return SliverFillRemaining(child: _buildEmptyState());
      }
      return _buildDoctorsList();
    });
  }

  Widget _buildDoctorsList() {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= ctrl.filteredDoctors.length) {
            return _buildLoadMoreIndicator();
          }
          final doctor = ctrl.filteredDoctors[index];
          return _buildDoctorCard(doctor).paddingOnly(bottom: 12);
        }, childCount: ctrl.filteredDoctors.length + (ctrl.hasMore.value ? 1 : 0)),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(
      () => ctrl.isLoadingMore.value
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => DoctorDetails(doctorId: doctor.id)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorImage(doctor),
                const SizedBox(width: 16),
                Expanded(child: _buildDoctorInfo(doctor)),
                _buildAvailabilityIndicator(doctor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorImage(DoctorModel doctor) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.primaryTeal.withOpacity(0.2), AppTheme.primaryTeal.withOpacity(0.1)]),
            border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3), width: 2),
          ),
          child: ClipOval(
            child: Image.network(
              APIConfig.resourceBaseURL + doctor.profileImage.toString(),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppTheme.backgroundLight,
                  child: const Center(child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(strokeWidth: 2))),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.backgroundLight,
                  child: Icon(Icons.person_rounded, color: AppTheme.textLight, size: 36),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: doctor.isAvailable ? AppTheme.successGreen : AppTheme.emergencyRed,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorInfo(DoctorModel doctor) {
    int index = ctrl.categories.indexWhere((e) => e.id == doctor.specialty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                doctor.name,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(index != -1 ? ctrl.categories[index].name.toString() : "Other", style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              doctor.rating.toStringAsFixed(1),
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
            ),
            const SizedBox(width: 12),
            Icon(Icons.work_outline_rounded, color: AppTheme.textLight, size: 14),
            const SizedBox(width: 4),
            Text(doctor.experienceText, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: AppTheme.textLight, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                doctor.displayClinicName,
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(
                doctor.formattedFee,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
              ),
            ),
            const SizedBox(width: 8),
            if (doctor.distance != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_walk_rounded, size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('${doctor.distance!.toStringAsFixed(1)} km', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAvailabilityIndicator(DoctorModel doctor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: doctor.isAvailable ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.emergencyRed.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(
            doctor.isAvailable ? 'Available' : 'Busy',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: doctor.isAvailable ? AppTheme.successGreen : AppTheme.emergencyRed),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off_rounded, size: 80, color: AppTheme.textLight),
        const SizedBox(height: 16),
        Text(
          'No Doctors Found',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          'Try adjusting your filters or search terms',
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
