import 'package:flutter/material.dart';

class RegisterStep1Form extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  final Function(Map<String, dynamic> data) onNext;

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const RegisterStep1Form({
    super.key,
    required this.formKey,
    required this.onNext,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<RegisterStep1Form> createState() => _RegisterStep1FormState();
}

class _RegisterStep1FormState extends State<RegisterStep1Form> {

  void _handleNext() {
    if (widget.formKey.currentState!.validate()) {
      final data = {
        'name': widget.nameController.text,
        'email': widget.emailController.text,
        'password': widget.passwordController.text,
      };
      widget.onNext(data);
    }
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
            // --- Header ---
            const SizedBox(height: 20),
            const Image(image: AssetImage('assets/images/gambar_bayi.png'), height: 60, color: Colors.white),
            const SizedBox(height: 8),
            const Text('NutriBy', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            const Text('Isi data anda dibawah', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 48),

            // --- Form Fields ---
            _buildTextField(
              controller: widget.nameController,
              label: 'Username',
              validator: (value) => value == null || value.isEmpty ? 'Username tidak boleh kosong' : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: widget.emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Masukkan alamat email yang valid';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: widget.passwordController,
              label: 'Password',
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                if (value.length < 8) return 'Password minimal 8 karakter';
                return null;
              },
            ),
            const SizedBox(height: 40),

            // --- Action Button ---
            ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Selanjutnya', style: TextStyle(fontSize: 18, color: primaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
            errorStyle: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }
}