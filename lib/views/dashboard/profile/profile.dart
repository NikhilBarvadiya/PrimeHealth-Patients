import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prime_health_patients/utils/network/api_config.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/dashboard/dashboard_ctrl.dart';
import 'package:prime_health_patients/views/dashboard/doctors/specialists.dart';
import 'package:prime_health_patients/views/dashboard/profile/profile_ctrl.dart';
import 'package:prime_health_patients/views/dashboard/profile/ui/edit_profile.dart';
import 'package:prime_health_patients/views/dashboard/profile/ui/settings.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileCtrl>(
      init: ProfileCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          body: RefreshIndicator(
            onRefresh: () async => await ctrl.loadUserData(),
            child: Obx(() {
              return CustomScrollView(
                slivers: [
                  _buildSliverAppBar(ctrl, context),
                  if (ctrl.isLoading.value) const SliverToBoxAdapter(child: LinearProgressIndicator()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: Get.height * .1),
                      child: Column(
                        children: [
                          _buildQuickActions(ctrl, context),
                          const SizedBox(height: 20),
                          _buildPersonalInfoCard(ctrl),
                          const SizedBox(height: 16),
                          _buildHealthInfoCard(ctrl),
                          const SizedBox(height: 16),
                          _buildEmergencyContactCard(ctrl),
                          const SizedBox(height: 16),
                          _buildAllergiesCard(ctrl),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(ProfileCtrl ctrl, BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryLight,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final isCollapsed = constraints.biggest.height <= kToolbarHeight + MediaQuery.of(context).padding.top + 20;
          return FlexibleSpaceBar(
            centerTitle: true,
            title: AnimatedOpacity(
              opacity: isCollapsed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                'My Profile',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.primaryLight, AppTheme.primaryTeal]),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProfileAvatar(ctrl),
                    const SizedBox(height: 16),
                    Obx(
                      () => Text(
                        ctrl.user.value.name,
                        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() => Text(ctrl.user.value.email, style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.9)))),
                    const SizedBox(height: 8),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone_rounded, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              ctrl.user.value.mobileNo,
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).paddingOnly(left: 15, right: 15),
              ),
            ),
          );
        },
      ),
      actions: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Icon(Icons.edit, color: Colors.white, size: 22),
          onPressed: () => Get.to(() => const EditProfile()),
          tooltip: 'Edit Profile',
        ),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Icon(Icons.settings_outlined, color: Colors.white, size: 22),
          onPressed: () => Get.to(() => const Settings()),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildProfileAvatar(ProfileCtrl ctrl) {
    return Stack(
      children: [
        Obx(() {
          final hasProfileImage = ctrl.user.value.profileImage?.isNotEmpty ?? false;
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
              image: hasProfileImage ? DecorationImage(image: NetworkImage(APIConfig.imageBaseURL + ctrl.user.value.profileImage!), fit: BoxFit.cover) : null,
            ),
            child: !hasProfileImage ? Icon(Icons.person_rounded, size: 50, color: AppTheme.primaryLight.withOpacity(0.5)) : null,
          );
        }),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => ctrl.pickAvatar(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ProfileCtrl ctrl, BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(icon: Icons.people_alt_rounded, label: 'Top Specialists', color: AppTheme.primaryTeal, onTap: () => Get.to(() => SpecialistsList())),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.calendar_today_rounded,
            label: 'Appointments',
            color: AppTheme.primaryTeal,
            onTap: () {
              DashboardCtrl dashboardCtrl = Get.put(DashboardCtrl());
              dashboardCtrl.changeTab(2);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(ProfileCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.person_outline_rounded, color: AppTheme.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Personal Information',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Obx(() => _buildInfoRow(icon: Icons.location_on_rounded, label: 'Location', value: '${ctrl.user.value.city}, ${ctrl.user.value.state}, ${ctrl.user.value.country}')),
          Obx(
            () => _buildInfoRow(
              icon: Icons.cake_rounded,
              label: 'Date of Birth',
              value: ctrl.user.value.dateOfBirth == null || ctrl.user.value.dateOfBirth!.isEmpty
                  ? 'Not provided'
                  : DateFormat('MMM dd, yyyy').format(DateTime.parse(ctrl.user.value.dateOfBirth.toString())),
            ),
          ),
          Obx(() => _buildInfoRow(icon: Icons.wc_rounded, label: 'Gender', value: ctrl.user.value.gender ?? 'Not provided', isLast: true)),
        ],
      ),
    );
  }

  Widget _buildHealthInfoCard(ProfileCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.favorite_rounded, color: AppTheme.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Health Information',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() => _buildInfoRow(icon: Icons.bloodtype_rounded, label: 'Blood Group', value: ctrl.user.value.bloodGroup ?? 'Not provided', isLast: true)),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard(ProfileCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.phone_in_talk_rounded, color: AppTheme.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Emergency Contact',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() => _buildInfoRow(icon: Icons.person_rounded, label: 'Contact Name', value: ctrl.user.value.emergencyName.isNotEmpty ? ctrl.user.value.emergencyName : 'Not provided')),
          Obx(
            () => _buildInfoRow(icon: Icons.phone_rounded, label: 'Contact Number', value: ctrl.user.value.emergencyMobile.isNotEmpty ? ctrl.user.value.emergencyMobile : 'Not provided', isLast: true),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesCard(ProfileCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.warning_amber_rounded, color: AppTheme.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Allergies',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            final allergies = ctrl.user.value.allergies;
            if (allergies == null || allergies.isEmpty) {
              return Padding(padding: const EdgeInsets.all(20), child: _buildEmptyState('No allergies recorded', Icons.check_circle_outline_rounded));
            }
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allergies.map((allergy) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_rounded, size: 16, color: AppTheme.primaryTeal),
                        const SizedBox(width: 6),
                        Text(
                          allergy.toString(),
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primaryTeal),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value, bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.textSecondary, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 56),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryTeal),
        const SizedBox(width: 12),
        Expanded(
          child: Text(message, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
        ),
      ],
    );
  }
}
