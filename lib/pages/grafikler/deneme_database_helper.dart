import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_model.dart';

class DenemeDatabaseHelper {
  static final DenemeDatabaseHelper instance = DenemeDatabaseHelper._init();
  static Database? _database;

  DenemeDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('denemeler.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1, // Sıfırdan başladığımız için versiyon 1 yeterli
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    // Varsayılan değer 0 olsun ki boş geçilirse hata vermesin
    const intType = 'INTEGER NOT NULL DEFAULT 0';

    // --- 1. TYT TABLOSU ---
    await db.execute('''
      CREATE TABLE tyt_denemeler (
        id $idType,
        denemeAdi $textType,
        tarih $textType,
        turkceD $intType, turkceY $intType,
        sosyalD $intType, sosyalY $intType,
        matD $intType, matY $intType,
        fenD $intType, fenY $intType
      )
    ''');

    // --- 2. AYT TABLOSU (Tüm yeni dersler dahil) ---
    await db.execute('''
      CREATE TABLE ayt_denemeler (
        id $idType,
        denemeAdi $textType,
        tarih $textType,
        alan $textType,
        matD $intType, matY $intType,
        fizD $intType, fizY $intType,
        kimD $intType, kimY $intType,
        biyD $intType, biyY $intType,
        edbD $intType, edbY $intType,
        tar1D $intType, tar1Y $intType,
        cog1D $intType, cog1Y $intType,
        tar2D $intType, tar2Y $intType,
        cog2D $intType, cog2Y $intType,
        felD $intType, felY $intType,
        dinD $intType, dinY $intType
      )
    ''');
  }

  // --- TYT İŞLEMLERİ ---
  Future<int> addTyt(TytDenemeModel deneme) async {
    final db = await instance.database;
    return await db.insert('tyt_denemeler', deneme.toMap());
  }

  Future<List<TytDenemeModel>> getAllTyt() async {
    final db = await instance.database;
    final result = await db.query('tyt_denemeler', orderBy: 'tarih ASC');
    return result.map((json) => TytDenemeModel.fromMap(json)).toList();
  }

  Future<int> deleteTyt(int id) async {
    final db = await instance.database;
    return await db.delete('tyt_denemeler', where: 'id = ?', whereArgs: [id]);
  }

  // --- AYT İŞLEMLERİ ---
  Future<int> addAyt(AytDenemeModel deneme) async {
    final db = await instance.database;
    return await db.insert('ayt_denemeler', deneme.toMap());
  }

  Future<List<AytDenemeModel>> getAllAyt() async {
    final db = await instance.database;
    final result = await db.query('ayt_denemeler', orderBy: 'tarih ASC');
    return result.map((json) => AytDenemeModel.fromMap(json)).toList();
  }

  Future<int> deleteAyt(int id) async {
    final db = await instance.database;
    return await db.delete('ayt_denemeler', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> nukeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'denemeler.db');

    // Veritabanı dosyasını sil
    await deleteDatabase(path);

    // Açık olan bağlantıyı null yap ki tekrar çağrıldığında _initDB çalışsın
    _database = null;
    print("VERİTABANI SİLİNDİ VE SIFIRLANDI.");
  }
}
