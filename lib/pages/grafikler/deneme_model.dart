// lib/models/deneme_model.dart

class TytDenemeModel {
  final int? id;
  final String denemeAdi;
  final DateTime tarih;

  // Dersler (Doğru - Yanlış)
  final int turkceD;
  final int turkceY;
  final int sosyalD;
  final int sosyalY;
  final int matD;
  final int matY;
  final int fenD;
  final int fenY;

  TytDenemeModel({
    this.id,
    this.denemeAdi = "Genel Deneme",
    required this.tarih,
    required this.turkceD,
    required this.turkceY,
    required this.sosyalD,
    required this.sosyalY,
    required this.matD,
    required this.matY,
    required this.fenD,
    required this.fenY,
  });

  // Veritabanına Yazma (Model -> Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'denemeAdi': denemeAdi,
      'tarih': tarih.toIso8601String(),
      'turkceD': turkceD,
      'turkceY': turkceY,
      'sosyalD': sosyalD,
      'sosyalY': sosyalY,
      'matD': matD,
      'matY': matY,
      'fenD': fenD,
      'fenY': fenY,
    };
  }

  // Veritabanından Okuma (Map -> Model) - EKSİK OLAN KISIM BUYDU
  factory TytDenemeModel.fromMap(Map<String, dynamic> map) {
    return TytDenemeModel(
      id: map['id'],
      denemeAdi: map['denemeAdi'],
      tarih: DateTime.parse(map['tarih']),
      turkceD: map['turkceD'],
      turkceY: map['turkceY'],
      sosyalD: map['sosyalD'],
      sosyalY: map['sosyalY'],
      matD: map['matD'],
      matY: map['matY'],
      fenD: map['fenD'],
      fenY: map['fenY'],
    );
  }
}

// ... (TytDenemeModel kısmı aynı kalabilir) ...

class AytDenemeModel {
  final int? id;
  final String denemeAdi;
  final DateTime tarih;
  final String alan; // "SAY", "EA", "SOZ"

  final int matD;
  final int matY;
  final int fizD;
  final int fizY;
  final int kimD;
  final int kimY;
  final int biyD;
  final int biyY;
  final int edbD;
  final int edbY;
  final int tar1D;
  final int tar1Y; // Adını tar1 olarak netleştirelim
  final int cog1D;
  final int cog1Y; // Adını cog1 olarak netleştirelim
  final int tar2D;
  final int tar2Y; // YENİ
  final int cog2D;
  final int cog2Y; // YENİ
  final int felD;
  final int felY;
  final int dinD;
  final int dinY;

  AytDenemeModel({
    this.id,
    this.denemeAdi = "Genel Deneme",
    required this.tarih,
    required this.alan,
    this.matD = 0,
    this.matY = 0,
    this.fizD = 0,
    this.fizY = 0,
    this.kimD = 0,
    this.kimY = 0,
    this.biyD = 0,
    this.biyY = 0,
    this.edbD = 0,
    this.edbY = 0,
    this.tar1D = 0,
    this.tar1Y = 0,
    this.cog1D = 0,
    this.cog1Y = 0,
    this.tar2D = 0,
    this.tar2Y = 0, // YENİ
    this.cog2D = 0,
    this.cog2Y = 0, // YENİ
    this.felD = 0,
    this.felY = 0,
    this.dinD = 0,
    this.dinY = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'denemeAdi': denemeAdi,
      'tarih': tarih.toIso8601String(),
      'alan': alan,
      'matD': matD, 'matY': matY,
      'fizD': fizD, 'fizY': fizY,
      'kimD': kimD, 'kimY': kimY,
      'biyD': biyD, 'biyY': biyY,
      'edbD': edbD, 'edbY': edbY,
      'tar1D': tar1D, 'tar1Y': tar1Y,
      'cog1D': cog1D, 'cog1Y': cog1Y,
      'tar2D': tar2D, 'tar2Y': tar2Y, // YENİ
      'cog2D': cog2D, 'cog2Y': cog2Y, // YENİ
      'felD': felD, 'felY': felY,
      'dinD': dinD, 'dinY': dinY,
    };
  }

  factory AytDenemeModel.fromMap(Map<String, dynamic> map) {
    return AytDenemeModel(
      id: map['id'],
      denemeAdi: map['denemeAdi'],
      tarih: DateTime.parse(map['tarih']),
      alan: map['alan'],
      matD: map['matD'],
      matY: map['matY'],
      fizD: map['fizD'],
      fizY: map['fizY'],
      kimD: map['kimD'],
      kimY: map['kimY'],
      biyD: map['biyD'],
      biyY: map['biyY'],
      edbD: map['edbD'],
      edbY: map['edbY'],
      tar1D: map['tar1D'],
      tar1Y: map['tar1Y'],
      cog1D: map['cog1D'],
      cog1Y: map['cog1Y'],
      tar2D: map['tar2D'] ?? 0,
      tar2Y: map['tar2Y'] ?? 0, // YENİ (null check)
      cog2D: map['cog2D'] ?? 0,
      cog2Y: map['cog2Y'] ?? 0, // YENİ
      felD: map['felD'],
      felY: map['felY'],
      dinD: map['dinD'],
      dinY: map['dinY'],
    );
  }
}
