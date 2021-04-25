import 'package:aps_chat/models/theme_config_data.dart';
import 'package:path/path.dart' as pathImport;
import 'package:sqflite/sqflite.dart' as sql;

abstract class DbUtil {
  static sql.Database _db;

  static final nameDb = 'data.db';
  static final tableTheme = 'theme';
  static final themeField = 'isDarkTheme';

  static Future<void> initDb() async {
    final path = await sql.getDatabasesPath();

    _db = await sql.openDatabase(
      pathImport.join(path, nameDb),
      onCreate: (db, version) {
        return db.execute('CREATE TABLE $tableTheme (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $themeField INTEGER)');
      },
      version: 1,
    );
  }

  static Future<int> saveTheme(bool isDarkMode) async {
    final hasThemeOnDb = await getTheme();
    final themeUpdated = {
      themeField: isDarkMode ? 1 : 0,
    };
    if (hasThemeOnDb != null) {
      return _updateTheme(themeUpdated);
    }
    else {
      final newThemeId = await _db.insert(
        tableTheme,
        themeUpdated,
      );

      return newThemeId;
    }
  }

  static Future<int> _updateTheme(Map<String, dynamic> data) async {
    var themeUpdatedId = await _db.update(
      tableTheme,
      data,
    );

    return themeUpdatedId;
  }

  static Future<bool> getTheme() async {
    final themeOnDb = await _db.query(tableTheme);
    if (themeOnDb == null || themeOnDb.isEmpty) {
      return null;
    }

    final theme = ThemeConfigData.fromDbMap(themeOnDb.first);
    return theme.isDarkTheme;
  }

  static Future<void> clearData() async {
    await _db.delete(
      tableTheme
    );
  }
}