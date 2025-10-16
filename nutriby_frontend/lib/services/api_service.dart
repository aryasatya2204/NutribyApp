import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// A base service for handling API requests.
/// It manages authentication tokens and provides generic HTTP methods.
class ApiService {
  // Gunakan IP 10.0.2.2 untuk emulator Android agar bisa mengakses localhost di komputer Anda.
  // Ganti dengan IP address komputer Anda jika testing di perangkat fisik.
  final String _baseUrl = 'http://10.0.2.2:8000/api';

  /// Retrieves the stored authentication token.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Constructs the authorization headers for protected endpoints.
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    if (token == null) {
      // Jika Anda ingin menangani kasus di mana token tidak ada, Anda bisa throw exception di sini.
      // Namun, untuk service yang hanya dipanggil setelah login, token seharusnya selalu ada.
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

  /// Sends a GET request to a protected endpoint.
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getAuthHeaders();
    return http.get(url, headers: headers);
  }

  /// Sends a POST request to a protected endpoint.
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getAuthHeaders();
    final body = json.encode(data);
    return http.post(url, headers: headers, body: body);
  }

  /// Sends a PUT request to a protected endpoint.
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