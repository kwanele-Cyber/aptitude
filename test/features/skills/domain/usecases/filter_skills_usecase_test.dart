import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/filter_skills_usecase.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

void main() {
  late MockSkillRepository mockRepository;
  late FilterSkillsUseCase useCase;

  setUp(() {
    mockRepository = MockSkillRepository();
    useCase = FilterSkillsUseCase(repository: mockRepository);
  });

  group('FilterSkillsUseCase', () {
    final tSkill = SkillEntity(
      id: 'skill1',
      title: 'Flutter',
      description: 'Test',
      category: 'Tech',
      level: SkillLevel.beginner,
      format: SkillFormat.online,
      userId: 'user1',
    );
    final tSkill2 = SkillEntity(
      id: 'skill2',
      title: 'Guitar',
      description: 'Music lessons',
      category: 'Music',
      level: SkillLevel.intermediate,
      format: SkillFormat.inPerson,
      userId: 'user2',
    );

    test('should return all skills when no filters applied', () async {
      when(() => mockRepository.fetchAllSkills())
          .thenAnswer((_) async => Right([tSkill, tSkill2]));

      final result = await useCase(const FilterSkillsParams());

      expect(result.isRight(), true);
      result.fold(
        (l) => null,
        (r) => expect(r.length, 2),
      );
    });

    test('should filter by category', () async {
      when(() => mockRepository.fetchAllSkills())
          .thenAnswer((_) async => Right([tSkill, tSkill2]));

      final result = await useCase(
          const FilterSkillsParams(category: 'Tech'));

      expect(result.isRight(), true);
      result.fold(
        (l) => null,
        (r) {
          expect(r.length, 1);
          expect(r.first.category, 'Tech');
        },
      );
    });

    test('should filter by level', () async {
      when(() => mockRepository.fetchAllSkills())
          .thenAnswer((_) async => Right([tSkill, tSkill2]));

      final result = await useCase(
          const FilterSkillsParams(level: SkillLevel.intermediate));

      expect(result.isRight(), true);
      result.fold(
        (l) => null,
        (r) {
          expect(r.length, 1);
          expect(r.first.level, SkillLevel.intermediate);
        },
      );
    });

    test('should filter by format', () async {
      when(() => mockRepository.fetchAllSkills())
          .thenAnswer((_) async => Right([tSkill, tSkill2]));

      final result = await useCase(
          const FilterSkillsParams(format: SkillFormat.inPerson));

      expect(result.isRight(), true);
      result.fold(
        (l) => null,
        (r) {
          expect(r.length, 1);
          expect(r.first.format, SkillFormat.inPerson);
        },
      );
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.fetchAllSkills())
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(const FilterSkillsParams());

      expect(result.isLeft(), true);
    });
  });
}
