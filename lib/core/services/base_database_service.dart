import 'package:firebase_database/firebase_database.dart';
import '../exceptions/custom_exception.dart';

abstract class BaseDatabaseService {
  final FirebaseDatabase _db;
  final String pathPrefix;

  BaseDatabaseService({FirebaseDatabase? database, this.pathPrefix = ''}) 
      : _db = database ?? FirebaseDatabase.instance;

  String _resolvePath(String path) {
    if (pathPrefix.isEmpty) return path;
    // Ensure we don't have double slashes
    final cleanPrefix = pathPrefix.endsWith('/') ? pathPrefix.substring(0, pathPrefix.length - 1) : pathPrefix;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$cleanPrefix/$cleanPath';
  }

  // Generic Create/Update
  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final fullPath = _resolvePath(path);
    try {
      await _db.ref(fullPath).set(data).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw DatabaseException("Failed to set data at $fullPath: ${e.toString()}", "database-set-error");
    }
  }

  // Generic Read
  Future<DataSnapshot> getData(String path) async {
    final fullPath = _resolvePath(path);
    try {
      final snapshot = await _db.ref(fullPath).get().timeout(const Duration(seconds: 10));
      if (!snapshot.exists) {
        throw DatabaseException("Data at $fullPath does not exist", "not-found");
      }
      return snapshot;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException("Failed to get data at $fullPath: ${e.toString()}", "database-get-error");
    }
  }
  
  // Added helper for custom queries
  DatabaseReference getRef(String path) => _db.ref(_resolvePath(path));

  // Generic Update
  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final fullPath = _resolvePath(path);
    try {
      await _db.ref(fullPath).update(data).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw DatabaseException("Failed to update data at $fullPath: ${e.toString()}", "database-update-error");
    }
  }

  // Generic Delete
  Future<void> deleteData(String path) async {
    final fullPath = _resolvePath(path);
    try {
      await _db.ref(fullPath).remove();
    } catch (e) {
      throw DatabaseException("Failed to delete data at $fullPath: ${e.toString()}", "database-delete-error");
    }
  }

  // Generic Stream
  Stream<DatabaseEvent> dataStream(String path) {
    return _db.ref(_resolvePath(path)).onValue;
  }

  // Push (Generate unique ID)
  String generateId(String path) {
    return _db.ref(_resolvePath(path)).push().key ?? '';
  }
}
