import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/repository/auth_repository.dart';

class GenerateRecoveryCodesUseCase implements UseCase<List<String>, NoParams> {
  final AuthRepository repository;

  GenerateRecoveryCodesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return repository.generateRecoveryCodes();
  }
}
