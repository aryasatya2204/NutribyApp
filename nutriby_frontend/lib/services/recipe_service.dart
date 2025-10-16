import 'dart:convert';
import 'package:nutriby_frontend/models/recipe.dart';
import 'package:nutriby_frontend/services/api_service.dart';

class RecipeService {
  final ApiService _api = ApiService();

  Future<List<Recipe>> searchRecipes(String query) async {
    final response = await _api.get('/recipes/search?q=$query');
    if (response.statusCode == 200) {
      // Perhatikan, response dari paginator Laravel memiliki data di dalam 'data'
      Map<String, dynamic> body = json.decode(response.body);
      List<dynamic> data = body['data'];
      return data.map((dynamic item) => Recipe.fromJson(item)).toList();
    } else {
      throw Exception('Failed to search recipes');
    }
  }
}