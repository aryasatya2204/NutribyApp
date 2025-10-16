import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nutriby_frontend/models/child.dart';
import 'package:nutriby_frontend/models/user_model.dart';
import 'package:nutriby_frontend/services/auth_service.dart';
import 'package:nutriby_frontend/services/child_service.dart';
import 'package:nutriby_frontend/utils/currency_input_formatter.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ChildService _childService = ChildService();
  late Future<Child> _childFuture;
  Child? _currentChild;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  /// Memuat atau memuat ulang data anak dari server.
  void _loadChildData() {
    setState(() {
      _childFuture = _childService.getMyChildren().then((children) {
        if (children.isNotEmpty) {
          final child = children.first;
          _currentChild = child;
          // Inisialisasi controller dengan data terbaru
          _weightController.text = child.currentWeight.toStringAsFixed(1);
          _heightController.text = child.currentHeight.toStringAsFixed(1);
          _incomeController.text = NumberFormat.decimalPattern('id_ID').format(child.parentMonthlyIncome);
          return child;
        }
        throw Exception("Data anak tidak ditemukan");
      });
    });
  }

  /// Menghitung umur dalam format "X tahun, Y bulan" atau "Y bulan".
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

  /// Meng-handle logika untuk beralih mode edit dan menyimpan data.
  Future<void> _toggleEditAndSave() async {
    // Jika saat ini sedang dalam mode edit, maka simpan data.
    if (_isEditing) {
      if (_currentChild == null) return;
      setState(() => _isSaving = true);

      try {
        final double newWeight = double.tryParse(_weightController.text) ?? 0.0;
        final double newHeight = double.tryParse(_heightController.text) ?? 0.0;
        final int newIncome = int.tryParse(_incomeController.text.replaceAll('.', '')) ?? 0;

        // Panggil service untuk mengirim data update ke backend
        await _childService.updateChildDetails(
          childId: _currentChild!.id,
          weight: newWeight,
          height: newHeight,
          income: newIncome,
        );

        // Jika berhasil, muat ulang data dari server untuk refresh UI
        _loadChildData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Perubahan berhasil disimpan!"), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menyimpan: ${e.toString()}"), backgroundColor: Colors.red),
          );
        }
      } finally {
        setState(() => _isSaving = false);
      }
    }

    // Toggle state editing (masuk/keluar mode edit)
    setState(() => _isEditing = !_isEditing);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _incomeController.dispose();
    super.dispose();
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
        actions: [
          _isSaving
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)),
          )
              : IconButton(
            icon: Icon(_isEditing ? Icons.check_circle_outline : Icons.edit_outlined),
            onPressed: _toggleEditAndSave,
          ),
        ],
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

          return RefreshIndicator(
            onRefresh: () async => _loadChildData(),
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        child.gender == 'male'
                            ? 'assets/images/gender_boy.png'
                            : 'assets/images/gender_girl.png',
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
                ),
                const SizedBox(height: 24),

                _buildSectionTitle('Informasi Anak'),
                _buildInfoCard(children: [
                  _buildPermanentInfoTile('Nama Anak', child.name, Icons.child_care_outlined),
                  _buildPermanentInfoTile('Jenis Kelamin', child.gender == 'male' ? 'Laki-laki' : 'Perempuan', Icons.wc_outlined),
                  _buildEditableInfoTile('Berat Badan (kg)', _weightController, Icons.monitor_weight_outlined),
                  _buildEditableInfoTile('Tinggi Badan (cm)', _heightController, Icons.height_outlined),
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
                  _buildPermanentInfoTile('Password', '********', Icons.lock_outline),
                  _buildEditableInfoTile('Pendapatan Orang Tua (Rp)', _incomeController, Icons.monetization_on_outlined, isCurrency: true),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Padding _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
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

  Widget _buildEditableInfoTile(String label, TextEditingController controller, IconData icon, {bool isCurrency = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[500]),
      title: Text(label, style: const TextStyle(color: Colors.grey)),
      subtitle: _isEditing
          ? TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        decoration: const InputDecoration(isDense: true, border: UnderlineInputBorder()),
        inputFormatters: isCurrency
            ? [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()]
            : [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))], // Hanya 1 angka desimal
      )
          : Text(
        controller.text,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}