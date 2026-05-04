import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class SearchSkillsUseCase {
  final SkillRepository repository;

  SearchSkillsUseCase({required this.repository});

  Future<Either<Failure, List<SkillEntity>>> call(
      SearchSkillsParams params) async {
    return repository.searchSkills(params.query);
  }
}

class SearchSkillsParams extends Equatable {
  final String query;

  const SearchSkillsParams({required this.query});

  @override
  List<Object?> get props => [query];
}
