import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nutriby_frontend/models/child.dart';
import 'package:nutriby_frontend/models/ingredient.dart';
import 'package:nutriby_frontend/models/allergy.dart';
import 'package:nutriby_frontend/models/user_model.dart';
import 'package:nutriby_frontend/services/auth_service.dart';
import 'package:nutriby_frontend/services/child_service.dart';
import 'package:nutriby_frontend/services/data_service.dart';
import 'package:nutriby_frontend/utils/currency_input_formatter.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Child> _childFuture;
  Child? _currentChild;

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  void _loadChildData() {
    setState(() {
      _childFuture = ChildService().getMyChildren().then((children) {
        if (children.isNotEmpty) {
          _currentChild = children.first;
          return _currentChild!;
        }
        throw Exception("Data anak tidak ditemukan");
      });
    });
  }

  String _calculateAge(String birthDateStr) {
    try {
      final birthDate = DateTime.parse(birthDateStr);
      final now = DateTime.now();
      int years = now.year - birthDate.year;
      int months = now.month - birthDate.month;

      if (now.day < birthDate.day) {
        months--;
      }
      if (months < 0) {
        years--;
        months += 12;
      }

      if (years > 0) {
        return '$years tahun, $months bulan';
      }
      return '$months bulan';
    } catch (e) {
      return 'N/A';
    }
  }

  /// Menampilkan dialog pop-up untuk mengedit data.
  Future<void> _showEditDialog() async {
    if (_currentChild == null) return;

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EditProfileDialog(child: _currentChild!);
      },
    );

    if (result == true) {
      _loadChildData();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);
    final User? user = Provider.of<AuthService>(context, listen: false).user;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: FutureBuilder<Child>(
        future: _childFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Data anak tidak tersedia.'));
          }

          final Child child = snapshot.data!;
          final String childAge = _calculateAge(child.birthDate);
          final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          final budgetRecommendation =
              '${currencyFormatter.format(child.budgetMin ?? 0)} - ${currencyFormatter.format(child.budgetMax ?? 0)}';

          // Helper untuk menampilkan list ingredient
          String ingredientsToString(List<Ingredient> ingredients) {
            if (ingredients.isEmpty) return 'Belum diisi';
            return ingredients.map((e) => e.name).join(', ');
          }

          // ✅ FIX: Helper untuk menampilkan list allergy
          String allergiesToString(List<Allergy> allergies) {
            if (allergies.isEmpty) return 'Belum diisi';
            return allergies.map((e) => e.name).join(', ');
          }

          return RefreshIndicator(
            onRefresh: () async => _loadChildData(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                _buildProfileHeader(child, childAge),
                const SizedBox(height: 24),
                _buildSectionTitle('Informasi Anak'),
                _buildInfoCard(children: [
                  _buildPermanentInfoTile('Nama Anak', child.name, Icons.child_care_outlined),
                  _buildPermanentInfoTile('Jenis Kelamin', child.gender == 'male' ? 'Laki-laki' : 'Perempuan', Icons.wc_outlined),
                  _buildPermanentInfoTile('Berat Badan (kg)', child.currentWeight.toStringAsFixed(1), Icons.monitor_weight_outlined),
                  _buildPermanentInfoTile('Tinggi Badan (cm)', child.currentHeight.toStringAsFixed(1), Icons.height_outlined),
                ]),
                _buildSectionTitle('Preferensi Makanan'),
                _buildInfoCard(children: [
                  // ✅ Gunakan allergiesToString
                  _buildPermanentInfoTile('Alergi', allergiesToString(child.allergies), Icons.block),
                  _buildPermanentInfoTile('Makanan Kesukaan', ingredientsToString(child.favoriteIngredients), Icons.favorite_border),
                ]),
                _buildSectionTitle('Status & Rekomendasi'),
                _buildInfoCard(children: [
                  _buildPermanentInfoTile('Status Gizi (TB/U)', child.nutritionalStatusHfa ?? 'N/A', Icons.assessment_outlined),
                  _buildPermanentInfoTile('Rekomendasi Budget', budgetRecommendation, Icons.account_balance_wallet_outlined),
                ]),
                _buildSectionTitle('Informasi Akun'),
                _buildInfoCard(children: [
                  _buildPermanentInfoTile('Nama Pengguna', user?.name ?? 'N/A', Icons.person_outline),
                  _buildPermanentInfoTile('Email', user?.email ?? 'N/A', Icons.email_outlined),
                  _buildPermanentInfoTile('Pendapatan Orang Tua', currencyFormatter.format(child.parentMonthlyIncome), Icons.monetization_on_outlined),
                ]),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showEditDialog,
        label: const Text('Edit Data'),
        icon: const Icon(Icons.edit_outlined),
        backgroundColor: primaryColor,
      ),
    );
  }

  Widget _buildProfileHeader(Child child, String childAge) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        color: Color(0xFFC70039),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Image.asset(
            child.gender == 'male' ? 'assets/images/gender_boy.png' : 'assets/images/gender_girl.png',
            height: 100,
          ),
          const SizedBox(height: 16),
          Text(
            child.name,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            childAge,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Padding _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildPermanentInfoTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[500]),
      title: Text(label, style: const TextStyle(color: Colors.grey)),
      subtitle: Text(
        value,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  final Child child;
  const EditProfileDialog({super.key, required this.child});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _incomeController;

  Set<Allergy> _selectedAllergies = {};
  Set<Ingredient> _selectedFavorites = {};

  List<Allergy> _allAllergies = [];
  List<Ingredient> _allIngredients = [];
  bool _isLoadingData = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.child.currentWeight.toStringAsFixed(1));
    _heightController = TextEditingController(text: widget.child.currentHeight.toStringAsFixed(1));
    _incomeController = TextEditingController(text: NumberFormat.decimalPattern('id_ID').format(widget.child.parentMonthlyIncome));

    _selectedFavorites = widget.child.favoriteIngredients.toSet();

    _fetchData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        DataService().getAllergies(),
        DataService().getIngredients(cleanOnly: true),
      ]);

      if (mounted) {
        setState(() {
          _allAllergies = results[0] as List<Allergy>;
          _allIngredients = results[1] as List<Ingredient>;

          // ✅ FIX: Logika mapping lebih sederhana karena tipe data sudah sama
          final childAllergyIds = widget.child.allergies.map((e) => e.id).toSet();
          _selectedAllergies = _allAllergies
              .where((a) => childAllergyIds.contains(a.id))
              .toSet();

          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ChildService().updateChild(
        childId: widget.child.id,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        income: int.parse(_incomeController.text.replaceAll('.', '')),
        allergyIds: _selectedAllergies.map((e) => e.id).toList(),
        favoriteIds: _selectedFavorites.map((e) => e.id).toList(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showAllergyDialog() async {
    final Set<Allergy> tempSelections = {..._selectedAllergies};

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Pilih Alergi'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              if (_isLoadingData) {
                return const Center(child: CircularProgressIndicator());
              }
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allAllergies.length,
                  itemBuilder: (context, index) {
                    final item = _allAllergies[index];
                    final isSelected = tempSelections.any((i) => i.id == item.id);
                    final ingredientsText = item.ingredients.map((i) => i.name).join(', ');

                    return CheckboxListTile(
                      title: Text(item.name),
                      subtitle: Text(ingredientsText, maxLines: 1, overflow: TextOverflow.ellipsis),
                      value: isSelected,
                      onChanged: (selected) {
                        setDialogState(() {
                          if (selected == true) {
                            tempSelections.add(item);
                          } else {
                            tempSelections.removeWhere((i) => i.id == item.id);
                          }
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedAllergies = tempSelections;
                  final forbiddenIds = _selectedAllergies
                      .expand((a) => a.ingredients)
                      .map((i) => i.id)
                      .toSet();
                  _selectedFavorites.removeWhere((fav) => forbiddenIds.contains(fav.id));
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Pilih'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFavoriteDialog() async {
    final Set<Ingredient> tempSelections = {..._selectedFavorites};

    final forbiddenIds = _selectedAllergies
        .expand((a) => a.ingredients)
        .map((i) => i.id)
        .toSet();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Pilih Makanan Kesukaan'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              if (_isLoadingData) {
                return const Center(child: CircularProgressIndicator());
              }
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allIngredients.length,
                  itemBuilder: (context, index) {
                    final item = _allIngredients[index];
                    final isSelected = tempSelections.any((i) => i.id == item.id);
                    final isAllergic = forbiddenIds.contains(item.id);

                    return CheckboxListTile(
                      title: Text(item.name, style: TextStyle(
                        color: isAllergic ? Colors.grey : Colors.black,
                        decoration: isAllergic ? TextDecoration.lineThrough : null,
                      )),
                      subtitle: isAllergic ? const Text("Tidak bisa dipilih (Alergi)", style: TextStyle(fontSize: 10, color: Colors.red)) : null,
                      value: isSelected,
                      onChanged: isAllergic ? null : (selected) {
                        setDialogState(() {
                          if (selected == true) {
                            tempSelections.add(item);
                          } else {
                            tempSelections.removeWhere((i) => i.id == item.id);
                          }
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedFavorites = tempSelections;
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Pilih'),
            ),
          ],
        );
      },
    );
  }

  String _setToString(Set<dynamic> aSet) {
    if (aSet.isEmpty) return 'Ketuk untuk memilih';
    return aSet.map((e) => e.name).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Data Anak'),
      content: _isSaving
          ? Column(mainAxisSize: MainAxisSize.min, children: const [CircularProgressIndicator(), SizedBox(height: 16), Text("Menyimpan...")])
          : SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Berat Badan (kg)', icon: Icon(Icons.monitor_weight_outlined)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Tinggi Badan (cm)', icon: Icon(Icons.height_outlined)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _incomeController,
                decoration: const InputDecoration(labelText: 'Pendapatan (Rp)', icon: Icon(Icons.monetization_on_outlined)),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Alergi'),
                subtitle: Text(_setToString(_selectedAllergies)),
                trailing: const Icon(Icons.keyboard_arrow_down),
                onTap: _showAllergyDialog,
              ),
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Makanan Kesukaan'),
                subtitle: Text(_setToString(_selectedFavorites)),
                trailing: const Icon(Icons.keyboard_arrow_down),
                onTap: _showFavoriteDialog,
              ),
            ],
          ),
        ),
      ),
      actions: _isSaving ? [] : [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
        ElevatedButton(onPressed: _saveChanges, child: const Text('Simpan')),
      ],
    );
  }
}