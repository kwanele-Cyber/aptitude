import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

import 'package:myapp/core/data/extension/model_extensions.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import 'package:myapp/core/utils/logger.dart';

class UserRepository {
  final String _basePath = "users";
  DatabaseService<DataSnapshot>? _databaseService;

  UserRepository({DatabaseService<DataSnapshot>? databaseService}) {
    if (databaseService != null) {
      _databaseService = databaseService;
    } else {
      _databaseService = FirebaseService();
    }
  }

  Future<void> create(User user) async {
    try {
      await _databaseService!.create(
        location: '$_basePath/${user.uid}',
        data: user.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Reads a user by their UID. Returns null if not found.
  Future<User?> read(String userId) async {
    try {
      final snapshot = await _databaseService!.read(
        location: '$_basePath/$userId',
      );

      if (snapshot != null && snapshot.exists && snapshot.value != null) {
        // Firebase RTDB values often come back as Map<dynamic, dynamic>
        // We use Map.from to ensure it matches Map<String, dynamic> for the factory
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          snapshot.value as Map,
        );
        return User.fromJson(data);
      }
      return null;
    } catch (e, stackTrace) {
      // Log error or handle accordingly
      Log.e("Failed to fetch user at $_basePath/$userId", e, stackTrace);
      return null;
    }
  }

  /// Updates specific fields of a user without overwriting the entire record.
  /// Useful for things like updating just the 'bio' or 'location'.
  Future<void> update(String userId, Map<String, dynamic> updates) async {
    try {
      await _databaseService!.update(
        location: '$_basePath/$userId',
        data: updates,
      );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Deletes a user record from the database.
  Future<void> delete(String userId) async {
    try {
      await _databaseService!.delete(location: '$_basePath/$userId');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Lists all users in the database.
  Future<List<User>> listAll() async {
    try {
      final snapshot = await _databaseService!.list(location: _basePath);
      if (snapshot != null && snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> usersMap = snapshot.value as Map;
        return usersMap.entries.map((entry) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(
            entry.value as Map,
          );
          return User.fromJson(data);
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Helper: Checks if a user exists at the given ID.
  Future<bool> exists(String userId) async {
    final user = await read(userId);
    return user != null;
  }
}
