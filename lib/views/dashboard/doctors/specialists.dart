import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/doctor_model.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/dashboard/doctors/specialists_ctrl.dart';
import 'package:prime_health_patients/views/dashboard/doctors/ui/doctor_details.dart';

class SpecialistsList extends StatelessWidget {
  SpecialistsList({super.key});

  final SpecialistsCtrl ctrl = Get.put(SpecialistsCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(child: _buildDoctorsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Get.back()),
              const SizedBox(width: 8),
              Text(
                'Top Specialists',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              Obx(() => Text('${ctrl.filteredDoctors.length} doctors', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary))),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
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
                      )
                    : SizedBox.shrink(),
              ),
              filled: true,
              fillColor: AppTheme.backgroundLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            style: GoogleFonts.inter(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ctrl.specializations.length,
              itemBuilder: (context, index) {
                final specialization = ctrl.specializations[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(specialization, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                    selected: ctrl.selectedSpecialization.value == specialization,
                    onSelected: (selected) => ctrl.onSpecializationChanged(specialization),
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.primaryTeal.withOpacity(0.1),
                    checkmarkColor: AppTheme.primaryTeal,
                    labelStyle: TextStyle(color: ctrl.selectedSpecialization.value == specialization ? AppTheme.primaryTeal : AppTheme.textSecondary),
                    side: BorderSide(color: ctrl.selectedSpecialization.value == specialization ? AppTheme.primaryTeal : AppTheme.borderColor),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Sort by:',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Obx(
                () => DropdownButton<String>(
                  value: ctrl.sortBy.value,
                  icon: Icon(Icons.arrow_drop_down_rounded, color: AppTheme.primaryTeal),
                  underline: const SizedBox(),
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                  onChanged: (value) => ctrl.onSortChanged(value!),
                  items: [_buildSortItem('Rating', 'rating'), _buildSortItem('Experience', 'experience'), _buildSortItem('Fee: Low to High', 'fee'), _buildSortItem('Distance', 'distance')],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: ctrl.clearFilters,
                style: TextButton.styleFrom(foregroundColor: AppTheme.primaryTeal, padding: EdgeInsets.zero),
                child: Text('Clear Filters', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> _buildSortItem(String text, String value) {
    return DropdownMenuItem(value: value, child: Text(text));
  }

  Widget _buildDoctorsList() {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (ctrl.filteredDoctors.isEmpty) {
        return _buildEmptyState();
      }
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: ctrl.filteredDoctors.length,
        itemBuilder: (context, index) {
          final doctor = ctrl.filteredDoctors[index];
          return _buildDoctorCard(doctor);
        },
      );
    });
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => DoctorDetails(doctor: doctor)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorImage(doctor),
                const SizedBox(width: 12),
                Expanded(child: _buildDoctorInfo(doctor)),
                _buildFavoriteButton(doctor),
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
            border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2), width: 2),
          ),
          child: ClipOval(
            child: Image.network(
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
                  color: AppTheme.backgroundLight,
                  child: Icon(Icons.person, color: AppTheme.textLight, size: 30),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: doctor.isAvailable ? AppTheme.successGreen : AppTheme.emergencyRed,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorInfo(DoctorModel doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          doctor.name,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(doctor.specialization, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(doctor.ratingText, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(width: 12),
            Icon(Icons.work_outline_rounded, color: AppTheme.textLight, size: 14),
            const SizedBox(width: 4),
            Text(doctor.experienceText, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: AppTheme.textLight, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                doctor.clinicName,
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(
                doctor.feeText,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Text(doctor.distanceText, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFavoriteButton(DoctorModel doctor) {
    return Obx(() {
      final isFavorite = ctrl.doctors.firstWhere((d) => d.id == doctor.id).isFavorite;
      return IconButton(
        onPressed: () => ctrl.toggleFavorite(doctor.id),
        icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFavorite ? AppTheme.emergencyRed : AppTheme.textLight, size: 24),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: AppTheme.textLight),
          const SizedBox(height: 16),
          Text(
            'No Doctors Found',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text('Try adjusting your filters or search terms', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: ctrl.clearFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Clear Filters', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
