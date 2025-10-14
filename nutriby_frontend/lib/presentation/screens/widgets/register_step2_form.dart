import 'package:flutter/material.dart';

class RegisterStep2Form extends StatelessWidget {
  final VoidCallback onNext;

  const RegisterStep2Form({super.key, required this.onNext});

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
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Isi data anak anda',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 48),

          // Form Fields
          _buildTextField(label: 'Nama Lengkap'),
          const SizedBox(height: 20),
          // TODO: Ganti dengan DropdownButtonFormField untuk implementasi nyata
          _buildTextField(label: 'Jenis Kelamin Anak'),
          const SizedBox(height: 20),
          _buildTextField(label: 'Berat Badan Anak (Kg)', keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          _buildTextField(label: 'Tinggi Badan Anak (cm)', keyboardType: TextInputType.number),
          const SizedBox(height: 40),

          // Tombol Selanjutnya
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text(
              'Selanjutnya',
              style: TextStyle(fontSize: 18, color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget yang sama dengan Step 1
  Widget _buildTextField({
    required String label,
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
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}