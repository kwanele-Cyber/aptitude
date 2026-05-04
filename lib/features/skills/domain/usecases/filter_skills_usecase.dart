import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class FilterSkillsUseCase {
  final SkillRepository repository;

  FilterSkillsUseCase({required this.repository});

  Future<Either<Failure, List<SkillEntity>>> call(
      FilterSkillsParams params) async {
    final result = await repository.fetchAllSkills();
    return result.fold(
      (failure) => Left(failure),
      (skills) {
        var filtered = skills;

        if (params.category != null) {
          filtered = filtered
              .where((s) =>
                  s.category.toLowerCase() == params.category!.toLowerCase())
              .toList();
        }

        if (params.level != null) {
          filtered = filtered
              .where((s) => s.level == params.level)
              .toList();
        }

        if (params.format != null) {
          filtered = filtered
              .where((s) => s.format == params.format)
              .toList();
        }

        if (params.type != null) {
          filtered = filtered
              .where((s) => s.type == params.type)
              .toList();
        }

        return Right(filtered);
      },
    );
  }
}

class FilterSkillsParams extends Equatable {
  final String? category;
  final SkillLevel? level;
  final SkillFormat? format;
  final SkillType? type;

  const FilterSkillsParams({
    this.category,
    this.level,
    this.format,
    this.type,
  });

  @override
  List<Object?> get props => [category, level, format, type];
}
