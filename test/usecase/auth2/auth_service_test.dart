import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/core/data/models/user.dart' as model;
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

// Manual Mocks for simplicity
class ManualMockAuth extends Fake implements auth.FirebaseAuth {
  auth.User? mockUser;
  @override
  auth.User? get currentUser => mockUser;
  
  @override
  Future<void> signOut() async {
    mockUser = null;
  }
}

class ManualMockUser extends Fake implements auth.User {
  @override
  String get uid => 'user123';
}

class ManualMockUserRepo extends Fake implements UserRepository {
  Map<String, model.User> users = {};
  
  @override
  Future<model.User?> read(String uid) async {
    return users[uid];
  }
  
  @override
  Future<void> create(model.User user) async {
    users[user.uid] = user;
  }
}

void main() {
  late AuthService authService;
  late ManualMockAuth mockAuth;
  late ManualMockUserRepo mockRepo;

  setUp(() {
    mockAuth = ManualMockAuth();
    mockRepo = ManualMockUserRepo();
    authService = AuthService(firebaseAuth: mockAuth, userRepo: mockRepo);
  });

  group('AuthService Core Logic Tests', () {
    test('getCurrentUser should return null if no firebase user exists', () async {
      mockAuth.mockUser = null;
      final user = await authService.getCurrentUser();
      expect(user, isNull);
    });

    test('getCurrentUser should bridge Firebase UID to Database User model', () async {
      // Setup: Mock user exists in Auth and Repo
      final firebaseUser = ManualMockUser();
      mockAuth.mockUser = firebaseUser;
      
      final dbUser = model.User.fromJson({
        'uid': 'user123',
        'email': 'test@test.com',
        'firstName': 'Test',
      });
      mockRepo.users['user123'] = dbUser;

      final result = await authService.getCurrentUser();
      
      expect(result, isNotNull);
      expect(result!.uid, 'user123');
      expect(result.firstName, 'Test');
    });

    test('logout should clear current session', () async {
      mockAuth.mockUser = ManualMockUser();
      await authService.logout();
      expect(mockAuth.currentUser, isNull);
    });
  });
}
