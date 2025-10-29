import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutriby_frontend/models/weekly_plan.dart';
import 'package:nutriby_frontend/presentation/screens/daily_plan_screen.dart';

class WeeklyPlanDisplayScreen extends StatefulWidget {
  final WeeklyPlan weeklyPlan;

  const WeeklyPlanDisplayScreen({super.key, required this.weeklyPlan});

  @override
  State<WeeklyPlanDisplayScreen> createState() => _WeeklyPlanDisplayScreenState();
}

class _WeeklyPlanDisplayScreenState extends State<WeeklyPlanDisplayScreen> {
  late int _startDayIndex;
  final List<String> _dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  void initState() {
    super.initState();
    _startDayIndex = DateTime.now().weekday - 1;
  }

  Map<int, List<WeeklyPlanDetail>> _groupDetailsByDay() {
    final Map<int, List<WeeklyPlanDetail>> grouped = {};
    for (var detail in widget.weeklyPlan.details) {
      int dayIndex = detail.dayOfWeek - 1;
      if (!grouped.containsKey(dayIndex)) {
        grouped[dayIndex] = [];
      }
      grouped[dayIndex]!.add(detail);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);
    final groupedDetails = _groupDetailsByDay();

    final List<String> orderedDayNames = [
      ..._dayNames.sublist(_startDayIndex),
      ..._dayNames.sublist(0, _startDayIndex),
    ];
    final List<int> orderedDayIndices = [
      ...List.generate(7 - _startDayIndex, (i) => _startDayIndex + i),
      ...List.generate(_startDayIndex, (i) => i),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MPASI Mingguan', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
        // TODO: Tambahkan tombol "Generate Ulang" di sini jika diinginkan
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Minggu ke-${DateFormat('w').format(DateTime.now())}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: 7,
              itemBuilder: (context, index) {
                final dayIndex = orderedDayIndices[index];
                final dayName = orderedDayNames[index];
                final bool isToday = dayIndex == _startDayIndex;

                return _buildDayCard(
                  dayName: dayName,
                  isToday: isToday,
                  onTap: () {
                    if (groupedDetails.containsKey(dayIndex)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DailyPlanScreen(
                            dayName: dayName,
                            details: groupedDetails[dayIndex]!,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF333333),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: const Text('© Copyright by NutriBy', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildDayCard({required String dayName, required bool isToday, required VoidCallback onTap}) {
    const Color primaryColor = Color(0xFFC70039);
    final Color cardColor = isToday ? primaryColor : Colors.grey.shade300;
    final Color textColor = isToday ? Colors.white : Colors.grey.shade600;
    final IconData icon = isToday ? Icons.restaurant_menu : Icons.lock_outline;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: textColor.withOpacity(isToday ? 1.0 : 0.6)),
            const SizedBox(height: 12),
            Text(
              dayName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}