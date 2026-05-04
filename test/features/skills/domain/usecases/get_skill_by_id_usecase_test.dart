import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/get_skill_by_id_usecase.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

void main() {
  late MockSkillRepository mockRepository;
  late GetSkillByIdUseCase useCase;

  setUp(() {
    mockRepository = MockSkillRepository();
    useCase = GetSkillByIdUseCase(repository: mockRepository);
  });

  group('GetSkillByIdUseCase', () {
    const params = GetSkillByIdParams(id: 'skill1');
    final tSkill = SkillEntity(
      id: 'skill1',
      title: 'Flutter',
      description: 'Test',
      category: 'Tech',
      level: SkillLevel.beginner,
      format: SkillFormat.online,
      userId: 'user1',
    );

    test('should call repository.getSkillById with correct id', () async {
      when(() => mockRepository.getSkillById(any()))
          .thenAnswer((_) async => Right(tSkill));

      final result = await useCase(params);

      verify(() => mockRepository.getSkillById('skill1')).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getSkillById(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
