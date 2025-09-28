import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'analysis_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE analysis(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT UNIQUE NOT NULL,
            studyDuration INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // Yeni veri ekleme metodu
  Future<int> insertData(DateTime date, int studyDuration) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return await db.insert('analysis', {
      'date': formattedDate,
      'studyDuration': studyDuration,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Belirli bir tarihe ait kaydı sorgulama
  Future<Map<String, dynamic>?> getDataByDate(DateTime date) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final results = await db.query(
      'analysis',
      where: 'date = ?',
      whereArgs: [formattedDate],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllDataSorted() async {
    final db = await database;
    return await db.query(
      'analysis',
      orderBy: 'date ASC', // en eski → en yeni
    );
  }

  // Tüm verileri tarihe göre sıralı getirme
  Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await database;
    return await db.query('analysis', orderBy: 'date ASC');
  }

  // Veriyi güncelleme metodu
  Future<int> updateData(DateTime date, int studyDuration) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return await db.update(
      'analysis',
      {'studyDuration': studyDuration},
      where: 'date = ?',
      whereArgs: [formattedDate],
    );
  }
  // ----------------------------------------------------
  // KAYIT METODU
  // ----------------------------------------------------
  // DatabaseService sınıfına bu metot eklenmeli:

  final String denemeTable = '''
CREATE TABLE denemeler(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    denemeTipi INTEGER NOT NULL,
    tarih TEXT NOT NULL,
    denemeAdi TEXT NOT NULL,
    toplamNet INTEGER,
    dersSonuclari TEXT
)
''';

  /*Future<int> insertDenemeKayit(DenemeKayit kayit) async {
    final db = await database; // Veritabanı instance'ı
    return await db.insert(
      'denemeler',
      kayit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }*/
}
