import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/data/models/skill_offer.dart';
import 'package:myapp/core/data/models/skill_request.dart';
import 'package:myapp/core/data/repositories/user_skills_repository.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import 'package:firebase_database/firebase_database.dart';

class ManualMockDb implements DatabaseService<DataSnapshot> {
  Map<String, dynamic> data = {};
  int createCalls = 0;

  @override
  Future<void> create({required String location, required Map<String, dynamic> data}) async {
    this.data[location] = data;
    createCalls++;
  }

  @override
  Future<DataSnapshot?> read({required String location}) async => null;
  @override
  Future<void> delete({required String location}) async => data.remove(location);
  @override
  Future<DataSnapshot?> list({required String location}) async => null;
  @override
  Future<void> update({required String location, required Map<String, dynamic> data}) async {
    this.data[location] = data;
  }
}

void main() {
  late UserSkillsRepository repository;
  late ManualMockDb mockDb;

  setUp(() {
    mockDb = ManualMockDb();
    repository = UserSkillsRepository(databaseService: mockDb);
  });

  group('UserSkillsRepository Composite ID Tests', () {
    test('addOffer should generate a sid--uid composite ID', () async {
      final offer = SkillOffer(
        uid: 'user123',
        sid: 'flutter',
        skillName: 'Flutter',
        level: SkillLevel.expert,
        format: SkillFormat.online,
        description: 'test',
      );

      await repository.addOffer(offer);
      
      final expectedId = 'flutter--user123';
      final expectedPath = 'skill_offers/user123/$expectedId';
      
      expect(mockDb.data.containsKey(expectedPath), true);
      expect(mockDb.data[expectedPath]['id'], expectedId);
    });

    test('addRequest should generate a sid--uid composite ID', () async {
      final request = SkillRequest(
        uid: 'user123',
        sid: 'flutter',
        skillName: 'Flutter',
        targetLevel: SkillLevel.intermediate,
        preferredFormat: SkillFormat.online,
        description: 'test',
      );

      await repository.addRequest(request);
      
      final expectedId = 'flutter--user123';
      final expectedPath = 'skill_requests/user123/$expectedId';
      
      expect(mockDb.data.containsKey(expectedPath), true);
      expect(mockDb.data[expectedPath]['id'], expectedId);
    });
  });
}
