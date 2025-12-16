import 'package:flutter/material.dart';
import 'package:nutriby/models/weekly_plan.dart';
import 'package:nutriby/presentation/screens/weekly_plan_display_screen.dart';
import 'package:nutriby/presentation/screens/weekly_plan_setup_screen.dart';
import 'package:nutriby/services/child_service.dart';
import 'package:nutriby/services/weekly_plan_service.dart';

/// Screen entry point untuk Weekly Plan
/// Cek apakah ada plan aktif, jika ada tampilkan, jika tidak redirect ke setup
class WeeklyPlanEntryScreen extends StatefulWidget {
  const WeeklyPlanEntryScreen({super.key});

  @override
  State<WeeklyPlanEntryScreen> createState() => _WeeklyPlanEntryScreenState();
}

class _WeeklyPlanEntryScreenState extends State<WeeklyPlanEntryScreen> {
  final ChildService _childService = ChildService();
  final WeeklyPlanService _weeklyPlanService = WeeklyPlanService();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkActivePlan();
  }

  Future<void> _checkActivePlan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Get current child
      final children = await _childService.getMyChildren();
      if (children.isEmpty) {
        throw Exception("Anda belum memiliki data anak.");
      }
      final currentChild = children.first;

      // 2. Check for active weekly plan
      final WeeklyPlan? activePlan = await _weeklyPlanService.getActiveWeeklyPlan(
        childId: currentChild.id,
      );

      if (mounted) {
        if (activePlan != null) {
          // Ada plan aktif, tampilkan
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => WeeklyPlanDisplayScreen(weeklyPlan: activePlan),
            ),
          );
        } else {
          // Tidak ada plan aktif, ke setup
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const WeeklyPlanSetupScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MPASI Mingguan', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: Center(
        child: _errorMessage != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkActivePlan,
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Coba Lagi'),
            ),
          ],
        )
            : const CircularProgressIndicator(color: primaryColor),
      ),
    );
  }
}