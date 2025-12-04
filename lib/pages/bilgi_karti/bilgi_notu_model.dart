// lib/models/bilgi_notu_model.dart

class BilgiNotuModel {
  final int? id;
  final String ders;
  final String konu;
  final int onemDerecesi; // 0: Kritik, 1: Olağan, 2: Düşük
  final String aciklama;
  final String imagePath;
  final DateTime eklenmeTarihi;
  final DateTime? hatirlaticiTarihi;

  BilgiNotuModel({
    this.id,
    required this.ders,
    required this.konu,
    required this.onemDerecesi,
    required this.aciklama,
    required this.imagePath,
    required this.eklenmeTarihi,
    this.hatirlaticiTarihi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ders': ders,
      'konu': konu,
      'onemDerecesi': onemDerecesi,
      'aciklama': aciklama,
      'imagePath': imagePath,
      'eklenmeTarihi': eklenmeTarihi.toIso8601String(),
      'hatirlaticiTarihi': hatirlaticiTarihi?.toIso8601String(),
    };
  }

  factory BilgiNotuModel.fromMap(Map<String, dynamic> map) {
    return BilgiNotuModel(
      id: map['id'],
      ders: map['ders'],
      konu: map['konu'],
      onemDerecesi: map['onemDerecesi'],
      aciklama: map['aciklama'],
      imagePath: map['imagePath'],
      eklenmeTarihi: DateTime.parse(map['eklenmeTarihi']),
      hatirlaticiTarihi: map['hatirlaticiTarihi'] != null
          ? DateTime.parse(map['hatirlaticiTarihi'])
          : null,
    );
  }
}
