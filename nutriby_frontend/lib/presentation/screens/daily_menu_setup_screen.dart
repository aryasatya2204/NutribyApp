/**
 * @file daily_menu_setup_screen.dart
 * @description Halaman untuk mengatur filter pencarian resep MPASI harian.
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutriby_frontend/models/child.dart';
import 'package:nutriby_frontend/models/ingredient.dart';
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
  final RecipeService _recipeService = RecipeService(); // Tambahkan RecipeService

  // State
  Child? _currentChild;
  List<Ingredient> _allIngredients = [];
  bool _isLoading = true;
  String? _loadingError;

  // Form Controllers & Selections
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();
  Set<Ingredient> _selectedAllergies = {};
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
    // Implementasi mirip WeeklyPlanSetupScreen
    // ... (Ambil data anak, ambil data ingredients)
    setState(() => _isLoading = true);
    try {
      final children = await _childService.getMyChildren();
      if (children.isEmpty) throw Exception("Anda belum memiliki data anak.");
      _currentChild = children.first;

      _allIngredients = await _dataService.getIngredients();

      _selectedAllergies = _currentChild!.allergies.toSet();
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


  /// Update text field alergi.
  void _updateAllergyTextField() {
    _allergyController.text = _selectedAllergies.map((i) => i.name).join(', ');
  }

  /// Menampilkan dialog multi-select untuk alergi.
  Future<void> _showAllergySelectDialog() async {
    /// Menampilkan dialog multi-select untuk alergi.
    Future<void> _showAllergySelectDialog() async {
      // Salinan sementara dari alergi yang sudah dipilih
      final Set<Ingredient> tempSelections = {..._selectedAllergies};

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // --- Style Dialog ---
            backgroundColor: const Color(0xFFC70039).withOpacity(0.95),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("Pilih Alergi Anak", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

            // --- Konten Dialog (Daftar Checkbox) ---
            content: StatefulBuilder(
              builder: (context, setStateDialog) {
                return SizedBox(
                  width: double.maxFinite,
                  // Tampilkan loading jika data bahan belum siap
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _allIngredients.length,
                    itemBuilder: (context, index) {
                      final item = _allIngredients[index];
                      // Cek apakah item ini sudah dipilih sementara
                      final isSelected = tempSelections.any((i) => i.id == item.id);
                      // Cek apakah item ini adalah bahan utama yang dipilih (harus dinonaktifkan)
                      final isDisabled = _selectedMainIngredient?.id == item.id;

                      // Buat CheckboxListTile
                      return CheckboxListTile(
                        title: Text(
                          item.name,
                          style: TextStyle( // Style berbeda jika item disabled
                            color: isDisabled ? Colors.white54 : Colors.white,
                            decoration: isDisabled ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        value: isSelected,
                        // Set onChanged ke null jika item disabled
                        onChanged: isDisabled ? null : (bool? selected) {
                          // Update state internal dialog (tempSelections)
                          setStateDialog(() {
                            if (selected == true) {
                              tempSelections.add(item);
                            } else {
                              tempSelections.removeWhere((i) => i.id == item.id);
                            }
                          });
                        },
                        activeColor: Colors.white,
                        checkColor: const Color(0xFFC70039), // Warna centang
                      );
                    },
                  ),
                );
              },
            ),

            // --- Tombol Aksi Dialog ---
            actions: [
              TextButton(
                child: const Text('Batal', style: TextStyle(color: Colors.white70)),
                onPressed: () => Navigator.of(context).pop(), // Tutup dialog tanpa menyimpan
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Text('Pilih', style: TextStyle(color: Color(0xFFC70039))),
                onPressed: () {
                  // --- Logika saat tombol 'Pilih' ditekan ---
                  // Bandingkan pilihan sementara dengan pilihan awal (_selectedAllergies)
                  final bool changed = !(Set.from(_selectedAllergies).containsAll(tempSelections) &&
                      Set.from(tempSelections).containsAll(_selectedAllergies));

                  // Hanya update state utama jika ada perubahan
                  if (changed) {
                    setState(() { // Update state _DailyMenuSetupScreenState
                      _selectedAllergies.clear();
                      _selectedAllergies.addAll(tempSelections);
                      _updateAllergyTextField(); // Update teks di text field
                      _preferencesChanged = true; // Set flag bahwa ada perubahan preferensi
                    });
                  }
                  Navigator.of(context).pop(); // Tutup dialog
                },
              ),
            ],
          );
        },
      );
    }
    final Set<Ingredient> tempSelections = {..._selectedAllergies};

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
                  itemCount: _allIngredients.length,
                  itemBuilder: (context, index) {
                    final item = _allIngredients[index];
                    final isSelected = tempSelections.any((i) => i.id == item.id);
                    // Disable jika item ini adalah main ingredient yang dipilih
                    final isDisabled = _selectedMainIngredient?.id == item.id;

                    return CheckboxListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          color: isDisabled ? Colors.white54 : Colors.white,
                          decoration: isDisabled ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      value: isSelected,
                      onChanged: isDisabled ? null : (bool? selected) {
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
                if(changed){
                  setState(() {
                    _selectedAllergies.clear();
                    _selectedAllergies.addAll(tempSelections);
                    _updateAllergyTextField();
                    _preferencesChanged = true;
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


  /// Proses saat tombol "Generate" ditekan.
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
          // Kirim favoriteIds yang ada saat ini agar tidak terhapus
          favoriteIds: _currentChild!.favoriteIngredients.map((e) => e.id).toList(),
        );
        _preferencesChanged = false; // Reset flag
      }

      // 2. Ambil parameter filter
      int? maxCost = int.tryParse(_budgetController.text.replaceAll('.', ''));
      List<int> allergyIds = _selectedAllergies.map((e) => e.id).toList();
      int? mainIngredientId = _selectedMainIngredient?.id;

      // 3. Panggil API search/filter resep
      //    PENTING: Backend perlu endpoint baru/modifikasi untuk ini.
      //    Kita gunakan search yang ada, tapi idealnya perlu endpoint filter.
      final List<Recipe> results = await _recipeService.filterRecipes(
        mainIngredientId: mainIngredientId,
        maxCost: maxCost,
        allergyIds: allergyIds,
        // ageMonths: ageInMonths, // Jika Anda menambahkan filter usia di backend
      );


      if (mounted) {
        Navigator.of(context).pop(); // Tutup loading
        // 4. Navigasi ke halaman hasil
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DailyMenuResultsScreen(recipes: results),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup loading
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
                validator: (value) { // Budget wajib diisi
                  if (value == null || value.isEmpty) return 'Budget wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- Alergi Anak (Editable) ---
              _buildSectionTitle('Alergi Anak (Data Tersimpan)'),
              TextFormField( // Tampilan mirip dropdown
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
                items: _allIngredients.map((ing) {
                  // Disable jika bahan ini ada di daftar alergi
                  final bool isDisabled = _selectedAllergies.any((allergy) => allergy.id == ing.id);
                  return DropdownMenuItem<Ingredient>(
                    value: ing,
                    enabled: !isDisabled, // Disable item
                    child: Text(
                      ing.name,
                      style: TextStyle(color: isDisabled ? Colors.grey : Colors.black),
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
      bottomNavigationBar: BottomAppBar( // Footer konsisten
        color: const Color(0xFF333333),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: const Text('© Copyright by NutriBy', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ),
      ),
    );
  }

  /// Helper untuk judul section.
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