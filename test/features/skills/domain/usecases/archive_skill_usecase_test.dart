import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/archive_skill_usecase.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

void main() {
  late MockSkillRepository mockRepository;
  late ArchiveSkillUseCase useCase;

  setUp(() {
    mockRepository = MockSkillRepository();
    useCase = ArchiveSkillUseCase(repository: mockRepository);
  });

  group('ArchiveSkillUseCase', () {
    const params = ArchiveSkillParams(id: 'skill1');

    test('should call repository.archiveSkill with correct id', () async {
      when(() => mockRepository.archiveSkill(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      verify(() => mockRepository.archiveSkill('skill1')).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.archiveSkill(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
