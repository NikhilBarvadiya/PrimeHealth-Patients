import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/dashboard/appointments/appointments.dart';
import 'package:prime_health_patients/views/dashboard/dashboard_ctrl.dart';
import 'package:prime_health_patients/views/dashboard/home/home.dart';
import 'package:prime_health_patients/views/dashboard/profile/profile.dart';
import 'package:prime_health_patients/views/dashboard/services/services.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardCtrl>(
      init: DashboardCtrl(),
      builder: (ctrl) {
        return Obx(() {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              _onWillPop(context, ctrl);
            },
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
              child: Scaffold(
                backgroundColor: AppTheme.backgroundLight,
                body: IndexedStack(index: ctrl.currentIndex.value, children: [Home(), Services(), Appointments(), Profile()]),
                bottomNavigationBar: _buildFastBottomNavBar(ctrl),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildFastBottomNavBar(DashboardCtrl ctrl) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: AppTheme.primaryLight.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFastNavItem(ctrl: ctrl, index: 0, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
            _buildFastNavItem(ctrl: ctrl, index: 1, icon: Icons.medical_services_outlined, activeIcon: Icons.medical_services_rounded, label: 'Services'),
            _buildFastNavItem(ctrl: ctrl, index: 2, icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Appointments'),
            _buildFastNavItem(ctrl: ctrl, index: 3, icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildFastNavItem({required DashboardCtrl ctrl, required int index, required IconData icon, required IconData activeIcon, required String label}) {
    return Obx(() {
      final isActive = ctrl.currentIndex.value == index;
      return GestureDetector(
        onTap: () => ctrl.changeTab(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              tween: Tween(begin: 0.0, end: isActive ? 1.0 : 0.0),
              builder: (context, value, child) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 + (4 * value), vertical: 8),
                  decoration: BoxDecoration(
                    color: !isActive ? Colors.transparent : null,
                    gradient: !isActive
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.primaryLight.withOpacity(0.9), AppTheme.primaryTeal],
                          ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: !isActive ? null : [BoxShadow(color: AppTheme.primaryLight.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isActive ? activeIcon : icon, size: 22, color: Color.lerp(Colors.grey.shade600, Colors.white, value)),
                      if (value > 0.1) ...[
                        SizedBox(width: 8 * value),
                        Opacity(
                          opacity: value,
                          child: Text(
                            label,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }

  Future<void> _onWillPop(BuildContext context, DashboardCtrl ctrl) async {
    if (ctrl.currentIndex.value != 0) {
      ctrl.changeTab(ctrl.currentIndex.value - 1);
      return;
    }
    _showExitConfirmationDialog(context);
  }

  void _showExitConfirmationDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: AppTheme.emergencyRed.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.exit_to_app_rounded, color: AppTheme.emergencyRed, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                'Exit App?',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to exit Prime Health?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.close(1),
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
                      onPressed: () {
                        Get.close(1);
                        SystemNavigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.emergencyRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Exit', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
