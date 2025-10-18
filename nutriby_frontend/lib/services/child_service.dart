// lib/services/child_service.dart (FIXED)
import 'dart:convert';
import 'package:nutriby_frontend/models/child.dart';
import 'package:nutriby_frontend/services/api_service.dart';

class ChildService {
  final ApiService _api = ApiService();

  /// Membuat data anak baru dan mengembalikan objek Child.
  Future<Child> createChild(Map<String, dynamic> childData) async {
    final response = await _api.post('/children', childData);
    if (response.statusCode == 201) {
      return Child.fromJson(json.decode(response.body));
    } else {
      // Memberikan pesan error yang lebih spesifik dari backend
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal membuat data anak');
    }
  }

  /// Memperbarui preferensi (alergi & kesukaan) untuk anak yang sudah ada.
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
      return Child.fromJson(json.decode(response.body));
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

  /// Mengambil daftar semua anak yang dimiliki oleh pengguna yang sedang login.
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
