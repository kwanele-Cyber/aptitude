import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/clone_skill_usecase.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

final tSkill = SkillEntity(
  id: 'skill1',
  title: 'Flutter',
  description: 'Test',
  category: 'Tech',
  level: SkillLevel.beginner,
  format: SkillFormat.online,
  userId: 'user1',
);

void main() {
  late MockSkillRepository mockRepository;
  late CloneSkillUseCase useCase;

  setUp(() {
    mockRepository = MockSkillRepository();
    useCase = CloneSkillUseCase(repository: mockRepository);
  });

  group('CloneSkillUseCase', () {
    const params = CloneSkillParams(skillId: 'skill1');

    test('should fetch skill by id and create a clone', () async {
      when(() => mockRepository.getSkillById(any()))
          .thenAnswer((_) async => Right(tSkill));
      when(() => mockRepository.createSkill(any()))
          .thenAnswer((_) async => Right(tSkill));

      final result = await useCase(params);

      verify(() => mockRepository.getSkillById('skill1')).called(1);
      verify(() => mockRepository.createSkill({
        'title': 'Flutter',
        'description': 'Test',
        'category': 'Tech',
        'type': 'offer',
        'level': 'beginner',
        'format': 'online',
        'tags': <String>[],
      })).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when fetching skill fails', () async {
      when(() => mockRepository.getSkillById(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });

    test('should return Failure when creating clone fails', () async {
      when(() => mockRepository.getSkillById(any()))
          .thenAnswer((_) async => Right(tSkill));
      when(() => mockRepository.createSkill(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
