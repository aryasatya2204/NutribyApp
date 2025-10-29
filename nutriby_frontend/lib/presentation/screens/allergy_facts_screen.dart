import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nutriby_frontend/models/allergy.dart';
import 'package:nutriby_frontend/models/ingredient.dart';
import 'package:nutriby_frontend/presentation/screens/allergy_detail_screen.dart';
import 'package:nutriby_frontend/services/data_service.dart';

class AllergyFactsScreen extends StatefulWidget {
  const AllergyFactsScreen({super.key});

  @override
  State<AllergyFactsScreen> createState() => _AllergyFactsScreenState();
}

class _AllergyFactsScreenState extends State<AllergyFactsScreen> {
  final DataService _dataService = DataService();
  final TextEditingController _searchController = TextEditingController();
  List<Allergy> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.length >= 2) {
        _performSearch(_searchController.text);
      } else {
        setState(() => _searchResults = []);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    try {
      final results = await _dataService.searchAllergies(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencari: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildSafeImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset('assets/images/placeholder_gizi.png',
          width: 50, height: 50, fit: BoxFit.cover);
    }
    return Image.network(
      imageUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
      progress == null ? child : Container(width: 50, height: 50, color: Colors.grey[200]),
      errorBuilder: (context, error, stackTrace) =>
          Image.asset('assets/images/placeholder_gizi.png', width: 50, height: 50, fit: BoxFit.cover),
    );
  }

  Widget _buildSingleIngredientCard(Allergy allergy, Ingredient ingredient) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildSafeImage(ingredient.fullImageUrl),
        ),
        title: Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(allergy.name),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AllergyDetailScreen(allergy: allergy),
          ));
        },
      ),
    );
  }

  Widget _buildGroupIngredientCard(Allergy allergy) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildSafeImage(allergy.fullImageUrl),
              ),
              title: Text(allergy.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text("Grup Alergi (${allergy.ingredients.length} bahan terkait)"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AllergyDetailScreen(allergy: allergy),
                ));
              },
            ),
            const Divider(),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12.0,
              runSpacing: 8.0,
              children: allergy.ingredients.map((ingredient) {
                return Chip(
                  avatar: ClipOval(child: _buildSafeImage(ingredient.fullImageUrl)), // Gunakan fullImageUrl
                  label: Text(ingredient.name),
                  backgroundColor: Colors.grey[100],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Fakta Alergi', style: TextStyle(color: primaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari bahan makanan atau gejala...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : _searchResults.isEmpty && _searchController.text.length >= 2
                ? const Center(child: Text('Tidak ada hasil yang ditemukan.'))
                : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final allergy = _searchResults[index];
                if (allergy.ingredients.length == 1) {
                  return _buildSingleIngredientCard(allergy, allergy.ingredients.first);
                } else if (allergy.ingredients.isNotEmpty) {
                  return _buildGroupIngredientCard(allergy);
                } else {
                  return ListTile(title: Text(allergy.name));
                }
              },
            ),
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
}