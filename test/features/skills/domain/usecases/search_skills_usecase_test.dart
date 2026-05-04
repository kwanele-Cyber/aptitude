import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/search_skills_usecase.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

void main() {
  late MockSkillRepository mockRepository;
  late SearchSkillsUseCase useCase;

  setUp(() {
    mockRepository = MockSkillRepository();
    useCase = SearchSkillsUseCase(repository: mockRepository);
  });

  group('SearchSkillsUseCase', () {
    const params = SearchSkillsParams(query: 'flutter');
    final tSkills = <SkillEntity>[];

    test('should call repository.searchSkills with correct query', () async {
      when(() => mockRepository.searchSkills(any()))
          .thenAnswer((_) async => Right(tSkills));

      final result = await useCase(params);

      verify(() => mockRepository.searchSkills('flutter')).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.searchSkills(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
