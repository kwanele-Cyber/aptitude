import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/data/models/saved_search.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/data/repositories/search_repository.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import 'package:firebase_database/firebase_database.dart';

class ManualMockDb implements DatabaseService<DataSnapshot> {
  Map<String, dynamic> data = {};

  @override
  Future<void> create({required String location, required Map<String, dynamic> data}) async {
    this.data[location] = data;
  }

  @override
  Future<DataSnapshot?> read({required String location}) async {
    if (data.containsKey(location)) {
      return ManualSnapshot(data[location]);
    }
    return null;
  }

  @override
  Future<DataSnapshot?> list({required String location}) async {
    // Return a mock snapshot containing all items under the parent location
    final Map<String, dynamic> results = {};
    data.forEach((key, value) {
      if (key.startsWith(location)) {
        final subKey = key.split('/').last;
        results[subKey] = value;
      }
    });
    return ManualSnapshot(results);
  }

  @override
  Future<void> delete({required String location}) async => data.remove(location);
  @override
  Future<void> update({required String location, required Map<String, dynamic> data}) async {}
}

class ManualSnapshot implements DataSnapshot {
  @override final dynamic value;
  ManualSnapshot(this.value);
  @override bool get exists => value != null;
  @override String? get key => 'key';
  @override int get childrenCount => (value as Map?)?.length ?? 0;
  @override bool hasChild(String path) => false;
  @override DataSnapshot child(String path) => ManualSnapshot(null);
  @override Iterable<DataSnapshot> get children {
    if (value is Map) {
      return (value as Map).values.map((v) => ManualSnapshot(v));
    }
    return [];
  }
  @override DatabaseReference get ref => throw UnimplementedError();
  @override Object? get priority => null;
}

void main() {
  late SearchRepository repository;
  late ManualMockDb mockDb;

  setUp(() {
    mockDb = ManualMockDb();
    repository = SearchRepository(databaseService: mockDb);
  });

  group('SearchRepository Persistence Tests', () {
    test('saveSearch should store search under user-isolated path', () async {
      final search = SavedSearch(
        id: 's1',
        name: 'Flutter Expert',
        query: 'Flutter',
        levels: {SkillLevel.expert},
      );

      await repository.saveSearch('user123', search);
      
      final expectedPath = 'saved_searches/user123/s1';
      expect(mockDb.data.containsKey(expectedPath), true);
      expect(mockDb.data[expectedPath]['name'], 'Flutter Expert');
    });

    test('getSavedSearches should retrieve all searches for a user', () async {
      // Pre-populate mock data
      mockDb.data['saved_searches/u1/1'] = {'id': '1', 'name': 'Search 1', 'query': 'q1'};
      mockDb.data['saved_searches/u1/2'] = {'id': '2', 'name': 'Search 2', 'query': 'q2'};

      final results = await repository.getSavedSearches('u1');
      
      expect(results.length, 2);
      expect(results.any((s) => s.name == 'Search 1'), true);
    });

    test('deleteSearch should remove the correct node', () async {
      mockDb.data['saved_searches/u1/1'] = {'id': '1'};
      
      await repository.deleteSearch('u1', '1');
      
      expect(mockDb.data.containsKey('saved_searches/u1/1'), false);
    });
  });
}
