import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/create_skill_offer_usecase.dart';

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
  late CreateSkillOfferUseCase useCase;

  setUp(() {
    mockRepository = MockSkillRepository();
    useCase = CreateSkillOfferUseCase(repository: mockRepository);
  });

  group('CreateSkillOfferUseCase', () {
    final params = CreateSkillOfferParams(
      title: 'Flutter',
      description: 'Test',
      category: 'Tech',
      level: SkillLevel.beginner,
      format: SkillFormat.online,
      tags: ['mobile'],
    );

    test('should call repository.createSkill with correct data', () async {
      when(() => mockRepository.createSkill(any()))
          .thenAnswer((_) async => Right(tSkill));

      final result = await useCase(params);

      verify(() => mockRepository.createSkill({
        'title': 'Flutter',
        'description': 'Test',
        'category': 'Tech',
        'type': 'offer',
        'level': 'beginner',
        'format': 'online',
        'tags': ['mobile'],
      })).called(1);
      expect(result.isRight(), true);
    });

    test('should pass type as request when type is SkillType.request', () async {
      when(() => mockRepository.createSkill(any()))
          .thenAnswer((_) async => Right(tSkill));

      final result = await useCase(CreateSkillOfferParams(
        title: 'Flutter',
        description: 'Test',
        category: 'Tech',
        type: SkillType.request,
        level: SkillLevel.beginner,
        format: SkillFormat.online,
        tags: ['mobile'],
      ));

      verify(() => mockRepository.createSkill({
        'title': 'Flutter',
        'description': 'Test',
        'category': 'Tech',
        'type': 'request',
        'level': 'beginner',
        'format': 'online',
        'tags': ['mobile'],
      })).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.createSkill(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
