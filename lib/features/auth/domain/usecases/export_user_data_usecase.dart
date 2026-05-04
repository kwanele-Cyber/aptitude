import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/repository/auth_repository.dart';

class ExportUserDataUseCase implements UseCase<String, NoParams> {
  final AuthRepository repository;

  ExportUserDataUseCase({required this.repository});

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return repository.exportUserData();
  }
}
