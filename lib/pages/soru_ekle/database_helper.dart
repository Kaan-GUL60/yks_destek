import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
  Future<void> addSoru(SoruModel soru) async {
    final db = await instance.database;
    await db.insert(
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
}
