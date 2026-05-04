import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/repository/auth_repository.dart';

class RecoverAccountUseCase
    implements UseCase<void, RecoverAccountParams> {
  final AuthRepository repository;

  RecoverAccountUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(RecoverAccountParams params) async {
    return repository.recoverAccount(params.email, params.recoveryCode);
  }
}

class RecoverAccountParams {
  final String email;
  final String recoveryCode;

  RecoverAccountParams({
    required this.email,
    required this.recoveryCode,
  });
}
