import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/core/repositories/auth_repository_impl.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/services/base_database_service.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  group('Auth Integration Test (Real Firebase)', () {
    late AuthRepositoryImpl authRepository;
    final String testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
    const String testPassword = 'password123';
    const String testName = 'Debug User';

    setUpAll(() {
      // Use 'dev' prefix to isolate test data
      authRepository = AuthRepositoryImpl(pathPrefix: 'dev');
    });

    test('Full Registration Flow: Auth Creation + DB Entry', () async {
      print('Starting registration for $testEmail...');
      
      UserModel? newUser;
      try {
        newUser = await authRepository.signUpWithEmail(
          email: testEmail,
          password: testPassword,
          displayName: testName,
        );
      } catch (e) {
        print('Registration failed: $e');
        rethrow;
      }

      print('Auth user created with UID: ${newUser.uid}');
      expect(newUser.email, testEmail);
      expect(newUser.displayName, testName);

      print('Verifying database entry at dev/users/${newUser.uid}...');
      // We use the repository itself to fetch, which should also use the 'dev' prefix
      final fetchedUser = await authRepository.getCurrentUser();
      
      expect(fetchedUser, isNotNull);
      expect(fetchedUser!.uid, newUser.uid);
      expect(fetchedUser.email, testEmail);
      print('Database verification successful.');
    });

    tearDownAll(() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email == testEmail) {
        print('Cleaning up: Deleting database entry...');
        // Manually clean up DB entry in dev path
        try {
          // We can use a temporary service to delete the specific dev path
          await authRepository.deleteData('users/${user.uid}');
          print('Database clean-up successful.');
        } catch (e) {
          print('Database clean-up failed: $e');
        }

        print('Cleaning up: Deleting auth user...');
        try {
          await user.delete();
          print('Auth user deleted successfully.');
        } catch (e) {
          print('Auth user deletion failed (requires recent login): $e');
        }
      }
    });
  });
}
