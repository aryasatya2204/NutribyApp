// lib/models/child.dart (FIXED)
import 'package:nutriby_frontend/models/ingredient.dart';

class Child {
  final int id;
  final String name;
  final String birthDate;
  final String gender;
  final double currentWeight;
  final double currentHeight;
  final int parentMonthlyIncome;
  final String? nutritionalStatusWfa;
  final String? nutritionalStatusHfa;
  final String? nutritionalStatusWfh;
  final String? nutritionalStatusNotes;
  final int? budgetMin;
  final int? budgetMax;
  final List<Ingredient> allergies;
  final List<Ingredient> favoriteIngredients;

  Child({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.currentWeight,
    required this.currentHeight,
    required this.parentMonthlyIncome,
    this.nutritionalStatusWfa,
    this.nutritionalStatusHfa,
    this.nutritionalStatusWfh,
    this.nutritionalStatusNotes,
    this.budgetMin,
    this.budgetMax,
    this.allergies = const [],
    this.favoriteIngredients = const [],
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    List<Ingredient> parseIngredients(String key) {
      if (json[key] != null && json[key] is List) {
        return (json[key] as List)
            .map((item) => Ingredient.fromJson(item))
            .toList();
      }
      return [];
    }

    return Child(
      id: json['id'],
      name: json['name'],
      birthDate: json['birth_date'],
      gender: json['gender'],

      // Menggunakan .toString() untuk memastikan parsing aman, baik data datang sebagai String maupun num.
      currentWeight: double.parse(json['current_weight'].toString()),
      currentHeight: double.parse(json['current_height'].toString()),
      parentMonthlyIncome: int.parse(json['parent_monthly_income'].toString()),

      nutritionalStatusWfa: json['nutritional_status_wfa'],
      nutritionalStatusHfa: json['nutritional_status_hfa'],
      nutritionalStatusWfh: json['nutritional_status_wfh'],
      nutritionalStatusNotes: json['nutritional_status_notes'],
      budgetMin: json['budget_min'],
      budgetMax: json['budget_max'],
      allergies: parseIngredients('allergies'),
      favoriteIngredients: parseIngredients('favorite_ingredients'),
    );
  }
}