import 'package:flutter/material.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';
import 'package:kgsyks_destek/theme_section/app_colors.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MyData {
  final int value;
  final Color color;
  final String title;

  MyData({required this.value, required this.color, required this.title});
}

Future<List<MyData>> getSoruSayilariDerseGoreGrafik() async {
  final db = await DatabaseHelper.instance.database;

  final result = await db.rawQuery('''
    SELECT ders, COUNT(*) as soruSayisi
    FROM sorular
    GROUP BY ders
    ORDER BY ders
  ''');

  final Map<String, Color> dersRenkMap = {
    'Türkçe': AppColors.colorTr,
    'Matematik': AppColors.colorMat,
    'Geometri': AppColors.colorGeo,
    'Fizik': AppColors.colorFiz,
    'Kimya': AppColors.colorKim,
    'Biyoloji': AppColors.colorBiy,
    'Tarih': AppColors.colorTar,
    'Coğrafya': AppColors.colorCog,
    'Din': AppColors.colorDin,
    'Felsefe': AppColors.colorFel,
  };

  return result.map((row) {
    final ders = row['ders'] as String;
    final count = row['soruSayisi'] as int;
    final color = dersRenkMap[ders] ?? Colors.grey;
    return MyData(value: count, color: color, title: ders);
  }).toList();
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sorular.db'); // Veritabanı adı
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // SoruModel'e uygun tabloyu oluştur
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const nullableTextType = 'TEXT NULL'; // Boş olabilir alanlar için

    await db.execute('''
      CREATE TABLE sorular (
        id $idType,
        ders $textType,
        konu $textType,
        durum $textType,
        hataNedeni $textType,
        soruCevap $textType,
        aciklama $nullableTextType,
        imagePath $textType,
        eklenmeTarihi $textType,
        hatirlaticiTarihi $nullableTextType
      )
    ''');
  }

  // Veritabanına yeni soru ekleyen metot
  Future<int> addSoru(SoruModel soru) async {
    final db = await instance.database;
    return await db.insert(
      'sorular', // tablo adı
      soru.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Tüm soruları liste halinde döner
  Future<List<SoruModel>> getAllSorular() async {
    final db = await instance.database;
    final result = await db.query(
      'sorular',
      orderBy: "eklenmeTarihi DESC", // Son eklenen en üstte olsun
    );

    return result.map((json) => SoruModel.fromMap(json)).toList();
  }

  // DatabaseHelper.dart içinde

  Future<SoruModel?> getSoru(int id) async {
    final db = await instance.database;

    // 'where' ve 'whereArgs' kullanarak sadece belirli bir ID'ye sahip veriyi sorgula
    final maps = await db.query('sorular', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      // Sorgu sonucu boş değilse ilk elemanı SoruModel'e çevirip dön
      return SoruModel.fromMap(maps.first);
    } else {
      // Sorgu sonucu boşsa null dön
      return null;
    }
  }

  Future<Map<String, int>> getSoruDurumSayilari() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
    SELECT durum, COUNT(*) as sayi
    FROM sorular
    GROUP BY durum
  ''');

    // default değerler
    final Map<String, int> sayilar = {
      'Öğrenildi': 0,
      'Öğrenilecek': 0,
      'Beklemede': 0,
    };

    for (var row in result) {
      final durum = row['durum'] as String;
      final count = row['sayi'] as int;
      sayilar[durum] = count;
    }

    return sayilar;
  }

  // Soru Durumunu ve Hata Nedenini Güncelleme
  Future<void> updateSoruDurum(
    int id,
    String yeniDurum,
    String yeniHataNedeni,
  ) async {
    final db = await instance.database;
    final map = <String, Object?>{
      'durum': yeniDurum,
      // Hata Nedeni SoruModel'de zorunlu olduğu için güncellenmeli.
      'hataNedeni': yeniHataNedeni,
    };

    await db.update('sorular', map, where: 'id = ?', whereArgs: [id]);
  }

  // Soru Açıklamasını Güncelleme (Aynı kaldı, String kullanıyor)
  Future<void> updateSoruAciklama(int id, String yeniAciklama) async {
    final db = await instance.database;
    final map = <String, Object?>{'aciklama': yeniAciklama};

    await db.update('sorular', map, where: 'id = ?', whereArgs: [id]);
  }

  // Hatırlatıcı Tarihini Güncelleme (DateTime'ı String'e çeviriyor)
  Future<void> updateSoruHatirlaticiTarihi(int id, DateTime? yeniTarih) async {
    final db = await instance.database;
    final map = <String, Object?>{
      // Hata 2'nin çözümü burada: DateTime'ı String'e çeviriyoruz
      'hatirlaticiTarihi': yeniTarih?.toIso8601String(),
    };

    await db.update('sorular', map, where: 'id = ?', whereArgs: [id]);
  }
}
