import 'package:get/get.dart';
import 'package:prime_health_patients/models/doctor_model.dart';

class SpecialistsCtrl extends GetxController {
  var isLoading = false.obs;
  var doctors = <DoctorModel>[].obs;
  var filteredDoctors = <DoctorModel>[].obs;
  var selectedSpecialization = 'All'.obs, searchQuery = ''.obs, sortBy = 'rating'.obs;
  final List<String> specializations = ['All', 'Orthopedic', 'Neurology', 'Pediatrics', 'Cardiology', 'Dermatology', 'Physiotherapy', 'General Medicine'];

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    doctors.assignAll(sampleDoctors);
    filteredDoctors.assignAll(doctors);
    isLoading.value = false;
  }

  void filterDoctors() {
    var result = doctors.where((doctor) {
      final matchesSpecialization = selectedSpecialization.value == 'All' || doctor.specialization.toLowerCase().contains(selectedSpecialization.value.toLowerCase());
      final matchesSearch =
          searchQuery.value.isEmpty ||
          doctor.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          doctor.specialization.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          doctor.services.any((service) => service.toLowerCase().contains(searchQuery.value.toLowerCase()));

      return matchesSpecialization && matchesSearch;
    }).toList();
    result.sort((a, b) {
      switch (sortBy.value) {
        case 'experience':
          return b.experience.compareTo(a.experience);
        case 'fee':
          return (a.consultationFee ?? 00).compareTo(b.consultationFee ?? 0.0);
        case 'distance':
          return a.distance.compareTo(b.distance);
        case 'rating':
        default:
          return b.rating.compareTo(a.rating);
      }
    });

    filteredDoctors.assignAll(result);
  }

  void onSpecializationChanged(String specialization) {
    selectedSpecialization.value = specialization;
    filterDoctors();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    filterDoctors();
  }

  void onSortChanged(String sortType) {
    sortBy.value = sortType;
    filterDoctors();
  }

  void toggleFavorite(String doctorId) {
    final index = doctors.indexWhere((doctor) => doctor.id == doctorId);
    if (index != -1) {
      doctors[index] = doctors[index].copyWith(isFavorite: !doctors[index].isFavorite);
      filterDoctors();
    }
  }

  List<DoctorModel> getAvailableDoctors() {
    return filteredDoctors.where((doctor) => doctor.isAvailable).toList();
  }

  List<DoctorModel> getSeniorDoctors() {
    return filteredDoctors.where((doctor) => doctor.isSeniorDoctor).toList();
  }

  void clearFilters() {
    selectedSpecialization.value = 'All';
    searchQuery.value = '';
    sortBy.value = 'rating';
    filterDoctors();
  }
}
