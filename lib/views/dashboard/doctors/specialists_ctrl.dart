import 'package:get/get.dart';
import 'package:prime_health_patients/models/category_model.dart';
import 'package:prime_health_patients/models/doctor_model.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';

class SpecialistsCtrl extends GetxController {
  final isLoading = false.obs, isLoadingCategory = false.obs, isLoadingMore = false.obs, hasMore = true.obs;
  final showAvailableOnly = false.obs;
  final doctors = <DoctorModel>[].obs, filteredDoctors = <DoctorModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final searchQuery = ''.obs, selectedCategoryId = ''.obs;
  final currentPage = 1.obs;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    debounce(searchQuery, (_) => _resetAndReload(), time: const Duration(milliseconds: 500));
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([loadCategories(), loadDoctors(initial: true)]);
    } catch (error) {
      toaster.error('Failed to initialize data');
    }
  }

  Future<void> loadCategories() async {
    try {
      isLoadingCategory.value = true;
      final response = await _authService.getCategories();
      if (response != null && response['categories'] != null) {
        final List<dynamic> list = response['categories'] ?? [];
        categories.assignAll(list.map((e) => CategoryModel.fromJson(e)).toList());
        categories.insert(0, CategoryModel(id: "", name: "All"));
      }
    } catch (error) {
      toaster.error('Error loading categories');
    } finally {
      isLoadingCategory.value = false;
    }
  }

  Future<void> loadDoctors({bool initial = false}) async {
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
      final Map<String, dynamic> request = {'page': currentPage.value, 'limit': 15};
      if (searchQuery.value.isNotEmpty) {
        request['search'] = searchQuery.value;
      }
      if (selectedCategoryId.value != "All") {
        request['speciality'] = selectedCategoryId.value;
      }
      if (showAvailableOnly.value) {
        request['isAvailable'] = true;
      }

      final response = await _authService.searchDoctors(request);
      if (response != null && response['docs'] != null) {
        final List<dynamic> docs = response['docs'];
        final doctorsList = docs.map((doctorData) => DoctorModel.fromJson(doctorData)).toList();
        final int total = int.tryParse(response['totalDocs']?.toString() ?? '0') ?? 0;
        if (initial) {
          doctors.assignAll(doctorsList);
        } else {
          doctors.addAll(doctorsList);
        }
        hasMore.value = doctors.length < total;
        currentPage.value++;
        _applyFilters();
      } else {
        if (initial) {
          doctors.clear();
        }
      }
    } catch (error) {
      toaster.error('Failed to load doctors. Please try again.');
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  void toggleAvailabilityFilter(bool value) {
    showAvailableOnly.value = value;
    _resetAndReload();
  }

  void filterByCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
    _resetAndReload();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void _resetAndReload() {
    currentPage.value = 1;
    doctors.clear();
    loadDoctors(initial: true);
  }

  void _applyFilters() {
    filteredDoctors.assignAll(doctors);
  }

  void loadMore() {
    if (hasMore.value && !isLoadingMore.value) {
      loadDoctors();
    }
  }

  void retry() {
    _resetAndReload();
  }

  void clearFilters() {
    selectedCategoryId.value = '';
    searchQuery.value = '';
    _resetAndReload();
  }
}
