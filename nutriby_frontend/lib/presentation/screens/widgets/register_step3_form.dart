import 'package:flutter/material.dart';

// Model sederhana untuk data bahan
class Ingredient {
  final int id;
  final String name;
  Ingredient({required this.id, required this.name});
}

class RegisterStep3Form extends StatefulWidget {
  final VoidCallback onFinish;

  const RegisterStep3Form({super.key, required this.onFinish});

  @override
  State<RegisterStep3Form> createState() => _RegisterStep3FormState();
}

class _RegisterStep3FormState extends State<RegisterStep3Form> {
  // TODO: Ganti list ini dengan data dari API /api/ingredients
  final List<Ingredient> _allIngredients = [
    Ingredient(id: 1, name: 'Udang'),
    Ingredient(id: 2, name: 'Telur'),
    Ingredient(id: 3, name: 'Susu Sapi'),
    Ingredient(id: 4, name: 'Kacang Tanah'),
    Ingredient(id: 5, name: 'Ikan Tuna'),
    Ingredient(id: 6, name: 'Ayam'),
    Ingredient(id: 7, name: 'Brokoli'),
    Ingredient(id: 8, name: 'Wortel'),
    Ingredient(id: 9, name: 'Hati Ayam'),
    Ingredient(id: 10, name: 'Tahu'),
    Ingredient(id: 11, name: 'Tempe'),
    Ingredient(id: 12, name: 'Bayam'),
  ];

  final Set<Ingredient> _selectedAllergies = {};
  final Set<Ingredient> _selectedFavorites = {};

  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _favoriteController = TextEditingController();

  @override
  void dispose() {
    _allergyController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan dialog multi-select
  Future<void> _showMultiSelectDialog({
    required BuildContext context,
    required String title,
    required List<Ingredient> items,
    required Set<Ingredient> initialSelections,
  }) async {
    final Set<Ingredient> tempSelections = {...initialSelections};

    final Set<Ingredient>? result = await showDialog<Set<Ingredient>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFC70039).withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = tempSelections.any((i) => i.id == item.id);
                    return CheckboxListTile(
                      title: Text(item.name, style: const TextStyle(color: Colors.white)),
                      value: isSelected,
                      onChanged: (bool? selected) {
                        setState(() {
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
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Pilih', style: TextStyle(color: Color(0xFFC70039))),
              onPressed: () => Navigator.of(context).pop(tempSelections),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        if (title.contains('Alergi')) {
          _selectedAllergies
            ..clear()
            ..addAll(result);
          _allergyController.text = _selectedAllergies.map((i) => i.name).join(', ');
        } else {
          _selectedFavorites
            ..clear()
            ..addAll(result);
          _favoriteController.text = _selectedFavorites.map((i) => i.name).join(', ');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Image(image: AssetImage('assets/images/logo_putih.png'), height: 60, color: Colors.white),
          const SizedBox(height: 8),
          const Text('NutriBy', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          const Text('Lengkapi alergi & kesukaan anak', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 48),

          // Field untuk Alergi
          _buildDropdownField(
            label: 'Alergi Anak (jika ada)',
            controller: _allergyController,
            onTap: () => _showMultiSelectDialog(
              context: context,
              title: 'Pilih Alergi',
              items: _allIngredients,
              initialSelections: _selectedAllergies,
            ),
          ),
          const SizedBox(height: 20),

          // Field untuk Makanan Kesukaan
          _buildDropdownField(
            label: 'Makanan Kesukaan',
            controller: _favoriteController,
            onTap: () => _showMultiSelectDialog(
              context: context,
              title: 'Pilih Makanan Kesukaan',
              items: _allIngredients,
              initialSelections: _selectedFavorites,
            ),
          ),
          const SizedBox(height: 60),

          ElevatedButton(
            onPressed: widget.onFinish,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Selesai', style: TextStyle(fontSize: 18, color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk membuat field dropdown palsu
  Widget _buildDropdownField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
          ),
        ),
      ],
    );
  }
}