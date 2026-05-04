import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:myapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:myapp/features/auth/data/models/user_model.dart';
import 'package:myapp/features/auth/data/repository/auth_repository_impl.dart';
import 'package:myapp/features/auth/domain/entity/user_entity.dart';

class MockRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;

  final tUserModel = UserModel(
    id: '1',
    firstName: 'Test',
    lastName: 'User',
    email: 'test@test.com',
  );

  setUpAll(() {
    registerFallbackValue(UserModel(
      id: '',
      firstName: '',
      lastName: '',
      email: '',
    ));
  });

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  group('login', () {
    test('should login and cache token and user on success', () async {
      when(() => mockRemote.login(any(), any()))
          .thenAnswer((_) async => tUserModel);
      when(() => mockLocal.cacheToken(any()))
          .thenAnswer((_) async => {});
      when(() => mockLocal.cacheUser(any()))
          .thenAnswer((_) async => {});

      final result = await repository.login('test@test.com', 'password');

      expect(result.isRight(), true);
      verify(() => mockRemote.login('test@test.com', 'password')).called(1);
      verify(() => mockLocal.cacheToken(any())).called(1);
      verify(() => mockLocal.cacheUser(tUserModel)).called(1);
    });

    test('should return InvalidCredentialsFailure when credentials are wrong',
        () async {
      when(() => mockRemote.login(any(), any()))
          .thenThrow(InvalidCredentialsException());

      final result = await repository.login('wrong@test.com', 'wrong');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null),
          isA<InvalidCredentialsFailure>());
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.login(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.login('test@test.com', 'password');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.login(any(), any())).thenThrow(Exception());

      final result = await repository.login('test@test.com', 'password');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('register', () {
    const firstName = 'John';
    const lastName = 'Doe';
    const email = 'john@test.com';
    const password = 'password123';

    test('should register and cache token and user on success', () async {
      when(() => mockRemote.register(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tUserModel);
      when(() => mockLocal.cacheToken(any()))
          .thenAnswer((_) async => {});
      when(() => mockLocal.cacheUser(any()))
          .thenAnswer((_) async => {});

      final result = await repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      expect(result.isRight(), true);
      verify(() => mockRemote.register(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
          )).called(1);
      verify(() => mockLocal.cacheToken(any())).called(1);
      verify(() => mockLocal.cacheUser(tUserModel)).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(() => mockRemote.register(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(ServerException());

      final result = await repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('logout', () {
    test('should clear token and logout from remote', () async {
      when(() => mockLocal.clearToken()).thenAnswer((_) async => {});
      when(() => mockRemote.logout()).thenAnswer((_) async => {});

      final result = await repository.logout();

      expect(result.isRight(), true);
      verify(() => mockLocal.clearToken()).called(1);
      verify(() => mockRemote.logout()).called(1);
    });

    test('should return ServerFailure on error', () async {
      when(() => mockLocal.clearToken()).thenThrow(Exception());

      final result = await repository.logout();

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('getCurrentUser', () {
    test('should return cached user when available', () async {
      when(() => mockLocal.getCachedUser())
          .thenAnswer((_) async => tUserModel);

      final result = await repository.getCurrentUser();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => null), isA<UserEntity>());
    });

    test('should return null when no cached user', () async {
      when(() => mockLocal.getCachedUser())
          .thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => null), null);
    });

    test('should return CacheFailure when local throws', () async {
      when(() => mockLocal.getCachedUser()).thenThrow(Exception());

      final result = await repository.getCurrentUser();

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<CacheFailure>());
    });
  });

  group('isAuthenticated', () {
    test('should return true when token exists', () async {
      when(() => mockLocal.getCachedToken())
          .thenAnswer((_) async => 'some_token');

      final result = await repository.isAuthenticated();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => false), true);
    });

    test('should return false when token is null', () async {
      when(() => mockLocal.getCachedToken())
          .thenAnswer((_) async => null);

      final result = await repository.isAuthenticated();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => true), false);
    });
  });

  group('resetPassword', () {
    test('should call remote.resetPassword with correct email', () async {
      when(() => mockRemote.resetPassword(any()))
          .thenAnswer((_) async => {});

      final result = await repository.resetPassword('test@test.com');

      expect(result.isRight(), true);
      verify(() => mockRemote.resetPassword('test@test.com')).called(1);
    });

    test('should return ServerFailure on error', () async {
      when(() => mockRemote.resetPassword(any())).thenThrow(ServerException());

      final result = await repository.resetPassword('test@test.com');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('updatePassword', () {
    test('should call remote.updatePassword with new password', () async {
      when(() => mockRemote.updatePassword(any()))
          .thenAnswer((_) async => {});

      final result = await repository.updatePassword('newPass123');

      expect(result.isRight(), true);
      verify(() => mockRemote.updatePassword('newPass123')).called(1);
    });
  });

  group('changePassword', () {
    test('should call remote.updatePassword with new password', () async {
      when(() => mockRemote.updatePassword(any()))
          .thenAnswer((_) async => {});

      final result = await repository.changePassword(
        oldPassword: 'oldPass',
        newPassword: 'newPass',
      );

      expect(result.isRight(), true);
      verify(() => mockRemote.updatePassword('newPass')).called(1);
    });
  });

  group('deleteAccount', () {
    test('should delete remote account and clear local token', () async {
      when(() => mockRemote.deleteAccount()).thenAnswer((_) async => {});
      when(() => mockLocal.clearToken()).thenAnswer((_) async => {});

      final result = await repository.deleteAccount();

      expect(result.isRight(), true);
      verify(() => mockRemote.deleteAccount()).called(1);
      verify(() => mockLocal.clearToken()).called(1);
    });
  });

  group('resendVerificationEmail', () {
    test('should call remote.resendVerificationEmail', () async {
      when(() => mockRemote.resendVerificationEmail())
          .thenAnswer((_) async => {});

      final result = await repository.resendVerificationEmail();

      expect(result.isRight(), true);
      verify(() => mockRemote.resendVerificationEmail()).called(1);
    });
  });

  group('verify2FAPin', () {
    test('should return true when pin is valid', () async {
      when(() => mockRemote.verify2FAPin(any(), any()))
          .thenAnswer((_) async => true);

      final result = await repository.verify2FAPin('uid123', '123456');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => false), true);
    });

    test('should return false when pin is invalid', () async {
      when(() => mockRemote.verify2FAPin(any(), any()))
          .thenAnswer((_) async => false);

      final result = await repository.verify2FAPin('uid123', '000000');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => true), false);
    });
  });

  group('updateProfile', () {
    final data = {'firstName': 'Updated'};
    final tUpdatedModel = UserModel(
      id: '1',
      firstName: 'Updated',
      lastName: 'User',
      email: 'test@test.com',
    );

    test('should update profile and cache user', () async {
      when(() => mockRemote.updateProfile(any()))
          .thenAnswer((_) async => tUpdatedModel);
      when(() => mockLocal.cacheUser(any()))
          .thenAnswer((_) async => {});

      final result = await repository.updateProfile(data);

      expect(result.isRight(), true);
      verify(() => mockRemote.updateProfile(data)).called(1);
      verify(() => mockLocal.cacheUser(tUpdatedModel)).called(1);
    });

    test('should return ServerFailure on error', () async {
      when(() => mockRemote.updateProfile(any())).thenThrow(ServerException());

      final result = await repository.updateProfile(data);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('generateRecoveryCodes', () {
    test('should return recovery codes on success', () async {
      when(() => mockRemote.generateRecoveryCodes())
          .thenAnswer((_) async => ['code1', 'code2']);

      final result = await repository.generateRecoveryCodes();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), hasLength(2));
      verify(() => mockRemote.generateRecoveryCodes()).called(1);
    });

    test('should return ServerFailure on error', () async {
      when(() => mockRemote.generateRecoveryCodes())
          .thenThrow(ServerException());

      final result = await repository.generateRecoveryCodes();

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('recoverAccount', () {
    test('should recover account on success', () async {
      when(() => mockRemote.recoverAccount(any(), any()))
          .thenAnswer((_) async => {});

      final result = await repository.recoverAccount(
        'test@test.com',
        'VALID_CODE',
      );

      expect(result.isRight(), true);
      verify(() => mockRemote.recoverAccount('test@test.com', 'VALID_CODE'))
          .called(1);
    });

    test('should return InvalidCredentialsFailure when code is wrong', () async {
      when(() => mockRemote.recoverAccount(any(), any()))
          .thenThrow(InvalidCredentialsException());

      final result = await repository.recoverAccount(
        'test@test.com',
        'WRONG',
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null),
          isA<InvalidCredentialsFailure>());
    });

    test('should return ServerFailure on error', () async {
      when(() => mockRemote.recoverAccount(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.recoverAccount(
        'test@test.com',
        'CODE',
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });
}
