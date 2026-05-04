import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/repository/auth_repository.dart';

class CheckAuthUsecase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  CheckAuthUsecase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return repository.isAuthenticated();
  }
}
