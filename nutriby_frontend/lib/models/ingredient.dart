class Ingredient {
  final int id;
  final String name;
  final String? imageUrl; // TAMBAHKAN INI

  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    // Pastikan base URL ini sesuai dengan server Laravel Anda
    // (10.0.2.2:8000 untuk emulator Android, IP komputer Anda untuk device fisik)
    return 'http://10.0.2.2:8000/storage/$imageUrl';
  }

  Ingredient({
    required this.id,
    required this.name,
    this.imageUrl, // TAMBAHKAN INI
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'], // TAMBAHKAN INI
    );
  }
}