import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BilgiNotuDatabaseHelper {
  // Singleton Pattern
  static final BilgiNotuDatabaseHelper instance =
      BilgiNotuDatabaseHelper._init();
  static Database? _database;

  BilgiNotuDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // DİKKAT: Veritabanı adı farklı olmalı!
    _database = await _initDB('bilgi_notlari.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Bu veritabanı ilk kez oluşturuluyor, o yüzden version: 1
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const nullableTextType = 'TEXT NULL';

    await db.execute('''
      CREATE TABLE bilgi_notlari (
        id $idType,
        ders $textType,
        konu $textType,
        onemDerecesi $intType,
        aciklama $nullableTextType,
        imagePath $textType,
        eklenmeTarihi $textType,
        hatirlaticiTarihi $nullableTextType
      )
    ''');
  }

  // --- CRUD İŞLEMLERİ ---

  // Not Ekleme
  Future<int> addBilgiNotu(BilgiNotuModel not) async {
    final db = await instance.database;
    return await db.insert(
      'bilgi_notlari',
      not.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Tüm Notları Getirme
  Future<List<BilgiNotuModel>> getAllBilgiNotlari() async {
    final db = await instance.database;
    final result = await db.query(
      'bilgi_notlari',
      orderBy: "eklenmeTarihi DESC",
    );
    return result.map((json) => BilgiNotuModel.fromMap(json)).toList();
  }

  // Tek bir notu getirme (Detay sayfası için gerekirse)
  Future<BilgiNotuModel?> getBilgiNotu(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'bilgi_notlari',
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BilgiNotuModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Not Silme
  Future<int> deleteBilgiNotu(int id) async {
    final db = await instance.database;
    return await db.delete('bilgi_notlari', where: 'id = ?', whereArgs: [id]);
  }

  // Not Güncelleme
  Future<int> updateBilgiNotu(BilgiNotuModel not) async {
    final db = await instance.database;
    return await db.update(
      'bilgi_notlari',
      not.toMap(),
      where: 'id = ?',
      whereArgs: [not.id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
