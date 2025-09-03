// lib/models/soru_model.dart

class SoruModel {
  final int? id;
  final String ders;
  final String konu;
  final String durum;
  final String hataNedeni;
  final String soruCevap;
  final String? aciklama;
  final String imagePath; // Resmin dosya yolunu saklayacağız
  final DateTime eklenmeTarihi;
  final DateTime?
  hatirlaticiTarihi; // Kullanıcı seçmeyebilir, bu yüzden nullable

  SoruModel({
    this.id,
    required this.ders,
    required this.konu,
    required this.durum,
    required this.hataNedeni,
    required this.soruCevap,
    this.aciklama,
    required this.imagePath,
    required this.eklenmeTarihi,
    this.hatirlaticiTarihi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ders': ders,
      'konu': konu,
      'durum': durum,
      'hataNedeni': hataNedeni,
      'soruCevap': soruCevap,
      'aciklama': aciklama,
      'imagePath': imagePath,
      // DateTime nesnelerini veritabanı için String'e çeviriyoruz
      'eklenmeTarihi': eklenmeTarihi.toIso8601String(),
      'hatirlaticiTarihi': hatirlaticiTarihi?.toIso8601String(),
    };
  }

  factory SoruModel.fromMap(Map<String, dynamic> map) {
    return SoruModel(
      id: map['id'],
      ders: map['ders'],
      konu: map['konu'],
      durum: map['durum'],
      hataNedeni: map['hataNedeni'],
      soruCevap: map['soruCevap'],
      aciklama: map['aciklama'],
      imagePath: map['imagePath'],
      // Veritabanından okurken String'i tekrar DateTime'a çeviriyoruz
      eklenmeTarihi: DateTime.parse(map['eklenmeTarihi']),
      hatirlaticiTarihi: map['hatirlaticiTarihi'] != null
          ? DateTime.parse(map['hatirlaticiTarihi'])
          : null,
    );
  }
}
