// lib/services/auth_service.dart (FIXED)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  // final String _baseUrl = 'http://10.0.2.2:8000/api';
  final String _baseUrl = 'http://192.168.213.209:8000/api';

  bool _isLoading = false;
  User? _user;
  String? _token;

  bool get isLoading => _isLoading;
  User? get user => _user;
  String? get token => _token;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> register({ required String name, required String email, required String password }) async {
    final url = Uri.parse('$_baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: json.encode({'name': name, 'email': email, 'password': password}),
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode != 201) {
      // Memberikan pesan error yang lebih informatif dari backend
      throw Exception(responseBody['message'] ?? 'Registrasi gagal');
    }
  }

  Future<void> login({ required String email, required String password }) async {
    _setLoading(true);
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['access_token'];
        _user = User.fromJson(data['user']);
        await _saveToken(_token!);
      } else {
        final errorData = json.decode(response.body);
        // Memberikan pesan error dari backend
        throw Exception(errorData['message'] ?? 'Email atau password salah.');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
}