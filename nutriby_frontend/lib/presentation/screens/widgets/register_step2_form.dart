import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nutriby_frontend/utils/currency_input_formatter.dart';

class RegisterStep2Form extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(Map<String, dynamic> data) onNext;

  final TextEditingController nameController;
  final TextEditingController birthDateController;
  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController incomeController;

  const RegisterStep2Form({
    super.key,
    required this.formKey,
    required this.onNext,
    required this.nameController,
    required this.birthDateController,
    required this.weightController,
    required this.heightController,
    required this.incomeController,
  });

  @override
  State<RegisterStep2Form> createState() => _RegisterStep2FormState();
}

class _RegisterStep2FormState extends State<RegisterStep2Form> {
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
  }

  void _handleNext() {
    if (widget.formKey.currentState!.validate()) {
      final data = {
        'name': widget.nameController.text,
        'birth_date': widget.birthDateController.text,
        'gender': _selectedGender,
        'current_weight': double.tryParse(widget.weightController.text) ?? 0.0,
        'current_height': double.tryParse(widget.heightController.text) ?? 0.0,
        'parent_monthly_income': widget.incomeController.text.replaceAll('.', ''),
      };
      widget.onNext(data);
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstAllowedDate = DateTime(now.year - 2, now.month, now.day);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstAllowedDate,
      lastDate: now,
      helpText: 'Pilih Tanggal Lahir Anak',
    );
    if (picked != null) {
      setState(() {
        widget.birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
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
            const Text('Isi data anak anda', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 48),

            // --- Form Fields ---
            _buildTextField(controller: widget.nameController, label: 'Nama Lengkap Anak', validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 20),
            _buildDateField(),
            const SizedBox(height: 20),
            _buildGenderDropdown(),
            const SizedBox(height: 20),
            _buildTextField(controller: widget.weightController, label: 'Berat Badan (Kg)', keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 20),
            _buildTextField(controller: widget.heightController, label: 'Tinggi Badan (cm)', keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 20),
            _buildTextField(
                controller: widget.incomeController,
                label: 'Pendapatan Bulanan Orang Tua (Rp)',
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ]),
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

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Jenis Kelamin Anak", style: TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'female', child: Text('Perempuan')),
          ],
          onChanged: (value) => setState(() => _selectedGender = value),
          validator: (value) => value == null ? 'Wajib dipilih' : null,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
            errorStyle: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold),
          ),
          dropdownColor: const Color(0xFFC70039),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tanggal Lahir Anak", style: TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.birthDateController,
          readOnly: true,
          onTap: _selectDate,
          decoration: const InputDecoration(
            hintText: "Ketuk untuk memilih tanggal",
            hintStyle: TextStyle(color: Colors.white54),
            suffixIcon: Icon(Icons.calendar_today, color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
            errorStyle: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          validator: (value) => value == null || value.isEmpty ? 'Tanggal lahir wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? formatters,
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
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: formatters,
        ),
      ],
    );
  }
}