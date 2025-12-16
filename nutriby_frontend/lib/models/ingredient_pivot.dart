import 'package:nutriby/models/ingredient.dart';

class IngredientPivot {
  final int id;
  final String name;
  final String? imageUrl;
  final String quantity;

  IngredientPivot({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.quantity,
  });

  String? get fullImageUrl {
    final ingredient = Ingredient(id: id, name: name, imageUrl: imageUrl);
    return ingredient.fullImageUrl;
  }

  factory IngredientPivot.fromJson(Map<String, dynamic> json) {
    String qty = json['pivot']?['quantity'] ?? '';

    return IngredientPivot(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      quantity: qty,
    );
  }
}