import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nutriby_frontend/models/ingredient.dart';
import 'package:nutriby_frontend/services/auth_service.dart';
import 'package:nutriby_frontend/services/data_service.dart';
import 'package:provider/provider.dart';

class RegisterStep3Form extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(Map<String, dynamic> data) onFinish;

  const RegisterStep3Form({
    super.key,
    required this.formKey,
    required this.onFinish,
  });

  @override
  State<RegisterStep3Form> createState() => _RegisterStep3FormState();
}

class _RegisterStep3FormState extends State<RegisterStep3Form> {
  final DataService _dataService = DataService();
  List<Ingredient> _allIngredients = [];
  bool _isLoading = true;

  final Set<Ingredient> _selectedAllergies = {};
  final Set<Ingredient> _selectedFavorites = {};

  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _favoriteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchIngredients();
    });
  }

  @override
  void dispose() {
    _allergyController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  Future<void> _fetchIngredients() async {
    final tokenExists = Provider.of<AuthService>(context, listen: false).token != null;
    if (!tokenExists) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Sesi autentikasi tidak ditemukan.')),
        );
      }
      return;
    }

    try {
      final ingredients = await _dataService.getIngredients();
      if (mounted) {
        setState(() {
          _allIngredients = ingredients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data bahan: ${e.toString()}')),
        );
      }
    }
  }

  void _updateTextFields() {
    _allergyController.text = _selectedAllergies.map((i) => i.name).join(', ');
    _favoriteController.text = _selectedFavorites.map((i) => i.name).join(', ');
  }

  Future<void> _showMultiSelectDialog({
    required String title,
    required List<Ingredient> items,
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
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
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
                setState(() {
                  if (title.contains('Alergi')) {
                    _selectedAllergies.clear();
                    _selectedAllergies.addAll(tempSelections);
                  } else {
                    _selectedFavorites.clear();
                    _selectedFavorites.addAll(tempSelections);
                  }
                  _updateTextFields();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Image(image: AssetImage('assets/images/gambar_bayi.png'), height: 60, color: Colors.white),
            const SizedBox(height: 8),
            const Text('NutriBy', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            const Text('Lengkapi alergi & kesukaan anak', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 48),

            _buildDropdownField(
              label: 'Alergi Anak (jika ada)',
              controller: _allergyController,
              onTap: () => _showMultiSelectDialog(
                title: 'Pilih Alergi',
                items: _allIngredients,
                currentSelections: _selectedAllergies,
                disabledSelections: _selectedFavorites,
              ),
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Makanan Kesukaan',
              controller: _favoriteController,
              onTap: () => _showMultiSelectDialog(
                title: 'Pilih Makanan Kesukaan',
                items: _allIngredients,
                currentSelections: _selectedFavorites,
                disabledSelections: _selectedAllergies,
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                final data = {
                  'allergy_ids': _selectedAllergies.map((e) => e.id).toList(),
                  'favorite_ids': _selectedFavorites.map((e) => e.id).toList(),
                };
                widget.onFinish(data);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Selesai', style: TextStyle(fontSize: 18, color: primaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
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
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: "Ketuk untuk memilih",
            hintStyle: TextStyle(color: Colors.white54),
            suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
          ),
        ),
      ],
    );
  }
}