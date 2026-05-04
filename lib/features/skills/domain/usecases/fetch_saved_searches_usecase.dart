import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/saved_search_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class FetchSavedSearchesUseCase {
  final SkillRepository repository;

  FetchSavedSearchesUseCase({required this.repository});

  Future<Either<Failure, List<SavedSearchEntity>>> call(
      FetchSavedSearchesParams params) async {
    return repository.fetchSavedSearches(params.uid);
  }
}

class FetchSavedSearchesParams extends Equatable {
  final String uid;

  const FetchSavedSearchesParams({required this.uid});

  @override
  List<Object?> get props => [uid];
}
