import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/restore_skill_usecase.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

void main() {
  late MockSkillRepository mockRepository;
  late RestoreSkillUseCase useCase;

  setUp(() {
    mockRepository = MockSkillRepository();
    useCase = RestoreSkillUseCase(repository: mockRepository);
  });

  group('RestoreSkillUseCase', () {
    const params = RestoreSkillParams(id: 'skill1');

    test('should call repository.restoreSkill with correct id', () async {
      when(() => mockRepository.restoreSkill(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      verify(() => mockRepository.restoreSkill('skill1')).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.restoreSkill(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
