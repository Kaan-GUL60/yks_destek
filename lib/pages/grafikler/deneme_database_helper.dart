// lib/services/deneme_database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_model.dart'; // Model dosyanın yolu

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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // TYT Tablosu
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

    // AYT Tablosu (Tüm dersleri içerir, alana göre doldurulur)
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
        tarD $intType, tarY $intType,
        cogD $intType, cogY $intType,
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

  // --- AYT İŞLEMLERİ ---
  Future<int> addAyt(AytDenemeModel deneme) async {
    final db = await instance.database;
    return await db.insert('ayt_denemeler', deneme.toMap());
  }

  // --- TYT OKUMA (Tarihe göre eskiden yeniye) ---
  Future<List<TytDenemeModel>> getAllTyt() async {
    final db = await instance.database;
    // Grafikte tarih sırası önemli olduğu için ORDER BY tarih ASC dedik
    final result = await db.query('tyt_denemeler', orderBy: 'tarih ASC');
    return result.map((json) => TytDenemeModel.fromMap(json)).toList();
  }

  // --- AYT OKUMA ---
  Future<List<AytDenemeModel>> getAllAyt() async {
    final db = await instance.database;
    final result = await db.query('ayt_denemeler', orderBy: 'tarih ASC');
    return result.map((json) => AytDenemeModel.fromMap(json)).toList();
  }

  // Veri silme (Opsiyonel, listeden kaydırma ile silmek istersen)
  Future<int> deleteTyt(int id) async {
    final db = await instance.database;
    return await db.delete('tyt_denemeler', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAyt(int id) async {
    final db = await instance.database;
    return await db.delete('ayt_denemeler', where: 'id = ?', whereArgs: [id]);
  }
}
