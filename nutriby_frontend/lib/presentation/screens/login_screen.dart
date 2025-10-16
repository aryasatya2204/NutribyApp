import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nutriby_frontend/presentation/screens/home_screen.dart'; // Asumsi ada home screen
import 'package:nutriby_frontend/presentation/screens/register_screen.dart';
import 'package:nutriby_frontend/services/auth_service.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
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
    // Menggunakan Consumer untuk rebuild widget saat state berubah (misal, isLoading)
    final authService = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header... (Sama seperti sebelumnya)
              const SizedBox(height: 20),
              const Image(image: AssetImage('assets/images/gambar_bayi.png'), height: 60, color: Colors.white),
              const SizedBox(height: 8),
              const Text('NutriBy', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              const Text('Masuk dengan akun tertaut', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 48),

              // Form Fields
              _buildEmailField(),
              const SizedBox(height: 20),
              _buildPasswordField(),
              const SizedBox(height: 12),
              _buildForgotPasswordButton(),
              const SizedBox(height: 24),

              // Tombol Login dengan Indikator Loading
              context.watch<AuthService>().isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _buildLoginButton(),

              const SizedBox(height: 48),
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helpers untuk kerapian kode
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: const InputDecoration(
        labelText: 'Email',
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email tidak boleh kosong';
        }
        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return 'Masukkan alamat email yang valid';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      obscureText: !_isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () { /* TODO: Navigasi ke Lupa Password */ },
        child: const Text('Forgot Password?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Text('Log In', style: TextStyle(fontSize: 18, color: Color(0xFFC70039), fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontFamily: 'Inter', color: Colors.white70, fontSize: 14),
          children: <TextSpan>[
            const TextSpan(text: "Belum punya akun? "),
            TextSpan(
              text: 'Daftar di sini',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}