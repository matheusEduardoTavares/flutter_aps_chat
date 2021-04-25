import 'package:aps_chat/models/user.dart';
import 'package:path/path.dart' as pathImport;
import 'package:sqflite/sqflite.dart' as sql;

abstract class DbUtil {
  static sql.Database _db;

  static final nameDb = 'data.db';
  static final tableUser = 'user';

  static Future<void> initDb() async {
    final path = await sql.getDatabasesPath();

    _db = await sql.openDatabase(
      pathImport.join(path, nameDb),
      onCreate: (db, version) {
        return db.execute('CREATE TABLE $tableUser (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR(60), password VARCHAR(60), isDarkTheme INTEGER, isLogged INTEGER)');
      },
      version: 1,
    );
  }

  static Future<int> saveData(Map<String, dynamic> data) async {
    final newUserId = await _db.insert(
      tableUser,
      data,
    );

    return newUserId;
  }

  static Future<int> updateData(Map<String, dynamic> data) async {
    var userUpdatedId = await _db.update(
      tableUser,
      data,
      where: 'id = ${data["id"]}'
    );

    return userUpdatedId;
  }

  static Future<List<User>> getData() async {
    final users = await _db.query(
      tableUser,
    );

    if (users == null || users.isEmpty) {
      return null;
    }

    final formattedUsers = users.map((user) => User.fromDbMap(user)).toList();

    return formattedUsers;
  }

  static Future<User> getUserById(int id) async {
    final user = await _db.query(
      tableUser,
      where: 'id = ?',
      whereArgs: [id]
    );

    if (user == null || user.isEmpty) {
      return null;
    }

    final currentUser = User.fromDbMap(user.first);

    return currentUser;
  }

  static Future<User> getUserByNameAndPassword(String name, String password) async {
    final user = await _db.query(
      tableUser,
      where: 'name = ? AND password = ?',
      whereArgs: [name, password]
    );

    if (user == null || user.isEmpty) {
      return null;
    }

    final currentUser = User.fromDbMap(user.first);

    return currentUser;
  }

  static Future<void> clearData() async {
    await _db.delete(
      tableUser
    );
  }

  static Future<void> deleteByUserId(int userId) async {
    await _db.delete(
      tableUser,
      where: 'id = ?',
      whereArgs: [userId]
    );
  }
}