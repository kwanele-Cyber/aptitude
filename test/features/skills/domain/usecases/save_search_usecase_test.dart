import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/save_search_usecase.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

void main() {
  late MockSkillRepository mockRepository;
  late SaveSearchUseCase useCase;

  setUp(() {
    mockRepository = MockSkillRepository();
    useCase = SaveSearchUseCase(repository: mockRepository);
  });

  group('SaveSearchUseCase', () {
    const params = SaveSearchParams(userId: 'user1', query: 'flutter');

    test('should call repository.saveSearch with correct params', () async {
      when(() => mockRepository.saveSearch(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      verify(() => mockRepository.saveSearch(any())).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.saveSearch(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
