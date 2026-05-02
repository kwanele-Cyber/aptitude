import 'package:myapp/core/services/firebase_service.dart';

class RequestRepository {
  final FirebaseService service = FirebaseService();
  final String tableName = "requests";

  // ✅ CREATE
  Future<void> create({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await service.create(location: "$tableName/$id", data: data);
  }

  // ✅ READ (single request)
  Future<dynamic> read(String location) async {
    return await service.read(location: location);
  }

  // ✅ UPDATE (positional args to match your setup)
  Future<void> update(String location, Map<String, dynamic> data) async {
    await service.update(location: location, data: data);
  }

  // ✅ DELETE (optional but good to have)
  Future<void> delete(String location) async {
    await service.delete(location: location);
  }

  // ✅ READ ALL (used for fetching requests)
  Future<List<dynamic>> readAll(String collection) async {
    final data = await service.readAll(location: collection);

    if (data == null) return [];

    return List<dynamic>.from(data);
  }
}
