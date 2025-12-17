import 'package:nutriby/models/ingredient.dart';

class Allergy {
  final int id;
  final String name;
  final String? type;
  final String symptoms;
  final String handlingAndPrevention;
  final String? imageUrl;
  final List<Ingredient> ingredients;

  Allergy({
    required this.id,
    required this.name,
    this.type,
    required this.symptoms,
    required this.handlingAndPrevention,
    this.imageUrl,
    this.ingredients = const [],
  });

  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;

    String cleanPath = imageUrl!.replaceAll('public/', '');

    if (!cleanPath.startsWith('allergies/')) {
      cleanPath = 'allergies/$cleanPath';
    }

    return 'https://nutribyapp.user.cloudjkt02.com/$cleanPath';
  }

  factory Allergy.fromJson(Map<String, dynamic> json) {
    var ingredientsList = <Ingredient>[];
    if (json['ingredients'] != null) {
      ingredientsList = (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i))
          .toList();
    }

    return Allergy(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      symptoms: json['symptoms'],
      handlingAndPrevention: json['handling_and_prevention'],
      imageUrl: json['image_url'],
      ingredients: ingredientsList,
    );
  }
}