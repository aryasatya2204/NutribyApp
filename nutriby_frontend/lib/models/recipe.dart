class Recipe {
  final int id;
  final String title;
  final String? imageUrl;
  final int minAgeMonths;
  final int? maxAgeMonths;
  final String texture;
  final int estimatedCost;
  // Add other fields as needed

  Recipe({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.minAgeMonths,
    this.maxAgeMonths,
    required this.texture,
    required this.estimatedCost,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'],
      minAgeMonths: json['min_age_months'],
      maxAgeMonths: json['max_age_months'],
      texture: json['texture'],
      estimatedCost: json['estimated_cost'],
    );
  }
}