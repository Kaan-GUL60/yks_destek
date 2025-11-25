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
  final int tarD;
  final int tarY;
  final int cogD;
  final int cogY;
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
    this.tarD = 0,
    this.tarY = 0,
    this.cogD = 0,
    this.cogY = 0,
    this.felD = 0,
    this.felY = 0,
    this.dinD = 0,
    this.dinY = 0,
  });

  // Veritabanına Yazma
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'denemeAdi': denemeAdi,
      'tarih': tarih.toIso8601String(),
      'alan': alan,
      'matD': matD,
      'matY': matY,
      'fizD': fizD,
      'fizY': fizY,
      'kimD': kimD,
      'kimY': kimY,
      'biyD': biyD,
      'biyY': biyY,
      'edbD': edbD,
      'edbY': edbY,
      'tarD': tarD,
      'tarY': tarY,
      'cogD': cogD,
      'cogY': cogY,
      'felD': felD,
      'felY': felY,
      'dinD': dinD,
      'dinY': dinY,
    };
  }

  // Veritabanından Okuma - EKSİK OLAN KISIM BUYDU
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
      tarD: map['tarD'],
      tarY: map['tarY'],
      cogD: map['cogD'],
      cogY: map['cogY'],
      felD: map['felD'],
      felY: map['felY'],
      dinD: map['dinD'],
      dinY: map['dinY'],
    );
  }
}
