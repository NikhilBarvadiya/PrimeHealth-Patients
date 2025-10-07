import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_health_patients/models/service_model.dart';
import 'package:prime_health_patients/views/dashboard/services/ui/service_details.dart';
import 'package:prime_health_patients/views/dashboard/services/ui/slot_selection.dart';

class ServicesCtrl extends GetxController {
  var services = <ServiceModel>[].obs;
  var filteredServices = <ServiceModel>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 1));
    services.value = [
      ServiceModel(id: 1, name: 'Ortho Therapy', description: 'Comprehensive rehabilitation for joint and muscle injuries.', icon: Icons.fitness_center, isActive: true, rate: 1200.0),
      ServiceModel(id: 2, name: 'Neuro Therapy', description: 'Specialized therapy for neurological conditions.', icon: Icons.psychology, isActive: true, rate: 1500.0),
      ServiceModel(id: 3, name: 'Sports Therapy', description: 'Tailored recovery programs for athletes.', icon: Icons.sports_tennis, isActive: true, rate: 1300.0),
      ServiceModel(id: 4, name: 'Pediatric Therapy', description: 'Therapy for children to support developmental milestones.', icon: Icons.child_care, isActive: true, rate: 1100.0),
      ServiceModel(id: 5, name: 'Geriatric Therapy', description: 'Gentle therapy for elderly prime_health_patients to improve mobility.', icon: Icons.elderly, isActive: true, rate: 1000.0),
      ServiceModel(id: 6, name: 'Pain Management', description: 'Advanced techniques to alleviate chronic pain.', icon: Icons.healing, isActive: false, rate: 1400.0),
    ];
    applyFilters();
    isLoading.value = false;
  }

  void searchServices(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    var filtered = services.where((service) => service.isActive).toList();
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((service) => service.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
    filteredServices.value = filtered;
  }

  void bookDetails(ServiceModel service) {
    Get.to(() => ServiceDetails(service: service));
  }

  void bookService(ServiceModel service) {
    Get.to(() => SlotSelection(service: service));
  }
}
