import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/data/datasources/skill_remote_datasource.dart';
import 'package:myapp/features/skills/data/models/saved_search_model.dart';
import 'package:myapp/features/skills/data/models/skill_model.dart';
import 'package:myapp/features/skills/data/repository/skill_repository_impl.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/admin/domain/repository/admin_repository.dart';
import 'package:dartz/dartz.dart';

class MockSkillRemoteDataSource extends Mock
    implements SkillRemoteDataSource {}

class MockAdminRepository extends Mock implements AdminRepository {}

final tSkillModel = SkillModel(
  id: 'skill1',
  title: 'Flutter',
  description: 'Test',
  category: 'Tech',
  level: SkillLevel.beginner,
  format: SkillFormat.online,
  userId: 'user1',
);

void main() {
  late SkillRepositoryImpl repository;
  late MockSkillRemoteDataSource mockRemote;
  late MockAdminRepository mockAdmin;

  setUp(() {
    mockRemote = MockSkillRemoteDataSource();
    mockAdmin = MockAdminRepository();

    // Stub logAudit to return success by default
    when(() => mockAdmin.logAudit(
      any(),
      detail: any(named: 'detail'),
      severity: any(named: 'severity'),
      actorRole: any(named: 'actorRole'),
      actorId: any(named: 'actorId'),
    )).thenAnswer((_) async => const Right(null));

    repository = SkillRepositoryImpl(
      remoteDataSource: mockRemote,
      adminRepository: mockAdmin,
    );
  });

  group('createSkill', () {
    final data = {
      'title': 'Flutter',
      'description': 'Test',
      'category': 'Tech',
      'level': 'beginner',
      'format': 'online',
    };

    test('should create skill on success', () async {
      when(() => mockRemote.createSkill(any()))
          .thenAnswer((_) async => tSkillModel);

      final result = await repository.createSkill(data);

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tSkillModel), isA<SkillEntity>());
      verify(() => mockRemote.createSkill(data)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.createSkill(any()))
          .thenThrow(ServerException());

      final result = await repository.createSkill(data);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.createSkill(any())).thenThrow(Exception());

      final result = await repository.createSkill(data);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('updateSkill', () {
    const updateData = {
      'title': 'Flutter Updated',
      'description': 'Updated desc',
      'category': 'Tech',
      'level': 'intermediate',
      'format': 'both',
    };

    test('should update skill on success', () async {
      when(() => mockRemote.updateSkill(any(), any()))
          .thenAnswer((_) async => tSkillModel);

      final result = await repository.updateSkill('skill1', updateData);

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tSkillModel), isA<SkillEntity>());
      verify(() => mockRemote.updateSkill('skill1', updateData)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.updateSkill(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.updateSkill('skill1', updateData);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.updateSkill(any(), any())).thenThrow(Exception());

      final result = await repository.updateSkill('skill1', updateData);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('deleteSkill', () {
    test('should delete skill on success', () async {
      when(() => mockRemote.deleteSkill(any()))
          .thenAnswer((_) async {});

      final result = await repository.deleteSkill('skill1');

      expect(result.isRight(), true);
      verify(() => mockRemote.deleteSkill('skill1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.deleteSkill(any()))
          .thenThrow(ServerException());

      final result = await repository.deleteSkill('skill1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.deleteSkill(any())).thenThrow(Exception());

      final result = await repository.deleteSkill('skill1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('fetchUserSkills', () {
    final skillsList = [tSkillModel];

    test('should fetch user skills on success', () async {
      when(() => mockRemote.fetchUserSkills(any()))
          .thenAnswer((_) async => skillsList);

      final result = await repository.fetchUserSkills('user1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<SkillEntity>>());
      verify(() => mockRemote.fetchUserSkills('user1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.fetchUserSkills(any()))
          .thenThrow(ServerException());

      final result = await repository.fetchUserSkills('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.fetchUserSkills(any())).thenThrow(Exception());

      final result = await repository.fetchUserSkills('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('getSkillById', () {
    test('should get skill by id on success', () async {
      when(() => mockRemote.getSkillById(any()))
          .thenAnswer((_) async => tSkillModel);

      final result = await repository.getSkillById('skill1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tSkillModel), isA<SkillEntity>());
      verify(() => mockRemote.getSkillById('skill1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.getSkillById(any()))
          .thenThrow(ServerException());

      final result = await repository.getSkillById('skill1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.getSkillById(any())).thenThrow(Exception());

      final result = await repository.getSkillById('skill1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('archiveSkill', () {
    test('should archive skill on success', () async {
      when(() => mockRemote.archiveSkill(any()))
          .thenAnswer((_) async {});

      final result = await repository.archiveSkill('skill1');

      expect(result.isRight(), true);
      verify(() => mockRemote.archiveSkill('skill1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.archiveSkill(any()))
          .thenThrow(ServerException());

      final result = await repository.archiveSkill('skill1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('restoreSkill', () {
    test('should restore skill on success', () async {
      when(() => mockRemote.restoreSkill(any()))
          .thenAnswer((_) async {});

      final result = await repository.restoreSkill('skill1');

      expect(result.isRight(), true);
      verify(() => mockRemote.restoreSkill('skill1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.restoreSkill(any()))
          .thenThrow(ServerException());

      final result = await repository.restoreSkill('skill1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('searchSkills', () {
    final skillsList = [tSkillModel];

    test('should search skills on success', () async {
      when(() => mockRemote.searchSkills(any()))
          .thenAnswer((_) async => skillsList);

      final result = await repository.searchSkills('flutter');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<SkillEntity>>());
      verify(() => mockRemote.searchSkills('flutter')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.searchSkills(any()))
          .thenThrow(ServerException());

      final result = await repository.searchSkills('flutter');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.searchSkills(any())).thenThrow(Exception());

      final result = await repository.searchSkills('flutter');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('fetchAllSkills', () {
    final skillsList = [tSkillModel];

    test('should fetch all skills on success', () async {
      when(() => mockRemote.fetchAllSkills())
          .thenAnswer((_) async => skillsList);

      final result = await repository.fetchAllSkills();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<SkillEntity>>());
      verify(() => mockRemote.fetchAllSkills()).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.fetchAllSkills())
          .thenThrow(ServerException());

      final result = await repository.fetchAllSkills();

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.fetchAllSkills()).thenThrow(Exception());

      final result = await repository.fetchAllSkills();

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('saveSearch', () {
    final data = {
      'userId': 'user1',
      'query': 'flutter',
    };

    test('should save search on success', () async {
      when(() => mockRemote.saveSearch(any()))
          .thenAnswer((_) async {});

      final result = await repository.saveSearch(data);

      expect(result.isRight(), true);
      verify(() => mockRemote.saveSearch(data)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.saveSearch(any()))
          .thenThrow(ServerException());

      final result = await repository.saveSearch(data);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.saveSearch(any())).thenThrow(Exception());

      final result = await repository.saveSearch(data);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('fetchSavedSearches', () {
    final tSearches = <SavedSearchModel>[];

    test('should fetch saved searches on success', () async {
      when(() => mockRemote.fetchSavedSearches(any()))
          .thenAnswer((_) async => tSearches);

      final result = await repository.fetchSavedSearches('user1');

      expect(result.isRight(), true);
      verify(() => mockRemote.fetchSavedSearches('user1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.fetchSavedSearches(any()))
          .thenThrow(ServerException());

      final result = await repository.fetchSavedSearches('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.fetchSavedSearches(any()))
          .thenThrow(Exception());

      final result = await repository.fetchSavedSearches('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('deleteSavedSearch', () {
    test('should delete saved search on success', () async {
      when(() => mockRemote.deleteSavedSearch(any()))
          .thenAnswer((_) async {});

      final result = await repository.deleteSavedSearch('search1');

      expect(result.isRight(), true);
      verify(() => mockRemote.deleteSavedSearch('search1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.deleteSavedSearch(any()))
          .thenThrow(ServerException());

      final result = await repository.deleteSavedSearch('search1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.deleteSavedSearch(any()))
          .thenThrow(Exception());

      final result = await repository.deleteSavedSearch('search1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });
}
