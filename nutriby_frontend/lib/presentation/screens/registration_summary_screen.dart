import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutriby_frontend/models/child.dart';
import 'package:nutriby_frontend/presentation/screens/home_screen.dart';

class RegistrationSummaryScreen extends StatelessWidget {
  final Child child;
  final String userName;

  const RegistrationSummaryScreen({
    super.key,
    required this.child,
    required this.userName,
  });

  String _calculateAge(String birthDateStr) {
    try {
      final birthDate = DateTime.parse(birthDateStr);
      final now = DateTime.now();
      int years = now.year - birthDate.year;
      int months = now.month - birthDate.month;
      int days = now.day - birthDate.day;

      if (days < 0) {
        months--;
        days += DateTime(now.year, now.month, 0).day;
      }
      if (months < 0) {
        years--;
        months += 12;
      }
      return '$months bulan, $days hari';
    } catch (e) {
      return 'Gagal menghitung umur';
    }
  }

  String? _getWarningMessage() {
    final ageInMonths = DateTime.now().difference(DateTime.parse(child.birthDate)).inDays ~/ 30;

    // Contoh Peringatan: Jika anak di bawah 2 tahun tapi beratnya > 20kg atau tingginya > 110cm
    if (ageInMonths <= 24) {
      if (child.currentWeight > 20) {
        return "Peringatan: Berat badan anak terlihat sangat tinggi untuk usianya. Pastikan Anda memasukkan data yang benar.";
      }
      if (child.currentHeight > 110) {
        return "Peringatan: Tinggi badan anak terlihat sangat tinggi untuk usianya. Pastikan Anda memasukkan data yang benar.";
      }
    }
    return null; // Tidak ada peringatan
  }

  @override
  Widget build(BuildContext context) {
    final title = child.gender == 'male' ? 'Pangeran' : 'Putri';
    final age = _calculateAge(child.birthDate);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFC70039),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 80),
              const SizedBox(height: 24),
              Text(
                'Hai $userName, sang $title telah tiba!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.3),
              ),
              const SizedBox(height: 32),
              _buildInfoCard(
                'Umur',
                age,
                Icons.cake_outlined,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Status Gizi (TB/U)',
                child.nutritionalStatusHfa ?? 'N/A',
                Icons.height_outlined,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Rekomendasi Budget MPASI',
                '${currencyFormatter.format(child.budgetMin ?? 0)} - ${currencyFormatter.format(child.budgetMax ?? 0)}',
                Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 24),
              Text(
                child.nutritionalStatusNotes ?? 'Jaga terus asupan gizi seimbang si kecil.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15, fontStyle: FontStyle.italic),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  'Mulai Petualangan Gizi',
                  style: TextStyle(fontSize: 18, color: Color(0xFFC70039), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}