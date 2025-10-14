import 'package:flutter/material.dart';

class RegisterStep1Form extends StatelessWidget {
  final VoidCallback onNext;

  const RegisterStep1Form({super.key, required this.onNext});

  // Tambahkan TextEditingController di sini jika menggunakan StatefulWidget
  // final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          // Header
          const Image(
            image: AssetImage('assets/images/gambar_bayi.png'),
            height: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          const Text(
            'NutriBy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Isi data anda dibawah',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 48),

          // Form Fields
          _buildTextField(label: 'Username'),
          const SizedBox(height: 20),
          _buildTextField(label: 'Email', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 20),
          _buildTextField(label: 'Password', obscureText: true),
          const SizedBox(height: 40),

          // Tombol Selanjutnya
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Selanjutnya',
              style: TextStyle(
                fontSize: 18,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk membuat text field yang konsisten
  Widget _buildTextField({
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            // Menggunakan UnderlineInputBorder agar sesuai dengan desain
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          obscureText: obscureText,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}