import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/update_skill_usecase.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

final tSkill = SkillEntity(
  id: 'skill1',
  title: 'Flutter Updated',
  description: 'Updated desc',
  category: 'Tech',
  level: SkillLevel.intermediate,
  format: SkillFormat.both,
  userId: 'user1',
);

void main() {
  late MockSkillRepository mockRepository;
  late UpdateSkillUseCase useCase;

  setUp(() {
    mockRepository = MockSkillRepository();
    useCase = UpdateSkillUseCase(repository: mockRepository);
  });

  group('UpdateSkillUseCase', () {
    const params = UpdateSkillParams(
      id: 'skill1',
      title: 'Flutter Updated',
      description: 'Updated desc',
      category: 'Tech',
      level: SkillLevel.intermediate,
      format: SkillFormat.both,
      tags: ['mobile', 'updated'],
    );

    test('should call repository.updateSkill with correct data', () async {
      when(() => mockRepository.updateSkill(any(), any()))
          .thenAnswer((_) async => Right(tSkill));

      final result = await useCase(params);

      verify(() => mockRepository.updateSkill('skill1', {
        'title': 'Flutter Updated',
        'description': 'Updated desc',
        'category': 'Tech',
        'type': 'offer',
        'level': 'intermediate',
        'format': 'both',
        'tags': ['mobile', 'updated'],
      })).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.updateSkill(any(), any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
