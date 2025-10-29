import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nutriby_frontend/models/weekly_plan.dart';
import 'package:nutriby_frontend/presentation/screens/recipe_detail_screen.dart';

class DailyPlanScreen extends StatelessWidget {
  final String dayName;
  final List<WeeklyPlanDetail> details;

  const DailyPlanScreen({
    super.key,
    required this.dayName,
    required this.details,
  });

  WeeklyPlanDetail? _getDetailByType(String mealType) {
    try {
      return details.firstWhere((detail) => detail.mealType == mealType);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);

    final morningMeal = _getDetailByType('pagi');
    final afternoonMeal = _getDetailByType('siang');
    final eveningMeal = _getDetailByType('sore');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(dayName, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Menu MPASI untuk hari $dayName:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 24),
          if (morningMeal != null) _buildMealCard('Pagi ☀️', morningMeal, context),
          if (afternoonMeal != null) _buildMealCard('Siang ☀️', afternoonMeal, context),
          if (eveningMeal != null) _buildMealCard('Sore 🌙', eveningMeal, context),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF333333),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: const Text(
            '© Copyright by NutriBy',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(String mealTimeLabel, WeeklyPlanDetail detail, BuildContext context) {
    final recipe = detail.recipe;
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
            _buildRecipeImage(recipe.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealTimeLabel,
                    style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.thermostat, size: 16, color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      Text('${recipe.calories} kkal', style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(width: 12),
                      Icon(Icons.grain, size: 16, color: Colors.brown.shade400),
                      const SizedBox(width: 4),
                      Text(recipe.texture, style: TextStyle(color: Colors.grey[700])),
                    ],
                  )
                ],
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