import 'package:flutter/material.dart';
import 'package:nutriby_frontend/presentation/screens/allergy_facts_screen.dart';

import '../daily_menu_setup_screen.dart';
import '../weekly_plan_setup_screen.dart';

// Halaman Placeholder untuk navigasi
class FeaturePlaceholderScreen extends StatelessWidget {
  final String featureName;
  const FeaturePlaceholderScreen({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(featureName),
        backgroundColor: const Color(0xFFC70039),
      ),
      body: Center(
        child: Text(
          'Halaman Fitur:\n$featureName',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, color: Colors.grey),
        ),
      ),
    );
  }
}

class FeaturesTab extends StatelessWidget {
  const FeaturesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          _buildFeatureCard(
            context: context,
            title: 'MPASI Mingguan',
            subtitle: 'Rencana makan 7 hari penuh gizi.',
            imagePlaceholder: 'assets/images/feature_weekly.png',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const WeeklyPlanSetupScreen(),
              ));
            },
          ),
          const SizedBox(height: 20),
          _buildFeatureCard(
            context: context,
            title: 'Fakta Alergi',
            subtitle: 'Ketahui pemicu & cara menanganinya.',
            imagePlaceholder: 'assets/images/feature_allergy.png',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const AllergyFactsScreen(),
              ));
            },
          ),
          const SizedBox(height: 20),
          _buildFeatureCard(
            context: context,
            title: 'Generate Menu',
            subtitle: 'Buat resep instan sesuai kebutuhan.',
            imagePlaceholder: 'assets/images/feature_generate.png',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const DailyMenuSetupScreen(),
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String imagePlaceholder,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(imagePlaceholder),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.45), BlendMode.darken),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}