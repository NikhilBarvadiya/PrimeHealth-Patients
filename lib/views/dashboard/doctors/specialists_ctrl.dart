import 'package:get/get.dart';
import 'package:prime_health_patients/models/doctor_model.dart';
import 'package:prime_health_patients/utils/toaster.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';

class SpecialistsCtrl extends GetxController {
  var isLoading = false.obs;
  var doctors = <DoctorModel>[].obs, filteredDoctors = <DoctorModel>[].obs;
  var selectedSpecialization = 'All'.obs, searchQuery = ''.obs;
  var specializations = <String>['All'].obs;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    searchDoctors();
  }

  Future<void> loadCategories() async {
    try {
      final response = await _authService.getCategories();
      if (response != null && response['categories'] != null) {
        final categories = List<String>.from(response['categories'].map((cat) => cat['name']?.toString() ?? ''));
        specializations.assignAll(['All', ...categories]);
      }
    } catch (error) {
      toaster.error('Error loading categories');
    }
  }

  Future<void> searchDoctors() async {
    try {
      isLoading.value = true;
      final request = {
        'search': searchQuery.value.isEmpty ? null : searchQuery.value,
        'speciality': selectedSpecialization.value == 'All' ? null : selectedSpecialization.value.toLowerCase(),
        'page': 1,
        'limit': 50,
      };
      request.removeWhere((key, value) => value == null);
      final response = await _authService.searchDoctors(request);
      if (response != null && response['docs'] != null) {
        final doctorsList = List<Map<String, dynamic>>.from(response['docs']).map((doctorData) => DoctorModel.fromJson(doctorData)).toList();
        doctors.assignAll(doctorsList);
      }
    } catch (error, s) {
      print(s);
      toaster.error('Error searching doctors');
    } finally {
      isLoading.value = false;
    }
  }

  void onSpecializationChanged(String specialization) {
    doctors.clear();
    selectedSpecialization.value = specialization;
    searchDoctors();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchDoctors();
    } else {
      debounce(searchQuery, (_) => searchDoctors(), time: const Duration(milliseconds: 500));
    }
  }
}
