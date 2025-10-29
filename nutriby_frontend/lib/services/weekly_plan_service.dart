import 'dart:convert';
import 'package:http/http.dart';
import 'package:nutriby_frontend/models/weekly_plan.dart';
import 'package:nutriby_frontend/services/api_service.dart';

class WeeklyPlanService {
  final ApiService _api = ApiService();

  Future<WeeklyPlan> generateWeeklyPlan({
    required int childId,
    int? budget,
  }) async {
    final endpoint = '/children/$childId/weekly-plan/generate';

    final Map<String, dynamic> requestBody = {};
    if (budget != null) {
      requestBody['budget'] = budget;
    }

    final response = await _api.post(endpoint, requestBody);

    if (response.statusCode == 201) {
      return WeeklyPlan.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to generate weekly plan');
    }
  }
}