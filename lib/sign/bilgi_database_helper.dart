// Gerekli paketleri import ediyoruz.
import 'package:kgsyks_destek/sign/yerel_kayit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// KullaniciModel'in bulunduğu dosyanın yolunu doğru şekilde belirttiğinizden emin olun.
// Dosya adının 'kullanici_model.dart' olduğunu varsayıyorum.

class KullaniciDatabaseHelper {
  // Singleton Pattern: Sınıfın tek bir örneğinin olmasını sağlar.
  static final KullaniciDatabaseHelper instance =
      KullaniciDatabaseHelper._init();
  static Database? _database;

  KullaniciDatabaseHelper._init();

  // Veritabanına erişim noktası.
  // Eğer veritabanı daha önce oluşturulmadıysa _initDB ile oluşturulur.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kullanici.db'); // Veritabanı dosya adı
    return _database!;
  }

  // Veritabanını başlatır ve dosya yolunu ayarlar.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Veritabanı ilk kez oluşturulduğunda tabloyu yaratır.
  Future _createDB(Database db, int version) async {
    // Alan tiplerini tanımlıyoruz.
    const textType = 'TEXT NOT NULL';
    const primaryKeyType =
        'TEXT PRIMARY KEY NOT NULL'; // uid benzersiz olduğu için Primary Key olarak kullanıyoruz.
    const intType = 'INTEGER NOT NULL';
    const boolType =
        'INTEGER NOT NULL'; // SQLite'ta boolean, 0 (false) veya 1 (true) olarak saklanır.

    // 'kullanici' adında bir tablo oluşturuyoruz.
    await db.execute('''
      CREATE TABLE kullanici (
        uid $primaryKeyType,
        userName $textType,
        email $textType,
        profilePhotos $textType,
        sinif $intType,
        sinav $intType,
        alan $intType,
        kurumKodu $textType,
        isPro $boolType
      )
    ''');
  }

  /// Veritabanına kullanıcı ekler veya mevcut kullanıcıyı günceller.
  ///
  /// Genellikle cihazda tek bir kullanıcı verisi tutulacağı için
  /// [ConflictAlgorithm.replace] kullanarak aynı `uid`'ye sahip bir kayıt varsa
  /// eskisini silip yenisini ekler (güncelleme işlemi yapmış olur).
  Future<void> saveKullanici(KullaniciModel kullanici) async {
    final db = await instance.database;
    await db.insert(
      'kullanici', // Tablo adı
      kullanici.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Kayıtlı kullanıcı verisini getirir.
  ///
  /// Cihazda tek bir kullanıcı olacağı varsayılarak ilk bulunan kullanıcıyı döndürür.
  /// Eğer kayıtlı kullanıcı yoksa `null` döner.
  Future<KullaniciModel?> getKullanici() async {
    final db = await instance.database;
    final maps = await db.query(
      'kullanici',
      limit: 1, // Sadece bir kayıt getirmesi yeterli.
    );

    if (maps.isNotEmpty) {
      // Veritabanından gelen map'i tekrar KullaniciModel nesnesine çeviriyoruz.
      return KullaniciModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Kullanıcı verisini siler.
  ///
  /// Bu metot, genellikle kullanıcı "Çıkış Yap" dediğinde çağrılır.
  Future<void> deleteKullanici() async {
    final db = await instance.database;
    await db.delete('kullanici');
  }

  /// Veritabanı bağlantısını kapatır.
  ///
  /// Uygulama kapanırken veya artık veritabanına ihtiyaç duyulmadığında
  /// kaynakları serbest bırakmak için kullanılır.
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
