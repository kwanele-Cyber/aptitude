import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/delete_saved_search_usecase.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

void main() {
  late MockSkillRepository mockRepository;
  late DeleteSavedSearchUseCase useCase;

  setUp(() {
    mockRepository = MockSkillRepository();
    useCase = DeleteSavedSearchUseCase(repository: mockRepository);
  });

  group('DeleteSavedSearchUseCase', () {
    const params = DeleteSavedSearchParams(id: 'search1');

    test('should call repository.deleteSavedSearch with correct id', () async {
      when(() => mockRepository.deleteSavedSearch(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      verify(() => mockRepository.deleteSavedSearch('search1')).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.deleteSavedSearch(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
