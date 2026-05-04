import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/repository/auth_repository.dart';

class Verify2FAUseCase implements UseCase<bool, Verify2FAParams> {
  final AuthRepository repository;

  Verify2FAUseCase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(params) async {
    return repository.verify2FAPin(params.uid, params.pin);
  }
}

class Verify2FAParams {
  final String uid;
  final String pin;

  Verify2FAParams({required this.uid, required this.pin});
}
