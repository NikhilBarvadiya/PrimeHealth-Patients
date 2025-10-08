import 'package:flutter/material.dart';

class ServiceModel {
  final int id;
  final String name;
  final String description;
  final String category;
  final IconData icon;
  bool isActive;
  final double rate;

  ServiceModel({required this.id, required this.name, required this.description, required this.category, required this.icon, this.isActive = false, this.rate = 0.0});
}
