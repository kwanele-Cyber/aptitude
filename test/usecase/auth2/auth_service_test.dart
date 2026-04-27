import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/usecase/auth2/auth_service.dart';
import 'package:myapp/core/data/models/user.dart';

class MockFirebaseAuth extends Mock implements auth.FirebaseAuth {}
class MockUserRepository extends Mock implements UserRepository {}
class MockUserCredential extends Mock implements auth.UserCredential {}
class MockFirebaseUser extends Mock implements auth.User {}

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockAuth;
  late MockUserRepository mockUserRepo;
  late MockUserCredential mockUserCredential;
  late MockFirebaseUser mockFirebaseUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserRepo = MockUserRepository();
    mockUserCredential = MockUserCredential();
    mockFirebaseUser = MockFirebaseUser();
    authService = AuthService(authService: mockAuth, userRepo: mockUserRepo);
    
    // Register fallback for user object if needed
    registerFallbackValue(User(
      uid: '', email: '', firstName: '', lastName: '', title: '', 
      photoURL: '', skills: [], interests: [], bio: '', 
      location: (User.fromJson({})).location // just to get a default
    ));
  });

  group('AuthService', () {
    test('register creates firebase user and then database user', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: 'test@test.com',
            password: 'password123',
          )).thenAnswer((_) async => mockUserCredential);
      
      when(() => mockUserCredential.user).thenReturn(mockFirebaseUser);
      when(() => mockFirebaseUser.uid).thenReturn('uid_123');
      when(() => mockUserRepo.create(any())).thenAnswer((_) async => {});

      final result = await authService.register(
        firstName: 'John',
        lastName: 'Doe',
        email: 'test@test.com',
        password: 'password123',
      );

      expect(result, isNotNull);
      expect(result?.uid, 'uid_123');
      expect(result?.firstName, 'John');
      verify(() => mockUserRepo.create(any())).called(1);
    });

    test('login calls firebase sign in', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: 'test@test.com',
            password: 'password123',
          )).thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockFirebaseUser);

      final result = await authService.login('test@test.com', 'password123');

      expect(result, equals(mockFirebaseUser));
      verify(() => mockAuth.signInWithEmailAndPassword(
            email: 'test@test.com',
            password: 'password123',
          )).called(1);
    });

    test('logout calls firebase sign out', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async => {});

      await authService.logout();

      verify(() => mockAuth.signOut()).called(1);
    });
  });
}
