class ReviewModel {
  final String id;
  final String patientName;
  final String patientImage;
  final double rating;
  final String review;
  final DateTime date;

  ReviewModel({required this.id, required this.patientName, required this.patientImage, required this.rating, required this.review, required this.date});

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id']?.toString() ?? '',
      patientName: json['patientId'] is Map ? json['patientId']['name']?.toString() ?? 'Anonymous' : 'Anonymous',
      patientImage: json['patientId'] is Map ? json['patientId']['profileImage']?.toString() ?? '' : '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      review: json['review']?.toString() ?? '',
      date: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
