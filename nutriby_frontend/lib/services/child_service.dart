import 'dart:convert';
import 'package:nutriby/models/child.dart';
import 'package:nutriby/services/api_service.dart';

class ChildService {
  final ApiService _api = ApiService();

  Future<Child> createChild(Map<String, dynamic> childData) async {
    final response = await _api.post('/children', childData);
    if (response.statusCode == 201) {
      return Child.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal membuat data anak');
    }
  }

  Future<Child> updateChildPreferences({
    required int childId,
    required List<int> allergyIds,
    required List<int> favoriteIds,
  }) async {
    final endpoint = '/children/$childId';
    final data = {
      'allergy_ids': allergyIds,
      'favorite_ids': favoriteIds,
    };

    final response = await _api.patch(endpoint, data);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['child'] != null) {
        return Child.fromJson(body['child']);
      }
      return Child.fromJson(body);
    } else {
      final errorData = json.decode(response.body);
      final message = errorData['message'] ?? 'Gagal memperbarui preferensi anak';
      throw Exception(message);
    }
  }

  Future<Child> updateChild({
    required int childId,
    required double weight,
    required double height,
    required int income,
    required List<int> allergyIds,
    required List<int> favoriteIds,
  }) async {
    final endpoint = '/children/$childId';
    final data = {
      'current_weight': weight,
      'current_height': height,
      'parent_monthly_income': income,
      'allergy_ids': allergyIds,
      'favorite_ids': favoriteIds,
    };

    final response = await _api.patch(endpoint, data);

    if (response.statusCode == 200) {
      return Child.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body);
      final message = errorData['message'] ?? 'Gagal memperbarui data anak';
      throw Exception(message);
    }
  }

  Future<List<Child>> getMyChildren() async {
    final response = await _api.get('/children');
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Child.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data anak');
    }
  }
}
