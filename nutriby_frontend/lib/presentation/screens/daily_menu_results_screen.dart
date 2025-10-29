import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nutriby_frontend/models/recipe.dart';
import 'package:nutriby_frontend/presentation/screens/recipe_detail_screen.dart';

class DailyMenuResultsScreen extends StatelessWidget {
  final List<Recipe> recipes;

  const DailyMenuResultsScreen({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Menu yang Tersedia', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: recipes.isEmpty
          ? const Center(
        child: Text(
          'Tidak ada resep yang cocok ditemukan.\nCoba ubah kriteria pencarian Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return _buildRecipeCard(context, recipe);
        },
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

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecipeImage(recipe.fullImageUrl),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                recipe.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage(String? imageUrl) {
    return AspectRatio(
      aspectRatio: 16 / 9,
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