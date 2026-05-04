import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/entity/user_entity.dart';
import 'package:myapp/features/auth/domain/repository/auth_repository.dart';

class GetUserProfileUseCase implements UseCase<UserEntity, GetUserProfileParams> {
  final AuthRepository repository;

  GetUserProfileUseCase({required this.repository});

  @override
  Future<Either<Failure, UserEntity>> call(GetUserProfileParams params) async {
    return repository.getUserProfile(params.uid);
  }
}

class GetUserProfileParams {
  final String uid;

  GetUserProfileParams({required this.uid});
}
