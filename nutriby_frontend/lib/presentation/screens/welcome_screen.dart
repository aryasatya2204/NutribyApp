import 'package:flutter/material.dart';
import 'package:nutriby_frontend/presentation/screens/login_screen.dart';
import 'package:nutriby_frontend/presentation/screens/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisikan warna utama agar mudah diubah jika diperlukan
    const Color primaryColor = Color(0xFFC70039);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header: Logo dan Nama Aplikasi (sesuai UI)
              const Column(
                children: [
                  // Ganti 'assets/images/logo.png' dengan path logo putih Anda
                  Image(
                    image: AssetImage('assets/images/gambar_bayi.png'), // Asumsi nama logo
                    height: 80,
                    color: Colors.white, // Pastikan logo berwarna putih
                  ),
                  SizedBox(height: 16),
                  Text(
                    'NutriBy',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 2. Sub-Teks (sesuai UI)
              const Text(
                'Solusi pantau perkembangan anak',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),

              // Spacer untuk mendorong tombol ke bagian bawah
              const Spacer(),

              // 3. Tombol "Sign Up" (sesuai UI)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Lebih melengkung seperti di UI
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Tombol "Log In" (sesuai UI)
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Lebih melengkung seperti di UI
                  ),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}