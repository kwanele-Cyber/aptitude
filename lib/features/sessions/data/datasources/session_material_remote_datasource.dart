import 'dart:io';
import 'package:myapp/features/sessions/data/models/session_material_model.dart';

abstract class SessionMaterialRemoteDataSource {
  Future<SessionMaterialModel> uploadMaterial({
    required String sessionId,
    required File file,
    required String uploadedBy,
  });
  Future<void> deleteMaterial(String materialId, String sessionId);
  Future<List<SessionMaterialModel>> getSessionMaterials(String sessionId);
}
