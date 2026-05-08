import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/repository/session_material_repository.dart';

class DeleteMaterialUseCase implements UseCase<void, DeleteMaterialParams> {
  final SessionMaterialRepository repository;

  DeleteMaterialUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteMaterialParams params) async {
    return repository.deleteMaterial(params.materialId, params.sessionId);
  }
}

class DeleteMaterialParams {
  final String materialId;
  final String sessionId;

  DeleteMaterialParams({
    required this.materialId,
    required this.sessionId,
  });
}
