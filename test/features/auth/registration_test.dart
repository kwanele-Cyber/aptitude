import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/repositories/auth_repository.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/exceptions/custom_exception.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('User Registration (U01)', () {
    final tUser = UserModel(
      uid: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      offeredSkills: [],
      desiredSkills: [],
      availability: {},
      trustScore: 0.0,
      createdAt: DateTime.now(),
    );

    test('should sign up user successfully', () async {
      // Arrange
      when(() => mockAuthRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => tUser);

      // Act
      final result = await mockAuthRepository.signUpWithEmail(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      );

      // Assert
      expect(result, tUser);
      verify(() => mockAuthRepository.signUpWithEmail(
            email: 'test@example.com',
            password: 'password123',
            displayName: 'Test User',
          )).called(1);
    });

    test('should throw AuthException when sign up fails', () async {
      // Arrange
      when(() => mockAuthRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenThrow(AuthException('Email already in use', 'email-already-in-use'));

      // Act & Assert
      expect(
        () => mockAuthRepository.signUpWithEmail(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
