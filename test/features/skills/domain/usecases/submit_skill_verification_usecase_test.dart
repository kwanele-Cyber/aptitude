import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/submit_skill_verification_usecase.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

void main() {
  late MockSkillRepository mockRepository;
  late SubmitSkillVerificationUseCase useCase;

  setUp(() {
    mockRepository = MockSkillRepository();
    useCase = SubmitSkillVerificationUseCase(repository: mockRepository);
  });

  group('SubmitSkillVerificationUseCase', () {
    const params = SubmitSkillVerificationParams(
      skillId: 'skill1',
      portfolioUrls: ['https://example.com/portfolio'],
    );
    final tSkill = SkillEntity(
      id: 'skill1',
      title: 'Flutter',
      description: 'Test',
      category: 'Tech',
      level: SkillLevel.beginner,
      format: SkillFormat.online,
      userId: 'user1',
      isVerified: true,
    );

    test('should call repository.updateSkill with verification data', () async {
      when(() => mockRepository.updateSkill(any(), any()))
          .thenAnswer((_) async => Right(tSkill));

      final result = await useCase(params);

      verify(
        () => mockRepository.updateSkill('skill1', {
          'isVerified': true,
          'portfolioUrls': ['https://example.com/portfolio'],
        }),
      ).called(1);
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
