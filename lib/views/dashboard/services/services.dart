import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/service_model.dart';
import 'services_ctrl.dart';

class Services extends StatelessWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context) {
    final ServicesCtrl ctrl = Get.put(ServicesCtrl());
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            elevation: 0,
            toolbarHeight: 65,
            backgroundColor: Colors.white,
            pinned: true,
            floating: true,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Services',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Obx(() => Text('${ctrl.filteredServices.length} services available', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]))),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 18),
              child: TextField(
                autofocus: true,
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: Colors.grey[600]),
                          onPressed: () {
                            searchController.clear();
                            ctrl.searchServices('');
                          },
                        )
                      : null,
                ),
                style: GoogleFonts.poppins(fontSize: 16),
                onChanged: ctrl.searchServices,
              ),
            ),
          ),
          Obx(() {
            if (ctrl.isLoading.value) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
                ),
              );
            }
            return ctrl.filteredServices.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState(ctrl))
                : SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final service = ctrl.filteredServices[index];
                        return _buildServiceCard(service, ctrl);
                      }, childCount: ctrl.filteredServices.length),
                    ),
                  );
          }),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service, ServicesCtrl ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => ctrl.bookDetails(service),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(service.icon, color: const Color(0xFF2563EB), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        service.name,
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ),
                    Text(
                      '₹${service.rate.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(service.description, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700], letterSpacing: .5)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => ctrl.bookDetails(service),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('View Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => ctrl.bookService(service),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Book Now', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
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

  Widget _buildEmptyState(ServicesCtrl ctrl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.medical_services_outlined, size: 100, color: Colors.grey[300]),
        const SizedBox(height: 24),
        Text(
          'No Services Found',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Try adjusting your search terms or browse our full catalog',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            ctrl.searchServices('');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'View All Services',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
