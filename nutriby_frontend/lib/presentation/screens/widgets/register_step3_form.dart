import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nutriby_frontend/models/allergy.dart';
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

  List<Allergy> _allAllergies = [];
  List<Ingredient> _allIngredients = [];
  bool _isLoading = true;

  final Set<Allergy> _selectedAllergies = {};
  final Set<Ingredient> _selectedFavorites = {};

  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _favoriteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _allergyController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final tokenExists = Provider.of<AuthService>(context, listen: false).token != null;
    if (!tokenExists) return;

    try {
      final results = await Future.wait([
        _dataService.getAllergies(),
        _dataService.getIngredients(cleanOnly: true),
      ]);

      if (mounted) {
        setState(() {
          _allAllergies = results[0] as List<Allergy>;
          _allIngredients = results[1] as List<Ingredient>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateTextFields() {
    _allergyController.text = _selectedAllergies.map((a) => a.name).join(', ');
    _favoriteController.text = _selectedFavorites.map((i) => i.name).join(', ');
  }

  // --- Dialog Pilih Alergi (Tidak Berubah Signifikan) ---
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
                    final allergy = _allAllergies[index];
                    final isSelected = tempSelections.any((a) => a.id == allergy.id);

                    return CheckboxListTile(
                      title: Text(allergy.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        allergy.ingredients.map((i) => i.name).join(', '),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      value: isSelected,
                      onChanged: (bool? selected) {
                        setStateDialog(() {
                          if (selected == true) {
                            tempSelections.add(allergy);
                          } else {
                            tempSelections.removeWhere((a) => a.id == allergy.id);
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
                  _selectedAllergies.clear();
                  _selectedAllergies.addAll(tempSelections);

                  // ✅ LOGIKA PENYELARASAN:
                  // Hapus item dari Favorit jika Alergi baru dipilih yang mengandung bahan tersebut
                  final forbiddenIngredientIds = tempSelections
                      .expand((a) => a.ingredients)
                      .map((i) => i.id)
                      .toSet();

                  _selectedFavorites.removeWhere((fav) => forbiddenIngredientIds.contains(fav.id));

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

  // --- Dialog Pilih Favorit (Dengan Logika Disable Alergi) ---
  Future<void> _showFavoriteDialog() async {
    final Set<Ingredient> tempSelections = {..._selectedFavorites};

    // ✅ LANGKAH 1: Kumpulkan ID semua bahan yang menyebabkan alergi yang dipilih
    // Kita ambil semua ingredient dari setiap Allergy yang dipilih di _selectedAllergies
    final Set<int> allergyIngredientIds = _selectedAllergies
        .expand((allergy) => allergy.ingredients)
        .map((ingredient) => ingredient.id)
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
                    final ingredient = _allIngredients[index];
                    final isSelected = tempSelections.any((i) => i.id == ingredient.id);

                    // ✅ LANGKAH 2: Cek apakah bahan ini termasuk alergi
                    final bool isAllergic = allergyIngredientIds.contains(ingredient.id);

                    return CheckboxListTile(
                      title: Text(
                        ingredient.name,
                        style: TextStyle(
                          // Jika alergi, teks dicoret dan transparan
                          color: isAllergic ? Colors.white30 : Colors.white,
                          decoration: isAllergic ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      // Jika alergi, subtitle beri keterangan
                      subtitle: isAllergic
                          ? const Text("Tidak bisa dipilih (Alergi)", style: TextStyle(color: Colors.white38, fontSize: 11))
                          : null,
                      value: isSelected,
                      // ✅ LANGKAH 3: Matikan checkbox (null) jika alergi
                      onChanged: isAllergic ? null : (bool? selected) {
                        setStateDialog(() {
                          if (selected == true) {
                            tempSelections.add(ingredient);
                          } else {
                            tempSelections.removeWhere((i) => i.id == ingredient.id);
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
                  _selectedFavorites.clear();
                  _selectedFavorites.addAll(tempSelections);
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
              onTap: _showAllergyDialog,
            ),
            const SizedBox(height: 20),

            _buildDropdownField(
              label: 'Makanan Kesukaan',
              controller: _favoriteController,
              onTap: _showFavoriteDialog,
            ),
            const SizedBox(height: 60),

            ElevatedButton(
              onPressed: () {
                final data = {
                  'allergy_ids': _selectedAllergies.map((a) => a.id).toList(),
                  'favorite_ids': _selectedFavorites.map((i) => i.id).toList(),
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

  Widget _buildDropdownField({required String label, required TextEditingController controller, required VoidCallback onTap}) {
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