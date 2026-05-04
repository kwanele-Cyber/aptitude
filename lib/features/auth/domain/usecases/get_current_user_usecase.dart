import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/entity/user_entity.dart';
import 'package:myapp/features/auth/domain/repository/auth_repository.dart';

class GetCurrentUserUsecase implements UseCase<UserEntity?,NoParams>{
  final AuthRepository repository;

  GetCurrentUserUsecase({required this.repository});

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async{
    return await repository.getCurrentUser();
  }
}