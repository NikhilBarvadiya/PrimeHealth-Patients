import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/service_model.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'services_ctrl.dart';

class Services extends StatelessWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context) {
    final ServicesCtrl ctrl = Get.put(ServicesCtrl());
    final TextEditingController searchController = TextEditingController();
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            elevation: 0,
            toolbarHeight: 80,
            backgroundColor: Colors.white,
            pinned: true,
            floating: true,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Services',
                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Obx(() => Text('${ctrl.filteredServices.length} services available', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary))),
              ],
            ),
          ),
          SliverToBoxAdapter(child: _buildSearchFilterSection(ctrl, searchController)),
          Obx(() {
            if (ctrl.isLoading.value) {
              return SliverToBoxAdapter(
                child: Container(height: 200, alignment: Alignment.center, child: const CircularProgressIndicator()),
              );
            }
            return ctrl.filteredServices.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState(ctrl))
                : SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final service = ctrl.filteredServices[index];
                        return _buildServiceCard(service, ctrl).paddingOnly(bottom: 12);
                      }, childCount: ctrl.filteredServices.length),
                    ),
                  );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchFilterSection(ServicesCtrl ctrl, TextEditingController searchController) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search services, specialties...',
              hintStyle: GoogleFonts.inter(color: AppTheme.textLight),
              prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 22),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: AppTheme.textSecondary, size: 20),
                      onPressed: () {
                        searchController.clear();
                        ctrl.searchServices('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.backgroundLight,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            style: GoogleFonts.inter(fontSize: 16),
            onChanged: ctrl.searchServices,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: ctrl.categories.length,
              itemBuilder: (context, index) {
                final category = ctrl.categories[index];
                return Obx(
                  () => Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                      selected: ctrl.selectedCategory.value == category,
                      onSelected: (selected) => ctrl.filterByCategory(category),
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.primaryTeal.withOpacity(0.1),
                      checkmarkColor: AppTheme.primaryTeal,
                      labelStyle: TextStyle(color: ctrl.selectedCategory.value == category ? AppTheme.primaryTeal : AppTheme.textSecondary),
                      side: BorderSide(color: ctrl.selectedCategory.value == category ? AppTheme.primaryTeal : AppTheme.borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service, ServicesCtrl ctrl) {
    return Container(
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
                Row(
                  spacing: 12.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: service.isActive ? AppTheme.primaryTeal.withOpacity(0.1) : AppTheme.textLight.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(service.icon, color: service.isActive ? AppTheme.primaryTeal : AppTheme.textLight, size: 20),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, height: 1.2),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            service.description,
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '₹${service.rate.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
                    ),
                    const Spacer(),
                    if (service.isActive)
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: AppTheme.primaryTeal, borderRadius: BorderRadius.circular(10)),
                        child: IconButton(
                          onPressed: () => ctrl.bookService(service),
                          icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                          padding: EdgeInsets.zero,
                        ),
                      )
                    else
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: AppTheme.textLight.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.lock_outline_rounded, color: AppTheme.textLight, size: 18),
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
        Icon(Icons.medical_services_outlined, size: 120, color: AppTheme.textLight.withOpacity(0.5)),
        const SizedBox(height: 24),
        Text(
          'No Services Found',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Try adjusting your search terms or browse our full catalog',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            ctrl.clearFilters();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: Text('View All Services', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
