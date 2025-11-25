import 'package:nutriby_frontend/models/ingredient.dart';

class Allergy {
  final int id;
  final String name;
  final String? imageUrl;
  final String symptoms;
  final String handlingAndPrevention;
  final List<Ingredient> ingredients;

  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    // Ganti '10.0.2.2:8000' jika base URL server Anda berbeda
    return 'http://10.0.2.2:8000/storage/$imageUrl';
    // return 'http://192.168.213.209:8000/storage/$imageUrl';
  }

  Allergy({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.symptoms,
    required this.handlingAndPrevention,
    this.ingredients = const [],
  });

  factory Allergy.fromJson(Map<String, dynamic> json) {
    var ingredientList = json['ingredients'] as List? ?? [];
    List<Ingredient> parsedIngredients =
    ingredientList.map((i) => Ingredient.fromJson(i)).toList();

    return Allergy(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      symptoms: json['symptoms'] ?? '',
      handlingAndPrevention: json['handling_and_prevention'] ?? '',
      ingredients: parsedIngredients,
    );
  }
}