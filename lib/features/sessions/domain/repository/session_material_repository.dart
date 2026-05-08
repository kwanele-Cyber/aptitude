import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/domain/entity/session_material_entity.dart';

abstract class SessionMaterialRepository {
  Future<Either<Failure, SessionMaterialEntity>> uploadMaterial({
    required String sessionId,
    required File file,
    required String uploadedBy,
  });
  Future<Either<Failure, void>> deleteMaterial(String materialId, String sessionId);
  Future<Either<Failure, List<SessionMaterialEntity>>> getSessionMaterials(String sessionId);
}
