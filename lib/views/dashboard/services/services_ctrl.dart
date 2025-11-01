import 'package:get/get.dart';
import 'package:prime_health_patients/models/service_model.dart';
import 'package:prime_health_patients/models/category_model.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';
import 'package:prime_health_patients/views/dashboard/services/ui/service_details.dart';
import 'package:prime_health_patients/views/dashboard/services/ui/slot_selection.dart';

class ServicesCtrl extends GetxController {
  final isLoading = false.obs, isLoadingMore = false.obs, hasMore = true.obs;

  final services = <ServiceModel>[].obs, filteredServices = <ServiceModel>[].obs;
  final categories = <CategoryModel>[].obs;

  final searchQuery = ''.obs;
  final selectedCategoryId = Rxn<String>();
  final currentPage = 1.obs;
  final limit = 10;

  AuthService get authService => Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadServices(initial: true);
  }

  Future<void> loadCategories() async {
    try {
      final response = await authService.getCategories();
      if (response != null && response.isNotEmpty) {
        final List<dynamic> list = response['categories'] ?? [];
        categories.assignAll(list.map((e) => CategoryModel.fromJson(e)).toList());
        categories.insert(0, CategoryModel(id: "", name: "All"));
      }
    } catch (e) {
      toaster.error('Categories error: $e');
    }
  }

  Future<void> loadServices({bool initial = false}) async {
    if (initial) {
      isLoading(true);
      currentPage.value = 1;
      hasMore.value = true;
    } else if (!hasMore.value || isLoadingMore.value) {
      return;
    } else {
      isLoadingMore(true);
    }
    try {
      final Map<String, dynamic> payload = {
        'page': currentPage.value,
        'limit': limit,
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        if (selectedCategoryId.value != null) 'category': selectedCategoryId.value,
      };
      final response = await authService.getServices(payload);
      if (response != null) {
        final List<dynamic> docs = response['docs'] ?? [];
        final int total = int.tryParse(response['totalDocs'].toString()) ?? 0;
        final newServices = docs.map((e) => ServiceModel.fromApi(e)).toList();
        if (initial) {
          services.assignAll(newServices);
        } else {
          services.addAll(newServices);
        }
        hasMore.value = services.length < total;
        currentPage.value++;
      }
    } catch (e) {
      toaster.error('Services error: $e');
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  void searchServices(String query) {
    searchQuery.value = query.trim();
    _resetAndReload();
  }

  void filterByCategory(String? categoryId) {
    selectedCategoryId.value = categoryId;
    _resetAndReload();
  }

  void _resetAndReload() {
    currentPage.value = 1;
    services.clear();
    loadServices(initial: true);
  }

  void loadMore() {
    if (hasMore.value && !isLoadingMore.value) {
      loadServices();
    }
  }

  void bookDetails(ServiceModel service) {
    Get.to(() => ServiceDetails(service: service));
  }

  void bookService(ServiceModel service) {
    if (service.isActive) {
      Get.to(() => SlotSelection(service: service));
    }
  }
}
