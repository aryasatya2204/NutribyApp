import 'package:flutter/material.dart';

class InformationTab extends StatefulWidget {
  const InformationTab({super.key});

  @override
  State<InformationTab> createState() => _InformationTabState();
}

class _InformationTabState extends State<InformationTab> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  // Data dummy untuk carousel
  final List<Map<String, String>> carouselItems = [
    {
      'title': 'Anak Indonesia Kekurangan Nutrisi?',
      'subtitle': 'Berdasarkan Ahli Gizi Unusa, gizi anak di Indonesia masih menjadi masalah serius...',
    },
    {
      'title': 'Pentingnya 1000 Hari Pertama',
      'subtitle': 'Masa emas pertumbuhan otak dan fisik anak yang tidak boleh terlewatkan.',
    },
    {
      'title': 'Kenali Tanda Stunting',
      'subtitle': 'Anak lebih pendek dari teman sebayanya? Mungkin itu salah satu tandanya.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color.fromRGBO(163, 25, 25, 1);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Bagian Umur Anak
          Container(
            color: primaryColor,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: const Text(
              '3 tahun 2 bulan', // Data umur anak
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(height: 24),

          // Carousel Section
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: carouselItems.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildCarouselItem(
                  title: carouselItems[index]['title']!,
                  subtitle: carouselItems[index]['subtitle']!,
                  color: primaryColor.withOpacity(0.9),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Indikator dots untuk carousel
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(carouselItems.length, (index) {
              return Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? primaryColor : Colors.grey.shade400,
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Bagian Informasi Malnutrisi (Accordion)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 224, 130, 1), // Warna kuning
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kenali Malnutrisi Pada Anak',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                _buildExpansionTile('Apa itu Malnutrisi Anak?'),
                _buildExpansionTile('Penyebab Malnutrisi Anak'),
                _buildExpansionTile('Dampak Malnutrisi Anak'),
                _buildExpansionTile('Atasi Malnutrisi Anak'),
                _buildExpansionTile('Jenis Malnutrisi Anak'),
                _buildExpansionTile('Data Malnutrisi Anak'),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper widget untuk item carousel
  Widget _buildCarouselItem({required String title, required String subtitle, required Color color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        // TODO: Ganti dengan gambar jika sudah ada
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.white70)),
        ],
      ),
    );
  }

  // Helper widget untuk ExpansionTile (efek dropdown)
  Widget _buildExpansionTile(String title) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        iconColor: Colors.black54,
        collapsedIconColor: Colors.black54,
        tilePadding: EdgeInsets.zero,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              'Ini adalah konten dummy. Informasi detail akan ditampilkan di sini ketika data sudah terhubung dengan backend atau sumber data lainnya.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}