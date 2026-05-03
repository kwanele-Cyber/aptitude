import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/session_material.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class MaterialRepository {
  final String _path = "session_materials";
  late final DatabaseService<DataSnapshot> _databaseService;

  MaterialRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  Future<void> uploadMaterial(SessionMaterial material) async {
    await _databaseService.create(
      location: "$_path/${material.sessionId}/${material.id}",
      data: material.toJson(),
    );
  }

  Future<List<SessionMaterial>> getSessionMaterials(String sessionId) async {
    final snapshot = await _databaseService.list(location: "$_path/$sessionId");
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> map = snapshot.value as Map;
      return map.values
          .map((v) =>
              SessionMaterial.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList()
        ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    }
    return [];
  }

  Future<void> deleteMaterial(String sessionId, String materialId) async {
    await _databaseService.delete(
      location: "$_path/$sessionId/$materialId",
    );
  }
}
