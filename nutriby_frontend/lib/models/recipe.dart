import 'package:nutriby_frontend/models/ingredient_pivot.dart'; // Impor model pivot baru

class Recipe {
  final int id;
  final String title;
  final String? description;
  final String? instructions;
  final String? imageUrl;
  final int minAgeMonths;
  final int? maxAgeMonths;
  final String texture;
  final int estimatedCost;
  final int? calories;
  final double? proteinGrams;
  final double? fatGrams;
  final List<IngredientPivot> ingredients;

  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    // Sesuaikan base URL
    // return 'http://10.0.2.2:8000/storage/$imageUrl';
    return 'http://192.168.213.209:8000/storage/$imageUrl';
  }

  Recipe({
    required this.id,
    required this.title,
    this.description,
    this.instructions,
    this.imageUrl,
    required this.minAgeMonths,
    this.maxAgeMonths,
    required this.texture,
    required this.estimatedCost,
    this.calories,
    this.proteinGrams,
    this.fatGrams,
    this.ingredients = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<IngredientPivot> parsedIngredients = [];
    if (json['ingredients'] != null && json['ingredients'] is List) {
      parsedIngredients = (json['ingredients'] as List)
          .map((item) => IngredientPivot.fromJson(item)) // Gunakan fromJson dari pivot
          .toList();
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Recipe(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      instructions: json['instructions'],
      imageUrl: json['image_url'],
      minAgeMonths: json['min_age_months'],
      maxAgeMonths: json['max_age_months'],
      texture: json['texture'],
      estimatedCost: json['estimated_cost'],
      calories: parseInt(json['calories']),
      proteinGrams: parseDouble(json['protein_grams']),
      fatGrams: parseDouble(json['fat_grams']),
      ingredients: parsedIngredients,
    );
  }
}