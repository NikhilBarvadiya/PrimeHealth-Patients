import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/booking_model.dart';
import 'package:prime_health_patients/models/popular_doctor_model.dart';
import 'package:prime_health_patients/models/service_model.dart';
import 'package:prime_health_patients/utils/network/api_config.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/dashboard/doctors/specialists.dart';
import 'package:prime_health_patients/views/dashboard/home/home_ctrl.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final HomeCtrl ctrl = Get.put(HomeCtrl());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await ctrl.getAPICalling(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            elevation: 0,
            toolbarHeight: 65,
            backgroundColor: Colors.white,
            pinned: true,
            floating: true,
            automaticallyImplyLeading: false,
            title: Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_getGreeting()}!',
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ctrl.userName.value,
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBannerSection(),
                const SizedBox(height: 12),
                _buildSearchSection(),
                const SizedBox(height: 12),
                _buildServicesSection(),
                const SizedBox(height: 12),
                _buildDoctorsByCategory(),
                const SizedBox(height: 12),
                _buildAppointmentsSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildBannerSection() {
    final banners = [
      {
        'image': 'https://images.pexels.com/photos/3825529/pexels-photo-3825529.jpeg?auto=compress&cs=tinysrgb&w=1080',
        'title': 'Welcome to Our Clinic',
        'subtitle': 'Where care meets expertise — your recovery starts here.',
        'color': Colors.blue[700]!,
      },
      {
        'image': 'https://images.pexels.com/photos/4506107/pexels-photo-4506107.jpeg?auto=compress&cs=tinysrgb&w=1080',
        'title': 'Special Offer',
        'subtitle': 'Enjoy 20% off your first physiotherapy session!',
        'color': Colors.green[700]!,
      },
      {
        'image': 'https://images.pexels.com/photos/8376234/pexels-photo-8376234.jpeg?auto=compress&cs=tinysrgb&w=1080',
        'title': 'New Services',
        'subtitle': 'Now offering maternity & pediatric physiotherapy programs.',
        'color': Colors.purple[700]!,
      },
    ];
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: banners.length,
        padEnds: false,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: banner['image'].toString(),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: banner['color'] as Color,
                        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: banner['color'] as Color,
                        child: const Icon(Icons.error, color: Colors.white, size: 40),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.black.withOpacity(0.6), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner['title'].toString(),
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(banner['subtitle'].toString(), style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Your Specialist',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          TextField(
            readOnly: true,
            onTap: () => Get.to(() => SpecialistsList()),
            decoration: InputDecoration(
              hintText: 'Search doctors',
              hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
              prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            style: GoogleFonts.inter(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Popular Services',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              TextButton(
                onPressed: ctrl.viewAllServices,
                style: TextButton.styleFrom(foregroundColor: AppTheme.primaryTeal, padding: EdgeInsets.zero),
                child: Text('See All', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Obx(() {
            if (ctrl.regularServices.isEmpty) {
              return _buildEmptyState('No Services Available', 'Services will be available soon', Icons.medical_services_outlined);
            }
            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                itemCount: ctrl.regularServices.length,
                itemBuilder: (context, index) {
                  return _buildServiceCard(ctrl.regularServices[index]);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => ctrl.bookDetails(service),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(service.icon, color: AppTheme.primaryTeal, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service.name,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'Book Now',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsByCategory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Top Specialists',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Get.to(() => SpecialistsList()),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primaryTeal, padding: EdgeInsets.zero),
                child: Text('See All', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Obx(() {
            if (ctrl.featuredDoctors.isEmpty) {
              return _buildEmptyState('No Doctors Available', 'Doctors will be available soon', Icons.people_outline);
            }
            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                itemCount: ctrl.featuredDoctors.length,
                itemBuilder: (context, index) {
                  return _buildDoctorCard(ctrl.featuredDoctors[index]);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(PopularDoctorModel doctor) {
    final String? imageUrl = doctor.profileImage;
    final String displayImageUrl = imageUrl != null && imageUrl.isNotEmpty ? APIConfig.resourceBaseURL + imageUrl : '';
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => ctrl.viewDoctorProfile(doctor),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2), width: 2),
                    ),
                    child: ClipOval(
                      child: displayImageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: displayImageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppTheme.backgroundLight,
                                child: const Icon(Icons.person, color: AppTheme.textLight, size: 30),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppTheme.backgroundLight,
                                child: const Icon(Icons.person, color: AppTheme.textLight, size: 30),
                              ),
                            )
                          : Container(
                              color: AppTheme.backgroundLight,
                              child: const Icon(Icons.person, color: AppTheme.textLight, size: 30),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  doctor.name,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  doctor.bio,
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      doctor.avgRating.toStringAsFixed(1),
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: doctor.totalBookings > 0 ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.emergencyRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        doctor.totalBookings > 0 ? 'Available' : 'Busy',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: doctor.totalBookings > 0 ? AppTheme.successGreen : AppTheme.emergencyRed),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Upcoming Appointments',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              TextButton(
                onPressed: ctrl.viewAllAppointments,
                style: TextButton.styleFrom(foregroundColor: AppTheme.primaryTeal, padding: EdgeInsets.zero),
                child: Text('See All', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (ctrl.pendingAppointments.isEmpty) {
              return _buildEmptyState('No Appointments', 'Book your first appointment to get started', Icons.calendar_today_outlined);
            }
            return Column(children: ctrl.pendingAppointments.take(3).map((appointment) => _buildAppointmentCard(appointment)).toList());
          }),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BookingModel appointment) {
    final statusColor = _getStatusColor(appointment.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => ctrl.viewAppointmentDetails(appointment.id.toString()),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(_getStatusIcon(appointment.status), color: statusColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.doctorName ?? 'Doctor',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(appointment.serviceName ?? 'Service', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        appointment.statusDisplay.toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(appointment),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BookingModel appointment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          _buildDetailItem(Icons.calendar_today_rounded, appointment.formattedDate, AppTheme.textSecondary),
          _buildDetailItem(Icons.access_time_rounded, appointment.formattedTime, AppTheme.textSecondary),
          _buildDetailItem(Icons.medical_services_rounded, appointment.consultationType == 'in-person' ? 'In-Person' : 'Virtual', AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 12, color: color, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'scheduled':
        return AppTheme.successGreen;
      case 'pending':
        return AppTheme.warningAmber;
      case 'cancelled':
      case 'no-show':
        return AppTheme.emergencyRed;
      case 'completed':
        return AppTheme.primaryTeal;
      case 'rescheduled':
        return AppTheme.warningAmber;
      default:
        return AppTheme.textLight;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'scheduled':
        return Icons.schedule_rounded;
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'completed':
        return Icons.verified_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'no-show':
        return Icons.no_accounts_rounded;
      case 'rescheduled':
        return Icons.calendar_today_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppTheme.textLight),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
