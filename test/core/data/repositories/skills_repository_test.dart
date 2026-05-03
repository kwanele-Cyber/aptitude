import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/data/repositories/skills_repository.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import 'package:firebase_database/firebase_database.dart';

class ManualMockDb implements DatabaseService<DataSnapshot> {
  Map<String, dynamic> data = {};
  int readCalls = 0;
  int createCalls = 0;

  @override
  Future<void> create({required String location, required Map<String, dynamic> data}) async {
    this.data[location] = data;
    createCalls++;
  }

  @override
  Future<DataSnapshot?> read({required String location}) async {
    readCalls++;
    if (data.containsKey(location)) {
      return ManualSnapshot(data[location]);
    }
    return null;
  }

  @override
  Future<void> delete({required String location}) async => data.remove(location);

  @override
  Future<DataSnapshot?> list({required String location}) async => null;

  @override
  Future<void> update({required String location, required Map<String, dynamic> data}) async {
    this.data[location] = data;
  }
}

class ManualSnapshot implements DataSnapshot {
  @override
  final dynamic value;
  ManualSnapshot(this.value);
  
  @override bool get exists => value != null;
  @override String? get key => 'key';
  int get childrenCount => 0;
  @override bool hasChild(String path) => false;
  @override DataSnapshot child(String path) => ManualSnapshot(null);
  @override Iterable<DataSnapshot> get children => [];
  @override DatabaseReference get ref => throw UnimplementedError();
  @override Object? get priority => null;
}

void main() {
  late SkillsRepository repository;
  late ManualMockDb mockDb;

  setUp(() {
    mockDb = ManualMockDb();
    repository = SkillsRepository(databaseService: mockDb);
  });

  group('SkillsRepository Slug & Logic Tests', () {
    test('resolveSkillId should generate correct slug and save it', () async {
      final sid = await repository.resolveSkillId('Flutter Development');
      
      expect(sid, 'flutter-development');
      expect(mockDb.createCalls, 1);
      expect(mockDb.data.containsKey('skills/flutter-development'), true);
    });

    test('resolveSkillId should handle existing skills via O(1) slug lookup', () async {
      // Pre-populate DB
      mockDb.data['skills/python'] = {'sid': 'python', 'name': 'Python'};
      
      final sid = await repository.resolveSkillId('Python');
      
      expect(sid, 'python');
      expect(mockDb.createCalls, 0); // Should NOT create a new one
      expect(mockDb.readCalls, 1); // Should have checked the specific slug location
    });

    test('resolveSkillId should sanitize name to protect composite IDs', () async {
      // We reserved '--' as a separator for composite IDs
      final sid = await repository.resolveSkillId('Special--Skill');
      
      expect(sid, isNot(contains('--')));
      expect(sid, contains('-'));
    });
  });
}
