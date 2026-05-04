import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/entity/user_entity.dart';
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
import 'package:myapp/features/auth/domain/usecases/verify_2fa_usecase.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}
class MockCheckAuthUsecase extends Mock implements CheckAuthUsecase {}
class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}
class MockUpdatePasswordUseCase extends Mock implements UpdatePasswordUseCase {}
class MockChangePasswordUseCase extends Mock implements ChangePasswordUseCase {}
class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}
class MockResendVerificationEmailUseCase extends Mock
    implements ResendVerificationEmailUseCase {}
class MockVerify2FAUseCase extends Mock implements Verify2FAUseCase {}
class MockGenerateRecoveryCodesUseCase extends Mock
    implements GenerateRecoveryCodesUseCase {}
class MockRecoverAccountUseCase extends Mock
    implements RecoverAccountUseCase {}

final tUser = UserEntity(id: '', firstName: '', lastName: '', email: '');

void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLogin;
  late MockRegisterUseCase mockRegister;
  late MockLogoutUseCase mockLogout;
  late MockGetCurrentUserUsecase mockGetCurrentUser;
  late MockCheckAuthUsecase mockCheckAuth;
  late MockResetPasswordUseCase mockResetPassword;
  late MockUpdatePasswordUseCase mockUpdatePassword;
  late MockChangePasswordUseCase mockChangePassword;
  late MockDeleteAccountUseCase mockDeleteAccount;
  late MockResendVerificationEmailUseCase mockResendVerificationEmail;
  late MockVerify2FAUseCase mockVerify2FA;
  late MockGenerateRecoveryCodesUseCase mockGenerateRecoveryCodes;
  late MockRecoverAccountUseCase mockRecoverAccount;

  setUpAll(() {
    registerFallbackValue(LoginParams(email: '', password: ''));
    registerFallbackValue(RegisterParams(
      firstName: '', lastName: '', email: '', password: '',
    ));
    registerFallbackValue(ResetPasswordParams(email: ''));
    registerFallbackValue(UpdatePasswordParams(newPassword: ''));
    registerFallbackValue(ChangePasswordParams(
      oldPassword: '', newPassword: '',
    ));
    registerFallbackValue(Verify2FAParams(uid: '', pin: ''));
    registerFallbackValue(NoParams());
    registerFallbackValue(RecoverAccountParams(
      email: '', recoveryCode: '',
    ));
  });

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockRegister = MockRegisterUseCase();
    mockLogout = MockLogoutUseCase();
    mockGetCurrentUser = MockGetCurrentUserUsecase();
    mockCheckAuth = MockCheckAuthUsecase();
    mockResetPassword = MockResetPasswordUseCase();
    mockUpdatePassword = MockUpdatePasswordUseCase();
    mockChangePassword = MockChangePasswordUseCase();
    mockDeleteAccount = MockDeleteAccountUseCase();
    mockResendVerificationEmail = MockResendVerificationEmailUseCase();
    mockVerify2FA = MockVerify2FAUseCase();
    mockGenerateRecoveryCodes = MockGenerateRecoveryCodesUseCase();
    mockRecoverAccount = MockRecoverAccountUseCase();

    bloc = AuthBloc(
      loginUseCase: mockLogin,
      registerUseCase: mockRegister,
      logoutUseCase: mockLogout,
      getCurrentUserUsecase: mockGetCurrentUser,
      checkAuthUsecase: mockCheckAuth,
      resetPasswordUseCase: mockResetPassword,
      updatePasswordUseCase: mockUpdatePassword,
      changePasswordUseCase: mockChangePassword,
      deleteAccountUseCase: mockDeleteAccount,
      resendVerificationEmailUseCase: mockResendVerificationEmail,
      verify2FAUseCase: mockVerify2FA,
      generateRecoveryCodesUseCase: mockGenerateRecoveryCodes,
      recoverAccountUseCase: mockRecoverAccount,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when not authenticated',
      build: () {
        when(() => mockCheckAuth(any()))
            .thenAnswer((_) async => const Right(false));
        return bloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when authenticated with user',
      build: () {
        when(() => mockCheckAuth(any()))
            .thenAnswer((_) async => const Right(true));
        when(() => mockGetCurrentUser(any()))
            .thenAnswer((_) async => Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [AuthLoading(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when check auth fails',
      build: () {
        when(() => mockCheckAuth(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
    );
  });

  group('AuthLoginRequested', () {
    final event = AuthLoginRequested(
      email: 'test@test.com',
      password: 'password',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        when(() => mockLogin(any()))
            .thenAnswer((_) async => Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [AuthLoading(), AuthAuthenticated(userEntity: tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on invalid credentials',
      build: () {
        when(() => mockLogin(any()))
            .thenAnswer((_) async => Left(InvalidCredentialsFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Invalid email or password'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on server failure',
      build: () {
        when(() => mockLogin(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Server error, please try again later'),
      ],
    );
  });

  group('AuthRegisterRequested', () {
    final event = AuthRegisterRequested(
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@test.com',
      password: 'password123',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        when(() => mockRegister(any()))
            .thenAnswer((_) async => Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [AuthLoading(), AuthAuthenticated(userEntity: tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on server failure',
      build: () {
        when(() => mockRegister(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Server error, please try again later'),
      ],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on success',
      build: () {
        when(() => mockLogout(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockLogout(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Logout Error'),
      ],
    );
  });

  group('AuthResetPasswordRequested', () {
    final event = AuthResetPasswordRequested(email: 'test@test.com');

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPasswordResetEmailSent] on success',
      build: () {
        when(() => mockResetPassword(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [AuthLoading(), AuthPasswordResetEmailSent()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockResetPassword(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Failed to send reset email'),
      ],
    );
  });

  group('AuthUpdatePasswordRequested', () {
    final event = AuthUpdatePasswordRequested(newPassword: 'newPass123');

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPasswordUpdated] on success',
      build: () {
        when(() => mockUpdatePassword(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [AuthLoading(), AuthPasswordUpdated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockUpdatePassword(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Failed to update password'),
      ],
    );
  });

  group('AuthChangePasswordRequested', () {
    final event = AuthChangePasswordRequested(
      oldPassword: 'oldPass',
      newPassword: 'newPass',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPasswordUpdated] on success',
      build: () {
        when(() => mockChangePassword(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [AuthLoading(), AuthPasswordUpdated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockChangePassword(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Failed to change password'),
      ],
    );
  });

  group('AuthDeleteAccountRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on success',
      build: () {
        when(() => mockDeleteAccount(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(AuthDeleteAccountRequested()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockDeleteAccount(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(AuthDeleteAccountRequested()),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Failed to delete account'),
      ],
    );
  });

  group('AuthResendVerificationEmailRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthVerificationEmailSent] on success',
      build: () {
        when(() => mockResendVerificationEmail(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(AuthResendVerificationEmailRequested()),
      expect: () => [AuthLoading(), AuthVerificationEmailSent()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockResendVerificationEmail(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(AuthResendVerificationEmailRequested()),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Failed to resend verification email'),
      ],
    );
  });

  group('AuthVerify2FARequested', () {
    final event = AuthVerify2FARequested(uid: '123', pin: '456789');

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Auth2FAVerified] when pin is valid',
      build: () {
        when(() => mockVerify2FA(any()))
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [AuthLoading(), Auth2FAVerified()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when pin is invalid',
      build: () {
        when(() => mockVerify2FA(any()))
            .thenAnswer((_) async => const Right(false));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Invalid 2FA PIN'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockVerify2FA(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        AuthLoading(),
        AuthError(message: '2FA verification failed'),
      ],
    );
  });

  group('AuthGenerateRecoveryCodesRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthRecoveryCodesGenerated] on success',
      build: () {
        when(() => mockGenerateRecoveryCodes(any()))
            .thenAnswer((_) async => Right(['code1', 'code2']));
        return bloc;
      },
      act: (bloc) => bloc.add(AuthGenerateRecoveryCodesRequested()),
      expect: () => [
        AuthLoading(),
        isA<AuthRecoveryCodesGenerated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockGenerateRecoveryCodes(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(AuthGenerateRecoveryCodesRequested()),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Failed to generate recovery codes'),
      ],
    );
  });

  group('AuthRecoverAccountRequested', () {
    final event = AuthRecoverAccountRequested(
      email: 'test@test.com',
      recoveryCode: 'CODE123',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAccountRecovered] on success',
      build: () {
        when(() => mockRecoverAccount(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        AuthLoading(),
        AuthAccountRecovered(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on invalid code',
      build: () {
        when(() => mockRecoverAccount(any()))
            .thenAnswer((_) async =>
                Left(InvalidCredentialsFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Invalid recovery code'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on server failure',
      build: () {
        when(() => mockRecoverAccount(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Server error, please try again later'),
      ],
    );
  });
}
