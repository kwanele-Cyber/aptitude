import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/delete_skill_usecase.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

void main() {
  late MockSkillRepository mockRepository;
  late DeleteSkillUseCase useCase;

  setUp(() {
    mockRepository = MockSkillRepository();
    useCase = DeleteSkillUseCase(repository: mockRepository);
  });

  group('DeleteSkillUseCase', () {
    const params = DeleteSkillParams(id: 'skill1');

    test('should call repository.deleteSkill with correct id', () async {
      when(() => mockRepository.deleteSkill(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      verify(() => mockRepository.deleteSkill('skill1')).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.deleteSkill(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
