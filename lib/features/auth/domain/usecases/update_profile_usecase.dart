import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/entity/user_entity.dart';
import 'package:myapp/features/auth/domain/repository/auth_repository.dart';

class UpdateProfileUsecase implements UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUsecase({required this.repository});

  @override
  Future<Either<Failure, UserEntity>> call(params) async {
    return repository.updateProfile(params.data);
  }
}

class UpdateProfileParams {
  final Map<String, dynamic> data;

  UpdateProfileParams({required this.data});
}
