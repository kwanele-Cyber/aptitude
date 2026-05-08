import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/ai/domain/entities/behavior_flag_entity.dart';
import 'package:myapp/features/ai/domain/repository/ai_repository.dart';
import 'package:myapp/features/ai/domain/usecases/analyze_behavior_usecase.dart';

class MockAiRepository extends Mock implements AiRepository {}

final tFlag = BehaviorFlagEntity(
  id: 'flag_1',
  userId: 'user1',
  type: FlagType.unusualLoginLocation,
  severity: FlagSeverity.high,
  description: 'Login from unusual location',
  timestamp: DateTime(2025, 1, 1),
);

void main() {
  late MockAiRepository mockRepository;
  late AnalyzeBehaviorUseCase useCase;

  setUp(() {
    mockRepository = MockAiRepository();
    useCase = AnalyzeBehaviorUseCase(repository: mockRepository);
  });

  group('AnalyzeBehaviorUseCase', () {
    const params = AnalyzeBehaviorParams(userId: 'user1');

    test('should return behavior flags on success', () async {
      when(() => mockRepository.analyzeBehavior(any()))
          .thenAnswer((_) async => Right([tFlag]));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.analyzeBehavior('user1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.analyzeBehavior(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
