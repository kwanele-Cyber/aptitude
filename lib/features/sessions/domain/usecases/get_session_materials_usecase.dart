import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_material_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_material_repository.dart';

class GetSessionMaterialsUseCase
    implements UseCase<List<SessionMaterialEntity>, GetSessionMaterialsParams> {
  final SessionMaterialRepository repository;

  GetSessionMaterialsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<SessionMaterialEntity>>> call(
      GetSessionMaterialsParams params) async {
    return repository.getSessionMaterials(params.sessionId);
  }
}

class GetSessionMaterialsParams {
  final String sessionId;

  GetSessionMaterialsParams({required this.sessionId});
}
