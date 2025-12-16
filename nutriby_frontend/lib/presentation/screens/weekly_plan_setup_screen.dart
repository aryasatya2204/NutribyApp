import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nutriby/models/child.dart';
import 'package:nutriby/models/ingredient.dart';
import 'package:nutriby/models/allergy.dart';
import 'package:nutriby/models/weekly_plan.dart';
import 'package:nutriby/presentation/screens/weekly_plan_display_screen.dart';
import 'package:nutriby/presentation/screens/widgets/loading_dialog.dart';
import 'package:nutriby/services/child_service.dart';
import 'package:nutriby/services/data_service.dart';
import 'package:nutriby/services/weekly_plan_service.dart';
import 'package:nutriby/utils/currency_input_formatter.dart';

import '../../services/data_service.dart';

class WeeklyPlanSetupScreen extends StatefulWidget {
  const WeeklyPlanSetupScreen({super.key});

  @override
  State<WeeklyPlanSetupScreen> createState() => _WeeklyPlanSetupScreenState();
}

class _WeeklyPlanSetupScreenState extends State<WeeklyPlanSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final ChildService _childService = ChildService();
  final DataService _dataService = DataService();
  final WeeklyPlanService _weeklyPlanService = WeeklyPlanService();

  Child? _currentChild;
  List<Allergy> _allAllergies = [];
  List<Ingredient> _allIngredients = [];
  bool _isLoading = true;
  String? _loadingError;

  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _favoriteController = TextEditingController();

  Set<Allergy> _selectedAllergies = {};
  Set<Ingredient> _selectedFavorites = {};

  String _recommendedBudgetHint = "Memuat rekomendasi...";
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
    _favoriteController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final children = await _childService.getMyChildren();
      if (children.isEmpty) {
        throw Exception("Anda belum memiliki data anak.");
      }
      _currentChild = children.first;

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

      // Load favorites
      _selectedFavorites = _currentChild!.favoriteIngredients.toSet();

      _updateTextFields();
      _calculateRecommendedBudgetHint();

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

  void _calculateRecommendedBudgetHint() {
    if (_currentChild?.budgetMin == null || _currentChild?.budgetMax == null) {
      _recommendedBudgetHint = "Rekomendasi tidak tersedia";
      return;
    }
    final double weeklyMin = (_currentChild!.budgetMin!) / 4.2;
    final double weeklyMax = (_currentChild!.budgetMax!) / 4.2;
    final int roundedMin = (weeklyMin / 1000).round() * 1000;
    final int roundedMax = (weeklyMax / 1000).round() * 1000;

    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    _recommendedBudgetHint = "Rekomendasi: ${formatter.format(roundedMin)} - ${formatter.format(roundedMax)}";
  }

  void _updateTextFields() {
    _allergyController.text = _selectedAllergies.map((i) => i.name).join(', ');
    _favoriteController.text = _selectedFavorites.map((i) => i.name).join(', ');
  }

  // ✅ UPDATE: Dialog Alergi dengan penghapusan konflik favorit
  Future<void> _showAllergyDialog() async {
    final Set<Allergy> tempSelections = {..._selectedAllergies};

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFC70039).withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Pilih Alergi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

                    return CheckboxListTile(
                      title: Text(item.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(ingredientsText, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1),
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

                    // Logic Penyelarasan
                    final forbiddenIds = _selectedAllergies
                        .expand((a) => a.ingredients)
                        .map((i) => i.id)
                        .toSet();
                    _selectedFavorites.removeWhere((fav) => forbiddenIds.contains(fav.id));

                    _updateTextFields();
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

  // ✅ UPDATE: Dialog Favorit dengan disable alergi
  Future<void> _showFavoriteDialog() async {
    final Set<Ingredient> tempSelections = {..._selectedFavorites};

    // Kumpulkan ID bahan alergi
    final forbiddenIds = _selectedAllergies
        .expand((a) => a.ingredients)
        .map((i) => i.id)
        .toSet();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFC70039).withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Pilih Makanan Kesukaan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    final isAllergic = forbiddenIds.contains(item.id);

                    return CheckboxListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          color: isAllergic ? Colors.white38 : Colors.white,
                          decoration: isAllergic ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: isAllergic ? const Text("Alergi", style: TextStyle(color: Colors.white30, fontSize: 10)) : null,
                      value: isSelected,
                      onChanged: isAllergic ? null : (bool? selected) {
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
                final bool changed = !(Set.from(_selectedFavorites).containsAll(tempSelections) &&
                    Set.from(tempSelections).containsAll(_selectedFavorites));
                if (changed) {
                  setState(() {
                    _selectedFavorites = tempSelections;
                    _updateTextFields();
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

  Future<void> _handleGeneratePlan() async {
    if (_isLoading || _loadingError != null || _currentChild == null) return;
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(message: "Membuat rencana mingguan..."),
    );

    try {
      if (_preferencesChanged) {
        await _childService.updateChildPreferences(
          childId: _currentChild!.id,
          allergyIds: _selectedAllergies.map((e) => e.id).toList(),
          favoriteIds: _selectedFavorites.map((e) => e.id).toList(),
        );
        _preferencesChanged = false;
      }

      int? budgetInput = int.tryParse(_budgetController.text.replaceAll('.', ''));
      int budgetToSend = budgetInput ?? _currentChild!.budgetMax ?? 0;
      int monthlyBudgetEstimate = (budgetToSend * 4.2).round();


      final WeeklyPlan weeklyPlan = await _weeklyPlanService.generateWeeklyPlan(
        childId: _currentChild!.id,
        budget: monthlyBudgetEstimate,
      );

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WeeklyPlanDisplayScreen(weeklyPlan: weeklyPlan),
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Generate MPASI Mingguan', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _loadingError != null
          ? Center(child: Text('Error: $_loadingError'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Budget Mingguan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: 'Contoh: 150000',
                  helperText: _recommendedBudgetHint,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildDropdownField(
                label: 'Alergi Anak',
                controller: _allergyController,
                onTap: _showAllergyDialog,
              ),
              const SizedBox(height: 24),

              _buildDropdownField(
                label: 'Makanan Kesukaan',
                controller: _favoriteController,
                onTap: _showFavoriteDialog,
              ),
              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: _handleGeneratePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Generate Rencana',
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
          child: const Text(
            '© Copyright by NutriBy',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: "Ketuk untuk memilih",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}