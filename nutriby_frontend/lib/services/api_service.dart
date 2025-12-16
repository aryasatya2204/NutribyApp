import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  // Gunakan IP 10.0.2.2 untuk emulator Android agar bisa mengakses localhost di komputer.
  // Ganti dengan IP address komputer jika testing di perangkat fisik.
  // final String _baseUrl = 'http://10.0.2.2:8000/api';
  final String _baseUrl = 'https://nutribyapp.user.cloudjkt02.com/api';

  String getBaseUrl() {
    return _baseUrl;
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    if (token == null) {
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getAuthHeaders();
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getAuthHeaders();
    final body = json.encode(data);
    return http.post(url, headers: headers, body: body);
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getAuthHeaders();
    final body = json.encode(data);
    return http.put(url, headers: headers, body: body);
  }

  Future<http.Response> patch(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getAuthHeaders();
    final body = json.encode(data);
    return http.patch(url, headers: headers, body: body);
  }
}