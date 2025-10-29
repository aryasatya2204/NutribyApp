import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutriby_frontend/models/recipe.dart';
import 'package:nutriby_frontend/services/api_service.dart';

class RecipeService {
  final ApiService _api = ApiService();

  Future<List<Recipe>> searchRecipes(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final response = await _api.get('/recipes/search?q=$encodedQuery');

    if (response.statusCode == 200) {
      Map<String, dynamic> body = json.decode(response.body);
      if (body['data'] != null && body['data'] is List) {
        List<dynamic> data = body['data'];
        return data.map((dynamic item) => Recipe.fromJson(item)).toList();
      } else {
        throw Exception('Invalid response format from search API');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to search recipes');
    }
  }

  Future<List<Recipe>> filterRecipes({
    int? mainIngredientId,
    int? maxCost,
    List<int>? allergyIds,
    int? ageMonths,
    int page = 1,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
    };

    if (mainIngredientId != null) {
      queryParams['main_ingredient_id'] = mainIngredientId.toString();
    }
    if (maxCost != null) {
      queryParams['max_cost'] = maxCost.toString();
    }
    if (ageMonths != null) {
      queryParams['age_months'] = ageMonths.toString();
    }
    if (allergyIds != null && allergyIds.isNotEmpty) {
      for (int i = 0; i < allergyIds.length; i++) {
        queryParams['allergy_ids[$i]'] = allergyIds[i].toString();
      }
    }

    final queryString = queryParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(
        e.value)}')
        .join('&');

    final endpoint = '/recipes/filter?$queryString';

    final http.Response response;
    try {
      response = await _api.get(endpoint);
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> body = json.decode(response.body);
      if (body['data'] != null && body['data'] is List) {
        List<dynamic> data = body['data'];
        return data.map((dynamic item) => Recipe.fromJson(item)).toList();
      } else {
        return [];
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to filter recipes (Status: ${response.statusCode})');
      } catch (e) {
        throw Exception(
            'Failed to filter recipes (Status: ${response.statusCode})');
      }
    }
  }
}