import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/saved_search_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/fetch_saved_searches_usecase.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

void main() {
  late MockSkillRepository mockRepository;
  late FetchSavedSearchesUseCase useCase;

  setUp(() {
    mockRepository = MockSkillRepository();
    useCase = FetchSavedSearchesUseCase(repository: mockRepository);
  });

  group('FetchSavedSearchesUseCase', () {
    const params = FetchSavedSearchesParams(uid: 'user1');
    final tSearches = <SavedSearchEntity>[];

    test(
        'should call repository.fetchSavedSearches with correct uid',
        () async {
      when(() => mockRepository.fetchSavedSearches(any()))
          .thenAnswer((_) async => Right(tSearches));

      final result = await useCase(params);

      verify(() => mockRepository.fetchSavedSearches('user1')).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.fetchSavedSearches(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
