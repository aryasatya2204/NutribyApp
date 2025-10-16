import 'package:nutriby_frontend/models/ingredient.dart'; // Pastikan path ini benar

class Allergy {
  final int id;
  final String name;
  final String symptoms;
  final String handlingAndPrevention;
  final Ingredient? ingredient; // Bahan yang terkait bisa jadi null

  Allergy({
    required this.id,
    required this.name,
    required this.symptoms,
    required this.handlingAndPrevention,
    this.ingredient,
  });

  // Factory constructor untuk membuat objek Allergy dari JSON
  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      id: json['id'],
      name: json['name'],
      symptoms: json['symptoms'],
      handlingAndPrevention: json['handling_and_prevention'],
      // Cek jika data 'ingredient' ada sebelum di-parse
      ingredient: json['ingredient'] != null
          ? Ingredient.fromJson(json['ingredient'])
          : null,
    );
  }
}