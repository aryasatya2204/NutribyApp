import 'dart:convert';
import 'package:nutriby/models/ingredient.dart';
import 'package:nutriby/models/allergy.dart';
import 'package:nutriby/services/api_service.dart';

class DataService {
  final ApiService _api = ApiService();

  /// ✅ UPDATED: Get ingredients dengan optional filter clean
  Future<List<Ingredient>> getIngredients({bool cleanOnly = false}) async {
    String endpoint = '/ingredients';
    if (cleanOnly) {
      endpoint = '/ingredients?category=Umum&clean=true';
    }

    final response = await _api.get(endpoint);

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Ingredient.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load ingredients from API');
    }
  }

  /// Get all allergies WITH their trigger ingredients
  Future<List<Allergy>> getAllergies() async {
    final response = await _api.get('/allergies');

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Allergy.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load allergies from API');
    }
  }

  /// Search allergies by name, symptom, or ingredient
  Future<List<Allergy>> searchAllergies(String query) async {
    try {
      final response = await _api.get('/allergies/search?q=$query');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Allergy.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search allergies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching allergies: $e');
      throw Exception('Failed to search allergies');
    }
  }
}