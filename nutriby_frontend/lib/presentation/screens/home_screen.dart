import 'package:flutter/material.dart';
import 'package:nutriby_frontend/presentation/screens/widgets/features_tab.dart';
import 'package:nutriby_frontend/presentation/screens/widgets/information_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna utama dari UI
    const Color primaryColor = Color.fromRGBO(163, 25, 25, 1);

    return DefaultTabController(
      length: 2, // Kita punya 2 tab: Information & Features
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          // Tombol Profile di kiri
          leading: IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white, size: 30),
            onPressed: () {
              // TODO: Navigasi ke halaman Profile
            },
          ),
          // Logo di tengah
          title: const Image(
            image: AssetImage('assets/images/logo_putih.png'), // Pastikan path logo benar
            height: 40,
          ),
          centerTitle: true,
          // TabBar di bagian bawah AppBar
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3.0,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 16),
            tabs: [
              Tab(text: 'INFORMATION'),
              Tab(text: 'FEATURES'),
            ],
          ),
        ),
        // Konten akan berubah sesuai tab yang dipilih
        body: const TabBarView(
          children: [
            InformationTab(), // UI dari image_fc2569.png
            FeaturesTab(),    // UI dari image_fc2567.jpg
          ],
        ),
        // Footer Copyright
        bottomNavigationBar: BottomAppBar(
          color: const Color.fromRGBO(80, 80, 80, 1),
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