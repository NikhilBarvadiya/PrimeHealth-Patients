import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/service_model.dart';
import 'package:prime_health_patients/views/dashboard/services/services_ctrl.dart';

class ServiceDetails extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetails({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final ServicesCtrl ctrl = Get.find<ServicesCtrl>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            toolbarHeight: 65,
            backgroundColor: Colors.white,
            pinned: true,
            title: Text(
              service.name,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            leading: IconButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
              ),
              icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildServiceHeaderCard(service), const SizedBox(height: 24), _buildDetailsSection(service), const SizedBox(height: 24), _buildActionButtons(service, ctrl)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHeaderCard(ServiceModel service) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Color(0xFF2563EB).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(service.icon, color: Color(0xFF2563EB), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${service.rate.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(ServiceModel service) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Details',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _buildDetailItem(icon: Icons.description_outlined, label: 'Description', value: service.description),
          const SizedBox(height: 12),
          _buildDetailItem(icon: Icons.category_outlined, label: 'Category', value: 'Physiotherapy'),
        ],
      ),
    );
  }

  Widget _buildDetailItem({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ServiceModel service, ServicesCtrl ctrl) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => ctrl.bookService(service),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Book Now',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: Text(
              'Back to Services',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ),
        ),
      ],
    );
  }
}
