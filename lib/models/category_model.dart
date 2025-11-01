class CategoryModel {
  final String id;
  final String name;
  final String? serviceId;

  CategoryModel({required this.id, required this.name, this.serviceId});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(id: json['_id']?.toString() ?? '', name: json['name'] ?? '', serviceId: json['service']?['_id']?.toString());
  }
}
