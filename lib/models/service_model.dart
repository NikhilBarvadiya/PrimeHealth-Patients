import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isActive;
  final String createdAt;
  final String category;

  ServiceModel({required this.id, required this.name, required this.description, required this.icon, required this.isActive, required this.createdAt, required this.category});

  factory ServiceModel.fromApi(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: _mapIcon(json['category'] ?? 'General'),
      isActive: json['isActive'] == true,
      createdAt: json['createdAt'] ?? '',
      category: json['category'] ?? 'General',
    );
  }
}

IconData _mapIcon(String category) {
  switch (category.toLowerCase()) {
    case 'orthopedic':
      return Icons.fitness_center;
    case 'neurology':
      return Icons.psychology;
    case 'pediatrics':
      return Icons.child_care_rounded;
    case 'physiotherapy':
      return Icons.accessible_rounded;
    case 'cardiology':
      return Icons.favorite_rounded;
    case 'dermatology':
      return Icons.spa_rounded;
    case 'wellness':
      return Icons.self_improvement_rounded;
    default:
      return Icons.medical_services_rounded;
  }
}
