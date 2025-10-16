import 'package:flutter/material.dart';
import 'package:nutriby_frontend/models/child.dart';
import 'package:nutriby_frontend/presentation/screens/registration_summary_screen.dart';
import 'package:nutriby_frontend/presentation/screens/widgets/loading_dialog.dart';
import 'package:nutriby_frontend/presentation/screens/widgets/register_step1_form.dart';
import 'package:nutriby_frontend/presentation/screens/widgets/register_step2_form.dart';
import 'package:nutriby_frontend/presentation/screens/widgets/register_step3_form.dart';
import 'package:nutriby_frontend/services/auth_service.dart';
import 'package:nutriby_frontend/services/child_service.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Kunci GlobalKey untuk validasi di setiap form
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _childNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _incomeController = TextEditingController();

  // Map untuk mengumpulkan data dari setiap langkah
  final Map<String, dynamic> _registrationData = {};
  // Variabel untuk menyimpan objek Child setelah dibuat
  Child? _createdChild;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _childNameController.dispose();
    _birthDateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan error dengan SnackBar
  void _showError(String message) {
    if (mounted) {
      // Tutup dialog loading jika ada
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // --- LOGIKA ALUR BARU ---

  /// STEP 1: Mendaftarkan & Login pengguna, lalu lanjut ke halaman 2
  Future<void> _handleStep1(Map<String, dynamic> data) async {
    if (!_step1Key.currentState!.validate()) return;
    _registrationData.addAll(data);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(message: "Membuat akun Anda..."),
    );

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      // 1. Mendaftarkan pengguna
      await authService.register(
        name: _registrationData['name'],
        email: _registrationData['email'],
        password: _registrationData['password'],
      );
      // 2. Login untuk mendapatkan token
      await authService.login(
        email: _registrationData['email'],
        password: _registrationData['password'],
      );

      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  /// STEP 2: Membuat data anak, lalu lanjut ke halaman 3
  Future<void> _handleStep2(Map<String, dynamic> data) async {
    if (!_step2Key.currentState!.validate()) return;

    // Hapus format Rupiah sebelum menyimpan
    data['parent_monthly_income'] =
        int.tryParse(data['parent_monthly_income'].replaceAll('.', '')) ?? 0;
    _registrationData.addAll(data);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(message: "Menyimpan data si kecil..."),
    );

    try {
      final childService = ChildService();
      // 3. Membuat data anak menggunakan token yang sudah tersimpan
      final Child newChild = await childService.createChild(_registrationData);
      setState(() {
        _createdChild = newChild; // Simpan objek anak
      });

      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  /// STEP 3: Memperbarui preferensi anak dan navigasi ke halaman summary
  Future<void> _handleStep3(Map<String, dynamic> data) async {
    if (_createdChild == null) {
      _showError("Terjadi kesalahan: Data anak tidak ditemukan.");
      return;
    }

    _registrationData.addAll(data);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(message: "Menyelesaikan pendaftaran..."),
    );

    try {
      final childService = ChildService();
      // 4. Update data anak dengan alergi dan kesukaan
      final updatedChild = await childService.updateChildPreferences(
        childId: _createdChild!.id,
        allergyIds: _registrationData['allergy_ids'],
        favoriteIds: _registrationData['favorite_ids'],
      );

      final authService = Provider.of<AuthService>(context, listen: false);

      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog
        // 5. Navigasi ke halaman summary
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => RegistrationSummaryScreen(
              child: updatedChild, // Kirim data anak yang sudah ter-update
              userName: authService.user?.name ?? _registrationData['name'],
            ),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _previousPage,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  width: 30,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage >= index ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              children: [
                RegisterStep1Form(
                  formKey: _step1Key,
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  onNext: _handleStep1, // Panggil fungsi step 1
                ),
                RegisterStep2Form(
                  formKey: _step2Key,
                  nameController: _childNameController,
                  birthDateController: _birthDateController,
                  weightController: _weightController,
                  heightController: _heightController,
                  incomeController: _incomeController,
                  onNext: _handleStep2, // Panggil fungsi step 2
                ),
                RegisterStep3Form(
                  formKey: _step3Key,
                  onFinish: _handleStep3, // Panggil fungsi step 3
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}