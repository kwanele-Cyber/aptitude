import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/repositories/auth_repository.dart';
import 'package:myapp/usecase/auth/auth_viewmodel.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/exceptions/custom_exception.dart';
import 'package:myapp/core/services/location_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockLocationService extends Mock implements LocationService {}

void main() {
  late AuthViewModel viewModel;
  late MockAuthRepository mockAuthRepo;
  late MockLocationService mockLocationService;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockLocationService = MockLocationService();
    // Stub location for all tests (M04 requirement)
    when(() => mockLocationService.getCurrentLocation()).thenAnswer((_) async => null);
    viewModel = AuthViewModel(mockAuthRepo, mockLocationService);
  });

  group('AuthViewModel - Registration', () {
    final tUser = UserModel(
      uid: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      offeredSkills: [],
      desiredSkills: [],
      bio: 'Test Bio',
      availability: {},
      trustScore: 0.0,
      createdAt: DateTime.now(),
    );

    test('should update user and loading state on success', () async {
      // Arrange
      when(() => mockAuthRepo.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => tUser);

      // Act
      final result = await viewModel.register(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      );

      // Assert
      expect(result, true);
      expect(viewModel.user, tUser);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
    });

    test('should set error state on AuthException', () async {
      // Arrange
      when(() => mockAuthRepo.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenThrow(AuthException('Invalid email', 'invalid-email'));

      // Act
      final result = await viewModel.register(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      );

      // Assert
      expect(result, false);
      expect(viewModel.error, 'Invalid email');
      expect(viewModel.isLoading, false);
    });

    test('should return false for invalid email format', () async {
      // Act
      final result = await viewModel.register(
        email: 'invalid-email',
        password: 'password123',
        displayName: 'Test User',
      );

      // Assert
      expect(result, false);
      expect(viewModel.error, 'Please enter a valid email address.');
    });

    test('should return false for short password', () async {
      // Act
      final result = await viewModel.register(
        email: 'test@example.com',
        password: '123',
        displayName: 'Test User',
      );

      // Assert
      expect(result, false);
      expect(viewModel.error, 'Password must be at least 6 characters long.');
    });
  });

  group('AuthViewModel - Logout', () {
    test('should call signOut and clear state on success', () async {
      // Arrange
      when(() => mockAuthRepo.signOut()).thenAnswer((_) async {});

      // Act
      await viewModel.logout();

      // Assert
      verify(() => mockAuthRepo.signOut()).called(1);
      expect(viewModel.user, null);
      expect(viewModel.offeredSkills, isEmpty);
      expect(viewModel.desiredSkills, isEmpty);
    });

    test('should set error state on logout failure', () async {
      // Arrange
      when(() => mockAuthRepo.signOut()).thenThrow(AuthException('Logout failed', 'logout-failed'));

      // Act
      await viewModel.logout();

      // Assert
      expect(viewModel.error, 'Logout failed');
    });
  });
}
