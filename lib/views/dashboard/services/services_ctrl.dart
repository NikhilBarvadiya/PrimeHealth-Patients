import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_health_patients/models/service_model.dart';
import 'package:prime_health_patients/views/dashboard/services/ui/service_details.dart';
import 'package:prime_health_patients/views/dashboard/services/ui/slot_selection.dart';

class ServicesCtrl extends GetxController {
  var isLoading = false.obs;
  var services = <ServiceModel>[].obs, filteredServices = <ServiceModel>[].obs;
  var searchQuery = ''.obs, selectedCategory = 'All'.obs;

  final List<String> categories = ['All', 'Orthopedic', 'Neurology', 'Pediatrics', 'Physiotherapy', 'Cardiology', 'Dermatology', 'Wellness'];

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    services.assignAll([
      ServiceModel(
        id: 1,
        name: 'Orthopedic Therapy',
        description: 'Specialized treatment for bone and joint issues, fractures, and musculoskeletal disorders.',
        icon: Icons.fitness_center,
        isActive: true,
        rate: 1200.0,
        category: 'Orthopedic',
      ),
      ServiceModel(
        id: 2,
        name: 'Neurology Consultation',
        description: 'Expert care for neurological conditions, brain and nervous system disorders.',
        icon: Icons.psychology,
        isActive: true,
        rate: 1500.0,
        category: 'Neurology',
      ),
      ServiceModel(
        id: 3,
        name: 'Pediatric Care',
        description: 'Comprehensive healthcare services for children and adolescents.',
        icon: Icons.child_care_rounded,
        isActive: true,
        rate: 1000.0,
        category: 'Pediatrics',
      ),
      ServiceModel(
        id: 4,
        name: 'Physical Therapy',
        description: 'Rehabilitation and mobility improvement through specialized exercises.',
        icon: Icons.accessible_rounded,
        isActive: true,
        rate: 800.0,
        category: 'Physiotherapy',
      ),
      ServiceModel(
        id: 5,
        name: 'Cardiac Consultation',
        description: 'Heart health assessment and cardiovascular disease management.',
        icon: Icons.favorite_rounded,
        isActive: false,
        rate: 2000.0,
        category: 'Cardiology',
      ),
      ServiceModel(
        id: 6,
        name: 'Skin Care Treatment',
        description: 'Advanced dermatological treatments for various skin conditions.',
        icon: Icons.spa_rounded,
        isActive: true,
        rate: 900.0,
        category: 'Dermatology',
      ),
      ServiceModel(
        id: 7,
        name: 'Mental Wellness',
        description: 'Counseling and therapy for mental health and emotional well-being.',
        icon: Icons.psychology_rounded,
        isActive: true,
        rate: 1300.0,
        category: 'Wellness',
      ),
      ServiceModel(
        id: 8,
        name: 'Sports Medicine',
        description: 'Injury prevention and treatment for athletes and active individuals.',
        icon: Icons.sports_rounded,
        isActive: false,
        rate: 1100.0,
        category: 'Orthopedic',
      ),
    ]);
    filteredServices.assignAll(services);
    isLoading.value = false;
  }

  void searchServices(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void _applyFilters() {
    var result = services.where((service) {
      final matchesSearch =
          searchQuery.value.isEmpty || service.name.toLowerCase().contains(searchQuery.value.toLowerCase()) || service.description.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesCategory = selectedCategory.value == 'All' || service.category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
    filteredServices.assignAll(result);
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = 'All';
    _applyFilters();
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
