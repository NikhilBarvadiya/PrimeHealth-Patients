import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/doctor_model.dart';
import 'package:prime_health_patients/utils/decoration.dart';
import 'package:prime_health_patients/utils/helper.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/dashboard/doctors/doctor_details/doctor_details.dart';
import 'package:prime_health_patients/views/dashboard/doctors/specialists_ctrl.dart';
import 'package:shimmer/shimmer.dart';

class SpecialistsList extends StatefulWidget {
  const SpecialistsList({super.key});

  @override
  State<SpecialistsList> createState() => _SpecialistsListState();
}

class _SpecialistsListState extends State<SpecialistsList> {
  final SpecialistsCtrl ctrl = Get.put(SpecialistsCtrl());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

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
        child: CustomScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [_buildAppBar(), _buildContent()],
        ),
      ),
      floatingActionButton: Obx(
        () => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_available_rounded, size: 16, color: ctrl.showAvailableOnly.value ? AppTheme.successGreen : AppTheme.textLight),
                const SizedBox(width: 6),
                Text(
                  'Available Now',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ctrl.showAvailableOnly.value ? AppTheme.successGreen : AppTheme.textSecondary,
                    fontWeight: ctrl.showAvailableOnly.value ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: ctrl.showAvailableOnly.value,
                    onChanged: ctrl.toggleAvailabilityFilter,
                    activeColor: AppTheme.successGreen,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      elevation: 0,
      toolbarHeight: 65,
      pinned: true,
      floating: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppTheme.primaryLight,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Specialists',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Obx(() {
            return Text('${ctrl.filteredDoctors.length} ${ctrl.filteredDoctors.length == 1 ? 'doctor' : 'doctors'} available', style: GoogleFonts.inter(fontSize: 14, color: Colors.white));
          }),
        ],
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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
              backgroundColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.2)),
            ),
            icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
            onPressed: () => ctrl.retry(),
            tooltip: 'Refresh doctors',
          ),
        ),
      ],
      bottom: PreferredSize(preferredSize: const Size.fromHeight(119), child: _buildSearchFilter()),
    );
  }

  Widget _buildSearchFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: TextField(
              controller: searchController,
              onChanged: ctrl.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search doctors, specialties...',
                hintStyle: GoogleFonts.inter(color: AppTheme.textLight),
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                suffixIcon: Obx(
                  () => ctrl.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                          onPressed: () {
                            searchController.clear();
                            ctrl.onSearchChanged('');
                          },
                          tooltip: 'Clear search',
                        )
                      : const SizedBox.shrink(),
                ),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: decoration.colorScheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: GoogleFonts.inter(fontSize: 14),
              textInputAction: TextInputAction.search,
            ),
          ),
          Obx(() {
            if (ctrl.categories.isEmpty) {
              return SizedBox(
                height: 40,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: List.generate(
                    6,
                    (index) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      ),
                    ).paddingOnly(right: 10),
                  ).toList(),
                ),
              ).paddingOnly(top: 10);
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
            ).paddingOnly(top: 10);
          }),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.doctors.isEmpty) {
        return SliverList(delegate: SliverChildBuilderDelegate((context, index) => _buildDoctorShimmerCard(), childCount: 6));
      }
      if (ctrl.filteredDoctors.isEmpty) {
        return SliverFillRemaining(child: _buildEmptyState());
      }
      return _buildDoctorsList();
    });
  }

  Widget _buildDoctorsList() {
    return SliverPadding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: Get.height * .1),
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
              child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
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
              helper.getAWSImage(doctor.profileImage.toString()),
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

  Widget _buildDoctorShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 12,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 24,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 70,
                          height: 24,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 50,
                height: 20,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
              ),
            ],
          ),
        ),
      ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Try adjusting your filters or search terms',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
