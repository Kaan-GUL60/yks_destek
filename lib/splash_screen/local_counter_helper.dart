import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalCounterHelper {
  static final LocalCounterHelper instance = LocalCounterHelper._();
  LocalCounterHelper._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'open_counter.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE counter(id INTEGER PRIMARY KEY, count INTEGER)',
        );
        await db.insert('counter', {'id': 1, 'count': 0});
      },
    );
    return _db!;
  }

  Future<int> increment() async {
    final database = await db;
    final res = await database.query('counter', where: 'id=1');
    int current = res.first['count'] as int;
    current++;
    await database.update('counter', {'count': current}, where: 'id=1');
    return current;
  }

  Future<int> getCount() async {
    final database = await db;
    final res = await database.query('counter', where: 'id=1');
    return res.first['count'] as int;
  }

  Future<void> reset() async {
    final database = await db;
    await database.update('counter', {'count': 0}, where: 'id=1');
  }
}
