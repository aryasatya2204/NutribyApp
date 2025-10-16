// Kelas untuk menampung data informasi
class InfoItem {
  final String title;
  final String content;

  InfoItem(this.title, this.content);
}

// Daftar data untuk bagian "Kenali Malnutrisi"
final List<InfoItem> malnutritionData = [
  InfoItem(
    'Apa itu Malnutrisi Anak?',
    'Malnutrisi adalah kondisi medis yang disebabkan oleh asupan gizi yang tidak tepat atau tidak seimbang. Pada anak, ini bisa berarti kekurangan gizi (kurus, pendek/stunting), kelebihan gizi (gemuk/obesitas), atau kekurangan zat gizi mikro seperti vitamin dan mineral.',
  ),
  InfoItem(
    'Penyebab Malnutrisi Anak',
    'Penyebabnya kompleks, mulai dari pola makan yang tidak memadai, infeksi berulang, sanitasi yang buruk, hingga kurangnya pengetahuan orang tua mengenai gizi seimbang untuk MPASI (Makanan Pendamping ASI).',
  ),
  InfoItem(
    'Dampak Malnutrisi Anak',
    'Dampak jangka pendeknya adalah gangguan pertumbuhan fisik dan perkembangan otak. Jangka panjangnya, anak yang mengalami malnutrisi berisiko lebih tinggi menderita penyakit kronis saat dewasa dan memiliki tingkat kecerdasan yang lebih rendah.',
  ),
  InfoItem(
    'Atasi Malnutrisi Anak',
    'Kunci utamanya adalah pemenuhan gizi seimbang sesuai usia. Pastikan MPASI mengandung karbohidrat, protein (terutama hewani seperti hati ayam, telur, ikan), lemak (santan, minyak), serta vitamin dan mineral dari sayur dan buah. Jika ada tanda-tanda malnutrisi, segera konsultasikan dengan dokter anak atau ahli gizi.',
  ),
];