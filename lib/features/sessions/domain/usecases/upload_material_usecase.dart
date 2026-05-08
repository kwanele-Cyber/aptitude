import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_material_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_material_repository.dart';

class UploadMaterialUseCase
    implements UseCase<SessionMaterialEntity, UploadMaterialParams> {
  final SessionMaterialRepository repository;

  UploadMaterialUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionMaterialEntity>> call(
      UploadMaterialParams params) async {
    return repository.uploadMaterial(
      sessionId: params.sessionId,
      file: params.file,
      uploadedBy: params.uploadedBy,
    );
  }
}

class UploadMaterialParams {
  final String sessionId;
  final File file;
  final String uploadedBy;

  UploadMaterialParams({
    required this.sessionId,
    required this.file,
    required this.uploadedBy,
  });
}
