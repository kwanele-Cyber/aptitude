import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/entity/user_entity.dart';
import 'package:myapp/features/auth/domain/repository/auth_repository.dart';
import 'package:myapp/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/register_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/resend_verification_email_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/generate_recovery_codes_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/recover_account_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/verify_2fa_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

final tUser = UserEntity(id: '', firstName: '', lastName: '', email: '');

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('LoginUseCase', () {
    final params = LoginParams(email: 'test@test.com', password: 'password');

    test('should call repository.login with correct params', () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => Right(tUser));

      final useCase = LoginUseCase(repository: mockRepository);
      final result = await useCase(params);

      verify(() => mockRepository.login('test@test.com', 'password')).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final useCase = LoginUseCase(repository: mockRepository);
      final result = await useCase(params);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('RegisterUseCase', () {
    final params = RegisterParams(
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@test.com',
      password: 'password123',
    );

    test('should call repository.register with correct params', () async {
      when(() => mockRepository.register(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(tUser));

      final useCase = RegisterUseCase(repository: mockRepository);
      final result = await useCase(params);

      verify(() => mockRepository.register(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@test.com',
            password: 'password123',
          )).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.register(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Left(ServerFailure()));

      final useCase = RegisterUseCase(repository: mockRepository);
      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });

  group('LogoutUseCase', () {
    test('should call repository.logout', () async {
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Right(null));

      final useCase = LogoutUseCase(repository: mockRepository);
      final result = await useCase(NoParams());

      verify(() => mockRepository.logout()).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.logout())
          .thenAnswer((_) async => Left(ServerFailure()));

      final useCase = LogoutUseCase(repository: mockRepository);
      final result = await useCase(NoParams());

      expect(result.isLeft(), true);
    });
  });

  group('ResetPasswordUseCase', () {
    final params = ResetPasswordParams(email: 'test@test.com');

    test('should call repository.resetPassword with correct email', () async {
      when(() => mockRepository.resetPassword(any()))
          .thenAnswer((_) async => const Right(null));

      final useCase = ResetPasswordUseCase(repository: mockRepository);
      final result = await useCase(params);

      verify(() => mockRepository.resetPassword('test@test.com')).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.resetPassword(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final useCase = ResetPasswordUseCase(repository: mockRepository);
      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });

  group('UpdatePasswordUseCase', () {
    final params = UpdatePasswordParams(newPassword: 'newPass123');

    test('should call repository.updatePassword with correct password',
        () async {
      when(() => mockRepository.updatePassword(any()))
          .thenAnswer((_) async => const Right(null));

      final useCase = UpdatePasswordUseCase(repository: mockRepository);
      final result = await useCase(params);

      verify(() => mockRepository.updatePassword('newPass123')).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.updatePassword(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final useCase = UpdatePasswordUseCase(repository: mockRepository);
      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });

  group('ChangePasswordUseCase', () {
    final params = ChangePasswordParams(
      oldPassword: 'oldPass',
      newPassword: 'newPass',
    );

    test('should call repository.changePassword with correct params', () async {
      when(() => mockRepository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async => const Right(null));

      final useCase = ChangePasswordUseCase(repository: mockRepository);
      final result = await useCase(params);

      verify(() => mockRepository.changePassword(
            oldPassword: 'oldPass',
            newPassword: 'newPass',
          )).called(1);
      expect(result.isRight(), true);
    });
  });

  group('DeleteAccountUseCase', () {
    test('should call repository.deleteAccount', () async {
      when(() => mockRepository.deleteAccount())
          .thenAnswer((_) async => const Right(null));

      final useCase = DeleteAccountUseCase(repository: mockRepository);
      final result = await useCase(NoParams());

      verify(() => mockRepository.deleteAccount()).called(1);
      expect(result.isRight(), true);
    });
  });

  group('ResendVerificationEmailUseCase', () {
    test('should call repository.resendVerificationEmail', () async {
      when(() => mockRepository.resendVerificationEmail())
          .thenAnswer((_) async => const Right(null));

      final useCase =
          ResendVerificationEmailUseCase(repository: mockRepository);
      final result = await useCase(NoParams());

      verify(() => mockRepository.resendVerificationEmail()).called(1);
      expect(result.isRight(), true);
    });
  });

  group('Verify2FAUseCase', () {
    final params = Verify2FAParams(uid: '123', pin: '456789');

    test('should call repository.verify2FAPin with correct params', () async {
      when(() => mockRepository.verify2FAPin(any(), any()))
          .thenAnswer((_) async => const Right(true));

      final useCase = Verify2FAUseCase(repository: mockRepository);
      final result = await useCase(params);

      verify(() => mockRepository.verify2FAPin('123', '456789')).called(1);
      expect(result.isRight(), true);
    });

    test('should return false when pin is invalid', () async {
      when(() => mockRepository.verify2FAPin(any(), any()))
          .thenAnswer((_) async => const Right(false));

      final useCase = Verify2FAUseCase(repository: mockRepository);
      final result = await useCase(params);

      expect(result.getOrElse(() => false), false);
    });
  });

  group('UpdateProfileUsecase', () {
    final params = UpdateProfileParams(data: {'firstName': 'Jane'});

    test('should call repository.updateProfile with correct data', () async {
      when(() => mockRepository.updateProfile(any()))
          .thenAnswer((_) async => Right(tUser));

      final useCase = UpdateProfileUsecase(repository: mockRepository);
      final result = await useCase(params);

      verify(() => mockRepository.updateProfile({'firstName': 'Jane'})).called(1);
      expect(result.isRight(), true);
    });
  });

  group('CheckAuthUsecase', () {
    test('should call repository.isAuthenticated', () async {
      when(() => mockRepository.isAuthenticated())
          .thenAnswer((_) async => const Right(true));

      final useCase = CheckAuthUsecase(repository: mockRepository);
      final result = await useCase(NoParams());

      verify(() => mockRepository.isAuthenticated()).called(1);
      expect(result.isRight(), true);
    });

    test('should return false when not authenticated', () async {
      when(() => mockRepository.isAuthenticated())
          .thenAnswer((_) async => const Right(false));

      final useCase = CheckAuthUsecase(repository: mockRepository);
      final result = await useCase(NoParams());

      expect(result.getOrElse(() => false), false);
    });
  });

  group('GetCurrentUserUsecase', () {
    test('should call repository.getCurrentUser', () async {
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => Right(tUser));

      final useCase = GetCurrentUserUsecase(repository: mockRepository);
      final result = await useCase(NoParams());

      verify(() => mockRepository.getCurrentUser()).called(1);
      expect(result.isRight(), true);
    });

    test('should return null when no user is cached', () async {
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      final useCase = GetCurrentUserUsecase(repository: mockRepository);
      final result = await useCase(NoParams());

      expect(result.getOrElse(() => null), null);
    });
  });

  group('GenerateRecoveryCodesUseCase', () {
    test('should call repository.generateRecoveryCodes', () async {
      when(() => mockRepository.generateRecoveryCodes())
          .thenAnswer((_) async => Right(['code1', 'code2']));

      final useCase = GenerateRecoveryCodesUseCase(repository: mockRepository);
      final result = await useCase(NoParams());

      verify(() => mockRepository.generateRecoveryCodes()).called(1);
      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), hasLength(2));
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.generateRecoveryCodes())
          .thenAnswer((_) async => Left(ServerFailure()));

      final useCase = GenerateRecoveryCodesUseCase(repository: mockRepository);
      final result = await useCase(NoParams());

      expect(result.isLeft(), true);
    });
  });

  group('RecoverAccountUseCase', () {
    final params = RecoverAccountParams(
      email: 'test@test.com',
      recoveryCode: 'CODE123',
    );

    test('should call repository.recoverAccount with correct params', () async {
      when(() => mockRepository.recoverAccount(any(), any()))
          .thenAnswer((_) async => const Right(null));

      final useCase = RecoverAccountUseCase(repository: mockRepository);
      final result = await useCase(params);

      verify(() => mockRepository.recoverAccount('test@test.com', 'CODE123'))
          .called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.recoverAccount(any(), any()))
          .thenAnswer((_) async => Left(InvalidCredentialsFailure()));

      final useCase = RecoverAccountUseCase(repository: mockRepository);
      final result = await useCase(params);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<InvalidCredentialsFailure>());
    });
  });
}
