/**
 * @file daily_menu_setup_screen.dart
 * @description Halaman untuk mengatur filter pencarian resep MPASI harian.
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutriby_frontend/models/child.dart';
import 'package:nutriby_frontend/models/ingredient.dart';
import 'package:nutriby_frontend/models/allergy.dart';
import 'package:nutriby_frontend/models/recipe.dart';
import 'package:nutriby_frontend/presentation/screens/daily_menu_results_screen.dart'; // Halaman hasil
import 'package:nutriby_frontend/presentation/screens/widgets/loading_dialog.dart';
import 'package:nutriby_frontend/services/child_service.dart';
import 'package:nutriby_frontend/services/data_service.dart';
import 'package:nutriby_frontend/services/recipe_service.dart'; // Service resep baru
import 'package:nutriby_frontend/utils/currency_input_formatter.dart';

class DailyMenuSetupScreen extends StatefulWidget {
  const DailyMenuSetupScreen({super.key});

  @override
  State<DailyMenuSetupScreen> createState() => _DailyMenuSetupScreenState();
}

class _DailyMenuSetupScreenState extends State<DailyMenuSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final ChildService _childService = ChildService();
  final DataService _dataService = DataService();
  final RecipeService _recipeService = RecipeService();

  // State
  Child? _currentChild;
  List<Allergy> _allAllergies = [];
  List<Ingredient> _allIngredients = [];
  bool _isLoading = true;
  String? _loadingError;

  // Form Controllers & Selections
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();

  Set<Allergy> _selectedAllergies = {};
  Ingredient? _selectedMainIngredient; // Single selection
  bool _preferencesChanged = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  /// Memuat data awal: data anak dan daftar bahan.
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final children = await _childService.getMyChildren();
      if (children.isEmpty) throw Exception("Anda belum memiliki data anak.");
      _currentChild = children.first;

      // Load master data
      final results = await Future.wait([
        _dataService.getAllergies(),
        _dataService.getIngredients(cleanOnly: true),
      ]);

      _allAllergies = results[0] as List<Allergy>;
      _allIngredients = results[1] as List<Ingredient>;

      final childAllergyIds = _currentChild!.allergies.map((e) => e.id).toSet();
      _selectedAllergies = _allAllergies
          .where((a) => childAllergyIds.contains(a.id))
          .toSet();

      _updateAllergyTextField();

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _updateAllergyTextField() {
    _allergyController.text = _selectedAllergies.map((i) => i.name).join(', ');
  }

  /// Menampilkan dialog multi-select untuk alergi.
  Future<void> _showAllergySelectDialog() async {
    final Set<Allergy> tempSelections = {..._selectedAllergies};

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFC70039).withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Pilih Alergi Anak", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SizedBox(
                width: double.maxFinite,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allAllergies.length,
                  itemBuilder: (context, index) {
                    final item = _allAllergies[index];
                    final isSelected = tempSelections.any((i) => i.id == item.id);
                    final ingredientsText = item.ingredients.map((i) => i.name).join(', ');

                    // Cek konflik dengan bahan utama
                    bool conflictsWithMain = false;
                    if (_selectedMainIngredient != null) {
                      conflictsWithMain = item.ingredients.any((i) => i.id == _selectedMainIngredient!.id);
                    }

                    return CheckboxListTile(
                      title: Text(item.name, style: const TextStyle(color: Colors.white)),
                      subtitle: conflictsWithMain
                          ? const Text("Konflik dengan bahan utama", style: TextStyle(color: Colors.yellow, fontSize: 11))
                          : Text(ingredientsText, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      value: isSelected,
                      onChanged: (bool? selected) {
                        setStateDialog(() {
                          if (selected == true) {
                            tempSelections.add(item);
                          } else {
                            tempSelections.removeWhere((i) => i.id == item.id);
                          }
                        });
                      },
                      activeColor: Colors.white,
                      checkColor: const Color(0xFFC70039),
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Pilih', style: TextStyle(color: Color(0xFFC70039))),
              onPressed: () {
                final bool changed = !(Set.from(_selectedAllergies).containsAll(tempSelections) &&
                    Set.from(tempSelections).containsAll(_selectedAllergies));

                if (changed) {
                  setState(() {
                    _selectedAllergies = tempSelections;
                    _updateAllergyTextField();
                    _preferencesChanged = true;

                    // Reset Main Ingredient jika konflik dengan alergi baru
                    if (_selectedMainIngredient != null) {
                      final forbiddenIds = _selectedAllergies.expand((a) => a.ingredients).map((i) => i.id).toSet();
                      if (forbiddenIds.contains(_selectedMainIngredient!.id)) {
                        _selectedMainIngredient = null;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Bahan utama di-reset karena termasuk dalam alergi baru.")),
                        );
                      }
                    }
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleGenerate() async {
    if (_isLoading || _loadingError != null || _currentChild == null) return;
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(message: "Mencari menu..."),
    );

    try {
      // 1. Update alergi jika ada perubahan
      if (_preferencesChanged) {
        await _childService.updateChildPreferences(
          childId: _currentChild!.id,
          allergyIds: _selectedAllergies.map((e) => e.id).toList(),
          favoriteIds: _currentChild!.favoriteIngredients.map((e) => e.id).toList(),
        );
        _preferencesChanged = false;
      }

      // 2. Ambil parameter filter
      int? maxCost = int.tryParse(_budgetController.text.replaceAll('.', ''));
      List<int> allergyIds = _selectedAllergies.map((e) => e.id).toList();
      int? mainIngredientId = _selectedMainIngredient?.id;

      DateTime birthDate;
      try {
        birthDate = DateTime.parse(_currentChild!.birthDate);
      } catch (e) {
        throw Exception('Format tanggal lahir tidak valid');
      }

      final DateTime now = DateTime.now();
      int ageInMonths = ((now.year - birthDate.year) * 12 + (now.month - birthDate.month));

      if (now.day < birthDate.day) {
        ageInMonths--;
      }
      if (ageInMonths < 6) {
        ageInMonths = 6;
      }

      // 3. Panggil API search/filter resep
      final List<Recipe> results = await _recipeService.filterRecipes(
        mainIngredientId: mainIngredientId,
        maxCost: maxCost,
        allergyIds: allergyIds,
        ageMonths: ageInMonths,
      );

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DailyMenuResultsScreen(recipes: results),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);

    // Siapkan set ID bahan yang dilarang (alergi)
    final forbiddenIds = _selectedAllergies.expand((a) => a.ingredients).map((i) => i.id).toSet();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cari Menu Harian', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _loadingError != null
          ? Center(child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('Error: $_loadingError', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
      ))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Budget Per Porsi ---
              _buildSectionTitle('Budget Maksimal Per Porsi'),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: 'Contoh: 15000',
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Budget wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- Alergi Anak (Editable) ---
              _buildSectionTitle('Alergi Anak (Data Tersimpan)'),
              TextFormField(
                controller: _allergyController,
                readOnly: true,
                onTap: _showAllergySelectDialog,
                decoration: InputDecoration(
                  hintText: "Ketuk untuk memilih/mengubah alergi",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),

              // --- Bahan Utama Dicari ---
              _buildSectionTitle('Bahan Makanan Utama Dicari'),
              DropdownButtonFormField<Ingredient>(
                value: _selectedMainIngredient,
                // ✅ FIX 1: isExpanded agar dropdown menyesuaikan lebar layar
                isExpanded: true,
                items: _allIngredients.map((ing) {
                  final bool isDisabled = forbiddenIds.contains(ing.id);
                  return DropdownMenuItem<Ingredient>(
                    value: ing,
                    enabled: !isDisabled,
                    child: Text(
                      ing.name,
                      style: TextStyle(
                        color: isDisabled ? Colors.grey : Colors.black,
                        decoration: isDisabled ? TextDecoration.lineThrough : null,
                      ),
                      // ✅ FIX 2: Handle text panjang dengan ellipsis
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedMainIngredient = value);
                },
                decoration: InputDecoration(
                  hintText: 'Pilih bahan utama',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null ? 'Bahan utama wajib dipilih' : null,
                dropdownColor: Colors.grey[100],
              ),
              const SizedBox(height: 48),

              // --- Tombol Generate ---
              ElevatedButton(
                onPressed: _handleGenerate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Cari Menu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
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

  Padding _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
      ),
    );
  }
}