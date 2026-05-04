import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class DeleteSavedSearchUseCase {
  final SkillRepository repository;

  DeleteSavedSearchUseCase({required this.repository});

  Future<Either<Failure, void>> call(DeleteSavedSearchParams params) async {
    return repository.deleteSavedSearch(params.id);
  }
}

class DeleteSavedSearchParams extends Equatable {
  final String id;

  const DeleteSavedSearchParams({required this.id});

  @override
  List<Object?> get props => [id];
}
