import '../app_database.dart';
import '../models/user_model.dart';

class UserDao {
  final db = AppDatabase.instance;

  // Insert a new user
  Future<int> insertUser(UserModel user) async {
    final database = await db.database;
    return await database.insert("users", user.toMap());
  }

  // Get user by email (for login)
  Future<UserModel?> getUserByEmail(String email) async {
    final database = await db.database;

    final result = await database.query(
      "users",
      where: "email = ?",
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  // Get user by ID
  Future<UserModel?> getUserById(int userId) async {
    final database = await db.database;

    final result = await database.query(
      "users",
      where: "user_id = ?",
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  // Update profile
  Future<int> updateUser(UserModel user) async {
    final database = await db.database;
    return await database.update(
      "users",
      user.toMap(),
      where: "user_id = ?",
      whereArgs: [user.userId],
    );
  }

  // Delete a user
  Future<int> deleteUser(int id) async {
    final database = await db.database;
    return await database.delete(
      "users",
      where: "user_id = ?",
      whereArgs: [id],
    );
  }
}
