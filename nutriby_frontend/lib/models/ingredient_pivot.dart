import 'package:nutriby_frontend/models/ingredient.dart';

// Model ini merepresentasikan satu baris dari tabel pivot recipe_ingredient
class IngredientPivot {
  final int id; // ID bahan
  final String name; // Nama bahan
  final String? imageUrl; // URL gambar bahan (jika ada)
  final String quantity; // Quantity bahan dari tabel pivot

  IngredientPivot({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.quantity,
  });

  // Helper untuk URL gambar lengkap (dari Ingredient)
  String? get fullImageUrl {
    final ingredient = Ingredient(id: id, name: name, imageUrl: imageUrl);
    return ingredient.fullImageUrl;
  }

  factory IngredientPivot.fromJson(Map<String, dynamic> json) {
    // Ambil data quantity dari nested 'pivot' object
    String qty = json['pivot']?['quantity'] ?? '';

    return IngredientPivot(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      quantity: qty,
    );
  }
}