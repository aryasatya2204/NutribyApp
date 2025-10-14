import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti dengan IP address lokal Anda jika menjalankan di HP fisik
  // atau 10.0.2.2 jika menggunakan emulator Android
  // static const String _baseUrl = 'http://192.168.1.8:8000/api';
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        // Melempar error dengan pesan dari backend
        throw Exception(responseBody['message'] ?? 'Login Gagal');
      }
    } catch (e) {
      // Menangkap error koneksi atau lainnya
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    }
  }

// TODO: Tambahkan method lain seperti register, getChildren, dll.
}
