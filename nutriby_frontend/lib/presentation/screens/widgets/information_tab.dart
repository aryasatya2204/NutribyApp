import 'package:flutter/material.dart';
import 'package:nutriby/data/malnutrition_data.dart';
import 'package:nutriby/models/child.dart';
import 'package:nutriby/services/child_service.dart';

class InformationTab extends StatefulWidget {
  const InformationTab({super.key});

  @override
  State<InformationTab> createState() => _InformationTabState();
}

class _InformationTabState extends State<InformationTab> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  late Future<List<Child>> _childrenFuture;
  final List<Map<String, String>> carouselItems = [
    {
      'title': 'Gizi Seimbang, Anak Cemerlang',
      'subtitle': 'Pastikan MPASI si kecil kaya akan protein hewani untuk tumbuh kembang otaknya.',
      'image_placeholder': 'assets/images/placeholder_gizi.png.jpg',
    },
    {
      'title': 'Pentingnya 1000 Hari Pertama',
      'subtitle': 'Masa emas pertumbuhan otak dan fisik anak yang tidak boleh terlewatkan.',
      'image_placeholder': 'assets/images/placeholder_1000hari.png.jpg',
    },
    {
      'title': 'Kenali Tanda Stunting',
      'subtitle': 'Anak lebih pendek dari teman sebayanya? Mungkin itu salah satu tandanya.',
      'image_placeholder': 'assets/images/placeholder_stunting.png.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _childrenFuture = ChildService().getMyChildren();
  }

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

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC70039);
    const Color yellowColor = Color(0xFFFFE082);

    return FutureBuilder<List<Child>>(
      future: _childrenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Anda belum memiliki data anak.\nSilakan tambahkan data anak di halaman profil.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        final Child firstChild = snapshot.data!.first;
        final String childAge = _calculateAge(firstChild.birthDate);
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Container(
              color: primaryColor,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'Anak Anda: $childAge',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: carouselItems.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = (_pageController.page! - index).abs();
                        value = (1 - (value * 0.15)).clamp(0.85, 1.0);
                      }
                      return Center(
                        child: SizedBox(
                          height: Curves.easeInOut.transform(value) * 180,
                          child: child,
                        ),
                      );
                    },
                    child: _buildCarouselItem(
                      title: carouselItems[index]['title']!,
                      subtitle: carouselItems[index]['subtitle']!,
                      imagePath: carouselItems[index]['image_placeholder']!,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(carouselItems.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index ? primaryColor : Colors.grey.shade400,
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: yellowColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kenali Malnutrisi Pada Anak',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 10),
                    ...malnutritionData.map((item) => _buildExpansionTile(item.title, item.content)).toList(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCarouselItem({required String title, required String subtitle, required String imagePath}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        iconColor: const Color(0xFF333333),
        collapsedIconColor: const Color(0xFF333333),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(color: Colors.grey[800], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}