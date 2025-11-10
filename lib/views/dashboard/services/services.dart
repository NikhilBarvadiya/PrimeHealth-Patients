import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prime_health_patients/models/service_model.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:shimmer/shimmer.dart';
import 'services_ctrl.dart';

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  final ServicesCtrl ctrl = Get.put(ServicesCtrl());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ever(ctrl.searchQuery, (String q) => searchController.text = q);
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
        child: CustomScrollView(physics: const ClampingScrollPhysics(), slivers: [_buildAppBar(), _buildServiceList()]),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      elevation: 0,
      toolbarHeight: 75,
      backgroundColor: AppTheme.backgroundWhite,
      pinned: true,
      floating: true,
      automaticallyImplyLeading: false,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Services',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text('${ctrl.services.length} services available', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
        ],
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
            onPressed: () => ctrl.resetAndReload(),
            tooltip: 'Refresh services',
          ),
        ),
      ],
      bottom: PreferredSize(preferredSize: const Size.fromHeight(135), child: _buildSearchFilter()),
    );
  }

  Widget _buildSearchFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: TextField(
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
              style: GoogleFonts.inter(fontSize: 13),
              onChanged: ctrl.searchServices,
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryChips(),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: Obx(() {
        return ListView.builder(
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
        );
      }),
    );
  }

  Widget _buildServiceList() {
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.services.isEmpty) {
        return SliverToBoxAdapter(child: _buildShimmerList());
      }
      if (ctrl.services.isEmpty) {
        return SliverFillRemaining(child: _buildEmptyState());
      }
      return SliverPadding(
        padding: const EdgeInsets.all(20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index >= ctrl.services.length) {
              return _buildLoadMoreIndicator();
            }
            final service = ctrl.services[index];
            return AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _buildServiceCard(service).paddingOnly(bottom: 12));
          }, childCount: ctrl.services.length + (ctrl.hasMore.value ? 1 : 0)),
        ),
      );
    });
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(
      () => ctrl.isLoadingMore.value
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => ctrl.bookDetails(service),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: service.isActive ? AppTheme.primaryTeal.withOpacity(0.1) : AppTheme.textLight.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(service.icon, color: service.isActive ? AppTheme.primaryTeal : AppTheme.textLight, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
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
                  Icon(Icons.access_time, color: AppTheme.primaryTeal, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(DateTime.parse(service.createdAt)),
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                  ),
                  const Spacer(),
                  _buildActionButton(service),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(ServiceModel service) {
    return service.isActive
        ? Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppTheme.primaryTeal, borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              onPressed: () => ctrl.bookService(service),
              icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              padding: EdgeInsets.zero,
            ),
          )
        : Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppTheme.textLight.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.lock_outline_rounded, color: AppTheme.textLight, size: 18),
          );
  }

  Widget _buildShimmerList() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: List.generate(6, (index) => _buildShimmerCard()).toList()),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 18,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'Try adjusting your search or browse our full catalog.',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
