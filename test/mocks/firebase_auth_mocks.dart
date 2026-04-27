import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

/// Mocks for Firebase Auth classes to be used in tests.
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockAuthCredential extends Mock implements AuthCredential {}

/// A helper class to provide pre-configured stubs for common Firebase Auth scenarios.
class FirebaseAuthStub {
  final MockFirebaseAuth mockAuth = MockFirebaseAuth();
  final MockUser mockUser = MockUser();
  final MockUserCredential mockUserCredential = MockUserCredential();

  FirebaseAuthStub() {
    // Default behaviors
    when(() => mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));
    when(() => mockAuth.currentUser).thenReturn(null);
    when(() => mockUserCredential.user).thenReturn(mockUser);
  }

  void login(String uid, String email) {
    when(() => mockUser.uid).thenReturn(uid);
    when(() => mockUser.email).thenReturn(email);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));
    
    // Stub for sign in
    when(() => mockAuth.signInWithEmailAndPassword(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => mockUserCredential);
  }

  void logout() {
    when(() => mockAuth.currentUser).thenReturn(null);
    when(() => mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));
    when(() => mockAuth.signOut()).thenAnswer((_) async => {});
  }

  void stubRegistration(String uid, String email) {
    when(() => mockUser.uid).thenReturn(uid);
    when(() => mockUser.email).thenReturn(email);
    when(() => mockAuth.createUserWithEmailAndPassword(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => mockUserCredential);
  }
}
