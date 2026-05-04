import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/repository/auth_repository.dart';

class ResendVerificationEmailUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  ResendVerificationEmailUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return repository.resendVerificationEmail();
  }
}
