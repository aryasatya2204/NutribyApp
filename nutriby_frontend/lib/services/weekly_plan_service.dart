import 'dart:convert';
import 'package:http/http.dart';
import 'package:nutriby_frontend/models/weekly_plan.dart';
import 'package:nutriby_frontend/services/api_service.dart';

/// Service responsible for generating and managing weekly meal plans.
class WeeklyPlanService {
  final ApiService _api = ApiService();

  /// Requests the backend to generate a new weekly plan for a specific child.
  ///
  /// Takes a [childId] and an optional [budget] to customize the generation.
  Future<WeeklyPlan> generateWeeklyPlan({
    required int childId,
    int? budget, // Budget bersifat opsional
  }) async {
    final endpoint = '/children/$childId/weekly-plan/generate';

    // Siapkan body request. Jika ada budget, sertakan.
    final Map<String, dynamic> requestBody = {};
    if (budget != null) {
      requestBody['budget'] = budget;
    }

    final response = await _api.post(endpoint, requestBody);

    if (response.statusCode == 201) {
      // Jika berhasil dibuat, parse hasilnya menjadi objek WeeklyPlan
      return WeeklyPlan.fromJson(json.decode(response.body));
    } else {
      // Jika gagal (misalnya karena tidak cukup resep), lempar error dengan pesan dari server
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to generate weekly plan');
    }
  }
}