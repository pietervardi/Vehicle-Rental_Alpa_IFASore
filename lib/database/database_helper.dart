import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:vehicle_rental/models/user_model.dart';

class DatabaseHelper {
  Database? _database;

  final String databaseName = 'vehiclerental.db';
  final int databaseVersion = 1;
  final String table = 'user';

  Future<Database> initDB() async {
    if (_database != null) return _database!;

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, databaseName);

    return openDatabase(path, version: databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, username TEXT UNIQUE, email TEXT UNIQUE, password TEXT, about TEXT)');
  }

  // Login
  Future<bool> login(UserModel user) async {
    try {
      final Database db = await initDB();
      var result = await db.query(
        table,
        where: 'email = ?',
        whereArgs: [user.email],
      );
      if (result.isNotEmpty) {
        final storedPassword = result.first['password'] as String;
        final matchPassword =
            BCrypt.checkpw(user.password as String, storedPassword);
        if (matchPassword) {
          return true;
        }
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Register
  Future<int> signup(UserModel user) async {
    try {
      final Database db = await initDB();

      final existingUser = await db.query(
        table,
        where: 'email = ? OR username = ?',
        whereArgs: [user.email, user.username],
      );

      if (existingUser.isNotEmpty) {
        return -1;
      } else {
        user.password = BCrypt.hashpw(user.password as String, BCrypt.gensalt());
        return db.insert(table, user.toMap());
      }
    } catch (e) {
      rethrow;
    }
  }

  // Current Login User Data
  Future<UserModel?> getLoginUser(String email) async {
    try {
      final Database db = await initDB();

      var result = await db.query(
        table,
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isNotEmpty) {
        final userMap = result.first;
        return UserModel(
          id: userMap['id'] as int,
          name: userMap['name'] as String,
          username: userMap['username'] as String,
          email: userMap['email'] as String,
          password: userMap['password'] as String,
          about: userMap['about'] as String,
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update User
  // Future<int> updateUser(UserModel user) async {
  //   try {
  //     final Database db = await initDB();

  //     final existingUser = await db.query(
  //       table,
  //       where: 'email = ? OR username = ?',
  //       whereArgs: [user.email, user.username],
  //     );

  //     if (existingUser.isNotEmpty) {
  //       return -1;
  //     } else {
  //       var res = await db.update(
  //         table, 
  //         user.toMap(), 
  //         where: 'id = ?', 
  //         whereArgs: [user.id]
  //       );
  //       return res;
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<int> updateUser(UserModel user) async {
  try {
    final Database db = await initDB();

    final existingUser = await db.query(
      table,
      where: 'email = ? OR username = ?',
      whereArgs: [user.email, user.username],
    );

    if (existingUser.isNotEmpty) {
      for (var userMap in existingUser) {
        UserModel existing = UserModel.fromMap(userMap);
        if (existing.id != user.id) {
          return -1;
        }
      }
    }

    var res = await db.update(
      table, 
      user.toMap(), 
      where: 'id = ?', 
      whereArgs: [user.id]
    );
    return res;
  } catch (e) {
    rethrow;
  }
}


  // Update Password
  Future<int> updatePassword(
      UserModel user, String currentPassword, String newPassword) async {
    try {
      final Database db = await initDB();

      final UserModel? existingUser = await getLoginUser(user.email as String);

      if (existingUser != null) {
        final isCurrentPasswordCorrect =
            BCrypt.checkpw(currentPassword, user.password as String);
        if (isCurrentPasswordCorrect) {
          user.password = BCrypt.hashpw(newPassword, BCrypt.gensalt());
          var res = await db.update(table, {'password': user.password},
              where: 'email = ?', whereArgs: [user.email]);
          return res;
        } else {
          return -2;
        }
      } else {
        return -1;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete User
  Future<int> deleteUser(String email) async {
    try {
      final Database db = await initDB();
      var res = await db.delete(table, where: 'email = ?', whereArgs: [email]);
      return res;
    } catch (e) {
      rethrow;
    }
  }
}