import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/backblaze_service.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/sessions/data/datasources/session_material_remote_datasource.dart';
import 'package:myapp/features/sessions/data/models/session_material_model.dart';
import 'package:myapp/injection_container.dart' as di;

class SessionMaterialRemoteDataSourceFirebase
    implements SessionMaterialRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseDatabase _database;
  final FileStorageService _storageService;

  SessionMaterialRemoteDataSourceFirebase({
    FirebaseAuth? auth,
    FirebaseDatabase? database,
    FileStorageService? storageService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _database = database ?? FirebaseDatabase.instance,
        _storageService = storageService ?? di.sl<FileStorageService>();

  DatabaseReference _materialsRef(String sessionId) =>
      _database.ref('sessionMaterials').child(sessionId);

  @override
  Future<SessionMaterialModel> uploadMaterial({
    required String sessionId,
    required File file,
    required String uploadedBy,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw const ServerException('Not authenticated');

      final uploadResult = await _storageService.uploadFile(
        file,
        bucketId: 'aptitude-files',
      );

      final fileUrl = uploadResult['fileUrl'] as String? ??
          uploadResult['fileName'] as String? ??
          '';
      final fileName = uploadResult['fileName'] as String? ??
          file.uri.pathSegments.last;
      final fileSize = await file.length();
      final mimeType = _inferMimeType(fileName);

      final materialRef = _materialsRef(sessionId).push();
      final now = DateTime.now().toIso8601String();

      final materialData = {
        'sessionId': sessionId,
        'fileName': fileName,
        'fileUrl': fileUrl,
        'fileSize': fileSize,
        'mimeType': mimeType,
        'uploadedBy': uploadedBy,
        'uploadedAt': now,
      };

      await materialRef.set(materialData);
      final snapshot = await materialRef.get();
      if (!snapshot.exists) throw const ServerException();

      return SessionMaterialModel.fromJson(
        materialRef.key ?? '',
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException();
    }
  }

  @override
  Future<void> deleteMaterial(String materialId, String sessionId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw const ServerException('Not authenticated');

      await _materialsRef(sessionId).child(materialId).remove();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException();
    }
  }

  @override
  Future<List<SessionMaterialModel>> getSessionMaterials(
      String sessionId) async {
    try {
      final snapshot = await _materialsRef(sessionId).get();
      if (!snapshot.exists) return [];

      final map = snapshot.value is Map
          ? Map<String, dynamic>.from(snapshot.value as Map)
          : null;
      if (map == null) return [];

      final materials = <SessionMaterialModel>[];
      map.forEach((key, value) {
        materials.add(SessionMaterialModel.fromJson(
          key,
          Map<String, dynamic>.from(value as Map),
        ));
      });

      materials.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
      return materials;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException();
    }
  }

  String _inferMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'zip':
        return 'application/zip';
      case 'txt':
        return 'text/plain';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }
}
