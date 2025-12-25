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
  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Container(padding: const EdgeInsets.all(8), child: const Icon(Icons.home_outlined, size: 24)),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.primaryTeal, shape: BoxShape.circle),
        child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
      ),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Container(padding: const EdgeInsets.all(8), child: const Icon(Icons.medical_services_outlined, size: 24)),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.primaryTeal, shape: BoxShape.circle),
        child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 22),
      ),
      label: 'Services',
    ),
    BottomNavigationBarItem(
      icon: Container(padding: const EdgeInsets.all(8), child: const Icon(Icons.calendar_today_outlined, size: 24)),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.primaryTeal, shape: BoxShape.circle),
        child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 22),
      ),
      label: 'Appointments',
    ),
    BottomNavigationBarItem(
      icon: Container(padding: const EdgeInsets.all(8), child: const Icon(Icons.person_outlined, size: 24)),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.primaryTeal, shape: BoxShape.circle),
        child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
      ),
      label: 'Profile',
    ),
  ];

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
                bottomNavigationBar: _buildBottomNavigationBar(ctrl),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildBottomNavigationBar(DashboardCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, -4))],
        border: Border(top: BorderSide(color: AppTheme.borderColor.withOpacity(0.5), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: ctrl.currentIndex.value,
        onTap: ctrl.changeTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryTeal,
        unselectedItemColor: AppTheme.textLight,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, height: 1.4),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 1.4),
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: _navItems,
      ),
    );
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
