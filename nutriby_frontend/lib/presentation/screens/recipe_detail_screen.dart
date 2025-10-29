import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nutriby_frontend/models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Menu', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: _buildRecipeImage(recipe.fullImageUrl),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            recipe.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[300]),

          _buildInfoSection(
            icon: Icons.child_friendly_outlined,
            title: 'Info Umum',
            content: [
              _buildInfoRow('Usia:', '${recipe.minAgeMonths} - ${recipe.maxAgeMonths ?? '24+'} bulan'),
              _buildInfoRow('Tekstur:', recipe.texture),
            ],
          ),

          _buildInfoSection(
            icon: Icons.local_fire_department_outlined,
            title: 'Informasi Gizi (Per Porsi)',
            content: [
              _buildInfoRow('Kalori:', '${recipe.calories?.toStringAsFixed(0) ?? 'N/A'} kkal'),
              _buildInfoRow('Protein:', '${recipe.proteinGrams?.toStringAsFixed(1) ?? 'N/A'} g'),
              _buildInfoRow('Lemak:', '${recipe.fatGrams?.toStringAsFixed(1) ?? 'N/A'} g'),
            ],
          ),

          _buildInfoSection(
            icon: Icons.list_alt_outlined,
            title: 'Bahan-Bahan',
            content: recipe.ingredients.map((ing) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text('• ${ing.quantity} ${ing.name}'),
              );
            }).toList(),
          ),

          _buildInfoSection(
            icon: Icons.soup_kitchen_outlined,
            title: 'Cara Memasak',
            content: [
              Text(
                recipe.instructions ?? 'Instruksi tidak tersedia.',
                style: const TextStyle(height: 1.5, color: Color(0xFF333333)),
              ),
            ],
          ),
        ],
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

  Widget _buildInfoSection({required IconData icon, required String title, required List<Widget> content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFC70039), size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC70039)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
          Divider(color: Colors.grey[300], height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeImage(String? imageUrl) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(color: Color(0xFFC70039))),
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/images/placeholder_gizi.png',
          fit: BoxFit.cover,
        ),
      )
          : Image.asset(
        'assets/images/placeholder_gizi.png',
        fit: BoxFit.cover,
      ),
    );
  }
}