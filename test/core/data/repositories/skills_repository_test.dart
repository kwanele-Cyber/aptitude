import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/core/data/repositories/skills_repository.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class MockDatabaseService extends Mock implements DatabaseService<DataSnapshot> {}
class MockDataSnapshot extends Mock implements DataSnapshot {}

void main() {
  late SkillsRepository skillsRepository;
  late MockDatabaseService mockDatabaseService;
  late MockDataSnapshot mockDataSnapshot;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockDataSnapshot = MockDataSnapshot();
    skillsRepository = SkillsRepository(databaseService: mockDatabaseService);
  });

  group('SkillsRepository', () {
    test('listAll returns list of skills', () async {
      when(() => mockDataSnapshot.exists).thenReturn(true);
      when(() => mockDataSnapshot.value).thenReturn({
        's1': {'sid': 's1', 'name': 'Flutter', 'description': '', 'category': ''}
      });
      when(() => mockDatabaseService.list(location: any(named: 'location')))
          .thenAnswer((_) async => mockDataSnapshot);

      final result = await skillsRepository.listAll();

      expect(result.length, 1);
      expect(result.first.name, 'Flutter');
    });

    test('resolveSkillId returns existing ID if skill exists', () async {
      when(() => mockDataSnapshot.exists).thenReturn(true);
      when(() => mockDataSnapshot.value).thenReturn({
        's1': {'sid': 's1', 'name': 'Flutter', 'description': '', 'category': ''}
      });
      when(() => mockDatabaseService.list(location: any(named: 'location')))
          .thenAnswer((_) async => mockDataSnapshot);

      final id = await skillsRepository.resolveSkillId('Flutter');

      expect(id, 's1');
      verifyNever(() => mockDatabaseService.create(
            location: any(named: 'location'),
            data: any(named: 'data'),
          ));
    });

    test('resolveSkillId creates new skill if not exists', () async {
      when(() => mockDataSnapshot.exists).thenReturn(true);
      when(() => mockDataSnapshot.value).thenReturn({});
      when(() => mockDatabaseService.list(location: any(named: 'location')))
          .thenAnswer((_) async => mockDataSnapshot);
      when(() => mockDatabaseService.create(
            location: any(named: 'location'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => {});

      final id = await skillsRepository.resolveSkillId('Dart');

      expect(id, isNotEmpty);
      verify(() => mockDatabaseService.create(
            location: any(named: 'location'),
            data: any(named: 'data'),
          )).called(1);
    });
   group('SkillsRepository Integration-like', () {
    test('resolveSkillIds batches correctly', () async {
       when(() => mockDataSnapshot.exists).thenReturn(true);
      when(() => mockDataSnapshot.value).thenReturn({
        's1': {'sid': 's1', 'name': 'Flutter', 'description': '', 'category': ''}
      });
       when(() => mockDatabaseService.list(location: any(named: 'location')))
          .thenAnswer((_) async => mockDataSnapshot);
      when(() => mockDatabaseService.create(
            location: any(named: 'location'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => {});

      final ids = await skillsRepository.resolveSkillIds(['Flutter', 'Dart']);

      expect(ids.length, 2);
      expect(ids[0], 's1');
      expect(ids[1], isNot('s1'));
    });
  });
  });
}
