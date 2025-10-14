import 'package:flutter/material.dart';

class FeaturesTab extends StatelessWidget {
  const FeaturesTab({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color.fromRGBO(163, 25, 25, 1);

    return Container(
      color: primaryColor, // Latar belakang utama
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
      child: Column(
        children: [
          _buildFeatureCard(
            title: 'MPASI Mingguan',
            color: Colors.orange.shade200,
            onTap: () {
              // TODO: Navigasi ke fitur MPASI Mingguan
            },
          ),
          const SizedBox(height: 20),
          _buildFeatureCard(
            title: 'Fakta Alergi',
            color: Colors.blue.shade200,
            onTap: () {
              // TODO: Navigasi ke fitur Fakta Alergi
            },
          ),
          const SizedBox(height: 20),
          _buildFeatureCard(
            title: 'Generate Menu',
            color: Colors.green.shade200,
            onTap: () {
              // TODO: Navigasi ke fitur Generate Menu
            },
          ),
        ],
      ),
    );
  }

  // Helper widget untuk membuat kartu fitur
  Widget _buildFeatureCard({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: color, // Menggunakan warna solid sebagai placeholder
            borderRadius: BorderRadius.circular(20),
            // TODO: Ganti dengan gambar jika ada
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
              ),
            ),
          ),
        ),
      ),
    );
  }
}