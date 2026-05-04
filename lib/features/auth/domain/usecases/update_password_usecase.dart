import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/repository/auth_repository.dart';

class UpdatePasswordUseCase implements UseCase<void, UpdatePasswordParams> {
  final AuthRepository repository;

  UpdatePasswordUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(params) async {
    return repository.updatePassword(params.newPassword);
  }
}

class UpdatePasswordParams {
  final String newPassword;

  UpdatePasswordParams({required this.newPassword});
}
