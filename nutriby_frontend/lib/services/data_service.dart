// lib/services/data_service.dart (FIXED)
import 'dart:convert';
import 'package:nutriby_frontend/models/ingredient.dart';
import 'package:nutriby_frontend/models/allergy.dart';
import 'package:nutriby_frontend/services/api_service.dart';

/// Service for fetching general catalog-like data.
class DataService {
  final ApiService _api = ApiService();

  /// Fetches a list of all available ingredients.
  /// Used for populating selection choices in the UI.
  Future<List<Ingredient>> getIngredients() async {
    // Perbaikan: _api.get tidak memerlukan argumen token
    final response = await _api.get('/ingredients');

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Ingredient.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load ingredients from API');
    }
  }

  /// Fetches a list of all allergy facts.
  Future<List<Allergy>> getAllergies() async {
    // Perbaikan: _api.get tidak memerlukan argumen token
    final response = await _api.get('/allergies');

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Allergy.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load allergies from API');
    }
  }
}