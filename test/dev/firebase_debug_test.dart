import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/core/services/base_database_service.dart';
import 'package:firebase_database/firebase_database.dart';

// Standalone service for testing
class TestDatabaseService extends BaseDatabaseService {
  TestDatabaseService({super.pathPrefix = 'dev'});
}

void main() async {
  // Initialize Firebase for integration testing at the very start
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  group('Firebase Integration Debug (Real DB)', () {
    late TestDatabaseService service;

    setUp(() {
      service = TestDatabaseService();
    });

    test('Explicit Test: Write and Read at users/test_user_id', () async {
      const testPath = 'users/test_user_id';
      // Total path will be dev/users/test_user_id
      final testData = {
        'status': 'success', 
        'timestamp': DateTime.now().toIso8601String(),
        'userId': 'debug_user_123'
      };

      print('Starting REAL write to $testPath...');
      await service.setData(path: testPath, data: testData);
      print('Write successful.');

      print('Starting REAL read from $testPath...');
      final snapshot = await service.getData(testPath);
      print('Read successful. Data: ${snapshot.value}');

      expect(snapshot.value != null, true);
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      expect(data['status'], 'success');
    });

    test('Clean-up Test: Delete dev path', () async {
      const testPath = 'users/test_user_id';
      print('Starting REAL delete of $testPath...');
      await service.deleteData(testPath);
      print('Delete successful.');
    });
  });
}
