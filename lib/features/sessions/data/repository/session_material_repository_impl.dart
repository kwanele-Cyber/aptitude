import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/sessions/data/datasources/session_material_remote_datasource.dart';
import 'package:myapp/features/sessions/domain/entity/session_material_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_material_repository.dart';

class SessionMaterialRepositoryImpl implements SessionMaterialRepository {
  final SessionMaterialRemoteDataSource remoteDataSource;

  SessionMaterialRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SessionMaterialEntity>> uploadMaterial({
    required String sessionId,
    required File file,
    required String uploadedBy,
  }) async {
    try {
      final material = await remoteDataSource.uploadMaterial(
        sessionId: sessionId,
        file: file,
        uploadedBy: uploadedBy,
      );
      return Right(material);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteMaterial(
      String materialId, String sessionId) async {
    try {
      await remoteDataSource.deleteMaterial(materialId, sessionId);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SessionMaterialEntity>>> getSessionMaterials(
      String sessionId) async {
    try {
      final materials = await remoteDataSource.getSessionMaterials(sessionId);
      return Right(materials);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
