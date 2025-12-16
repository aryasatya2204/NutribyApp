import 'package:flutter/material.dart';
import 'package:nutriby/presentation/screens/profile_screen.dart';
import 'package:nutriby/presentation/screens/widgets/features_tab.dart';
import 'package:nutriby/presentation/screens/widgets/information_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          title: const Image(
            image: AssetImage('assets/images/gambar_bayi.png'),
            height: 40,
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3.0,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
            unselectedLabelStyle: TextStyle(fontSize: 16, fontFamily: 'Inter'),
            tabs: [
              Tab(text: 'INFORMASI'),
              Tab(text: 'FITUR'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            InformationTab(),
            FeaturesTab(),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF333333),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: const Text(
              '© Copyright by NutriBy',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}