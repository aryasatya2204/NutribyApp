import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nutriby_frontend/models/user_model.dart';
import 'package:nutriby_frontend/services/api_service.dart';

class AuthService with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _apiService.login(email, password);

      _user = User.fromJson(response['user']);
      _token = response['access_token'];

      // Simpan token ke secure storage
      await _storage.write(key: 'auth_token', value: _token);
      await _storage.write(key: 'user_name', value: _user!.name);

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      // Melempar kembali error untuk ditangani oleh UI
      rethrow;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    await _storage.deleteAll();
    notifyListeners();
    // TODO: Tambahkan pemanggilan API /logout jika diperlukan
  }
}