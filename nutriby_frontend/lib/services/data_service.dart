import 'dart:convert';
import 'package:nutriby_frontend/models/ingredient.dart';
import 'package:nutriby_frontend/models/allergy.dart';
import 'package:nutriby_frontend/services/api_service.dart';

class DataService {
  final ApiService _api = ApiService();

  Future<List<Ingredient>> getIngredients() async {
    final response = await _api.get('/ingredients');

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Ingredient.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load ingredients from API');
    }
  }

  Future<List<Allergy>> getAllergies() async {
    final response = await _api.get('/allergies');

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Allergy.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load allergies from API');
    }
  }

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