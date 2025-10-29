import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nutriby_frontend/models/child.dart';
import 'package:nutriby_frontend/models/ingredient.dart';
import 'package:nutriby_frontend/models/weekly_plan.dart';
import 'package:nutriby_frontend/presentation/screens/weekly_plan_display_screen.dart'; // Halaman selanjutnya
import 'package:nutriby_frontend/presentation/screens/widgets/loading_dialog.dart';
import 'package:nutriby_frontend/services/child_service.dart';
import 'package:nutriby_frontend/services/data_service.dart';
import 'package:nutriby_frontend/services/weekly_plan_service.dart';
import 'package:nutriby_frontend/utils/currency_input_formatter.dart';

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
  List<Ingredient> _allIngredients = [];
  bool _isLoading = true;
  String? _loadingError;

  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _favoriteController = TextEditingController();
  Set<Ingredient> _selectedAllergies = {};
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

      _allIngredients = await _dataService.getIngredients();

      _selectedAllergies = _currentChild!.allergies.toSet();
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

  Future<void> _showMultiSelectDialog({
    required String title,
    required Set<Ingredient> currentSelections,
    required Set<Ingredient> disabledSelections,
  }) async {
    Future<void> _showMultiSelectDialog({
      required String title,
      required Set<Ingredient> currentSelections,
      required Set<Ingredient> disabledSelections,
    }) async {
      final Set<Ingredient> tempSelections = {...currentSelections};

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFFC70039).withOpacity(0.95),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

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
                      final bool isDisabled = disabledSelections.any((i) => i.id == item.id);

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
                  final bool changed = !(Set.from(currentSelections).containsAll(tempSelections) &&
                      Set.from(tempSelections).containsAll(currentSelections));

                  if (changed) {
                    setState(() {
                      if (title.contains('Alergi')) {
                        _selectedAllergies.clear();
                        _selectedAllergies.addAll(tempSelections);
                        _selectedFavorites.removeWhere((fav) => tempSelections.any((sel) => sel.id == fav.id));
                      } else {
                        _selectedFavorites.clear();
                        _selectedFavorites.addAll(tempSelections);
                        _selectedAllergies.removeWhere((alg) => tempSelections.any((sel) => sel.id == alg.id));
                      }
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
    final Set<Ingredient> tempSelections = {...currentSelections};

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFC70039).withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    final bool isDisabled = disabledSelections.any((i) => i.id == item.id);

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
                final bool changed = !(Set.from(currentSelections).containsAll(tempSelections) &&
                    Set.from(tempSelections).containsAll(currentSelections));
                if (changed) {
                  setState(() {
                    if (title.contains('Alergi')) {
                      _selectedAllergies.clear();
                      _selectedAllergies.addAll(tempSelections);
                      _selectedFavorites.removeWhere((fav) => tempSelections.any((sel) => sel.id == fav.id));
                    } else {
                      _selectedFavorites.clear();
                      _selectedFavorites.addAll(tempSelections);
                      _selectedAllergies.removeWhere((alg) => tempSelections.any((sel) => sel.id == alg.id));
                    }
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
                onTap: () => _showMultiSelectDialog(
                  title: 'Pilih Alergi',
                  currentSelections: _selectedAllergies,
                  disabledSelections: _selectedFavorites,
                ),
              ),
              const SizedBox(height: 24),

              _buildDropdownField(
                label: 'Makanan Kesukaan',
                controller: _favoriteController,
                onTap: () => _showMultiSelectDialog(
                  title: 'Pilih Makanan Kesukaan',
                  currentSelections: _selectedFavorites,
                  disabledSelections: _selectedAllergies,
                ),
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