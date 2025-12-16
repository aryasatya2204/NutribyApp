import 'package:nutriby/models/ingredient.dart';
import 'package:nutriby/models/growth_history.dart';
import 'package:nutriby/models/allergy.dart'; // Pastikan import ini ada

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
  final List<Allergy> allergies;
  final List<Ingredient> favoriteIngredients;
  final List<GrowthHistory> growthHistories;

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
    this.growthHistories = const [],
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

    List<Allergy> parseAllergies(String key) {
      if (json[key] != null && json[key] is List) {
        return (json[key] as List)
            .map((item) => Allergy.fromJson(item))
            .toList();
      }
      return [];
    }

    List<GrowthHistory> parseHistory(String key) {
      if (json[key] != null && json[key] is List) {
        return (json[key] as List)
            .map((item) => GrowthHistory.fromJson(item))
            .toList();
      }
      return [];
    }

    return Child(
      id: json['id'],
      name: json['name'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      currentWeight: double.parse(json['current_weight'].toString()),
      currentHeight: double.parse(json['current_height'].toString()),
      parentMonthlyIncome: int.parse(json['parent_monthly_income'].toString()),
      nutritionalStatusWfa: json['nutritional_status_wfa'],
      nutritionalStatusHfa: json['nutritional_status_hfa'],
      nutritionalStatusWfh: json['nutritional_status_wfh'],
      nutritionalStatusNotes: json['nutritional_status_notes'],
      budgetMin: json['budget_min'],
      budgetMax: json['budget_max'],
      allergies: parseAllergies('allergies'),
      favoriteIngredients: parseIngredients('favorite_ingredients'),
      growthHistories: parseHistory('growth_histories'),
    );
  }
}