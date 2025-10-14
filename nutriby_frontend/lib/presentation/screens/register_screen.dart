import 'package:flutter/material.dart';
import 'package:nutriby_frontend/presentation/screens/widgets/register_step1_form.dart';
import 'package:nutriby_frontend/presentation/screens/widgets/register_step2_form.dart';
import 'package:nutriby_frontend/presentation/screens/widgets/register_step3_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk mengelola halaman/langkah
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi untuk pindah ke halaman berikutnya
  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // TODO: Logika untuk menyelesaikan pendaftaran
      print('Pendaftaran Selesai!');
      // Contoh: Navigator.of(context).pushReplacement(... ke halaman utama);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Indikator Progress (Opsional tapi sangat direkomendasikan)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  width: 30,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage >= index ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          // Konten Form menggunakan PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              // Menonaktifkan scroll manual
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                RegisterStep1Form(onNext: _nextPage),
                RegisterStep2Form(onNext: _nextPage),
                RegisterStep3Form(onFinish: _nextPage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}