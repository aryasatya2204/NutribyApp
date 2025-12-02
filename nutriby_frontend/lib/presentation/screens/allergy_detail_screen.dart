import 'package:flutter/material.dart';
import 'package:nutriby_frontend/models/allergy.dart';
import 'package:nutriby_frontend/models/ingredient.dart';

class AllergyDetailScreen extends StatelessWidget {
  final Allergy allergy;

  const AllergyDetailScreen({super.key, required this.allergy});

  String _generateTitle() {
    if (allergy.ingredients.isNotEmpty) {
      return 'Kenali dampak-dampak alergi pada\n${allergy.ingredients.first.name}';
    }
    return 'Kenali dampak-dampak dari\n${allergy.name}';
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);

    // Perbaikan: Gunakan fullImageUrl untuk mendapatkan URL lengkap
    final String? displayImageUrl = allergy.fullImageUrl ??
        (allergy.ingredients.isNotEmpty ? allergy.ingredients.first.fullImageUrl : null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryColor),
        title: const Text(
          'Detail Alergi',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: displayImageUrl != null && displayImageUrl.startsWith('http')
                    ? Image.network(
                  displayImageUrl,
                  height: 180,
                  width: 180,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                        height: 180,
                        width: 180,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()));
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/images/placeholder_gizi.png', height: 180, width: 180, fit: BoxFit.cover),
                )
                    : Image.asset(
                  'assets/images/placeholder_gizi.png',
                  height: 180,
                  width: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                _generateTitle(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
              ),
            ),
            _buildRelatedIngredients(context, allergy.ingredients),
            const SizedBox(height: 24),
            _buildSection('Gejala Alergi', allergy.symptoms),
            const SizedBox(height: 24),
            _buildSection('Penanganan & Pencegahan', allergy.handlingAndPrevention),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF333333),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: const Text('© Copyright by NutriBy', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC70039))),
        const SizedBox(height: 8),
        Text(content, style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5)),
      ],
    );
  }

  Widget _buildRelatedIngredients(BuildContext context, List<Ingredient> ingredients) {
    if (ingredients.length <= 1) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Contoh Bahan Pemicu Alergi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC70039)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 6.0,
          children: ingredients.map((ingredient) => Chip(
            label: Text(ingredient.name, style: const TextStyle(color: Color(0xFF333333))),
            backgroundColor: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          )).toList(),
        ),
      ],
    );
  }
}