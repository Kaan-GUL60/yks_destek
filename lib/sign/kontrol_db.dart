import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// --- Sabitler ---
const String _tableName = 'settings';
const String _columnKey = 'setting_key';
const String _columnValue = 'setting_value';
const String _databaseName = 'app_settings.db';

// --- Anahtar Sabiti (Kontrol Edeceğimiz Ayar) ---
// Birden fazla boolean ayarınız olursa, bu anahtarları çoğaltabilirsiniz.
const String _isFeatureEnabledKey = 'is_feature_enabled';

class BooleanSettingStorage {
  late Database _database;

  // Veritabanını başlatan metod
  Future<void> initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Ayarlar tablosunu oluştur
        await db.execute('''
          CREATE TABLE $_tableName (
            $_columnKey TEXT PRIMARY KEY,
            $_columnValue INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // Boolean değeri (true/false) kaydetme metodu
  Future<void> saveSetting(bool value) async {
    // Boolean'ı INTEGER'a dönüştür: true=1, false=0
    final int intValue = value ? 1 : 0;

    await _database.insert(
      _tableName,
      {_columnKey: _isFeatureEnabledKey, _columnValue: intValue},
      // Eğer aynı anahtar (_isFeatureEnabledKey) daha önce varsa, üzerine yaz
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Kaydedilmiş boolean değeri okuma metodu
  // Eğer hiçbir değer kaydedilmemişse, varsayılan olarak `false` döner.
  Future<bool> getSetting({bool defaultValue = false}) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      _tableName,
      columns: [_columnValue],
      where: '$_columnKey = ?',
      whereArgs: [_isFeatureEnabledKey],
    );

    if (maps.isNotEmpty) {
      // INTEGER (1 veya 0) değeri boolean'a dönüştür
      // 1 -> true, 0 -> false
      final int? intValue = maps.first[_columnValue] as int?;
      // Eğer değer 1 ise true, değilse (0 ise) false döner
      return intValue == 1;
    } else {
      // Veritabanında kayıt yoksa, varsayılan değeri dön
      return defaultValue;
    }
  }

  // Veritabanını kapatma metodu (uygulama kapandığında veya ihtiyaç duyulduğunda)
  Future<void> closeDatabase() async {
    await _database.close();
  }
}
