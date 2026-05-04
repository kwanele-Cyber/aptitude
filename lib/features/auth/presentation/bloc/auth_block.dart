import 'dart:async';

import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/generate_recovery_codes_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/get_user_profile_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/recover_account_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/register_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/resend_verification_email_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/verify_2fa_usecase.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final CheckAuthUsecase checkAuthUsecase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final ResendVerificationEmailUseCase resendVerificationEmailUseCase;
  final Verify2FAUseCase verify2FAUseCase;
  final GenerateRecoveryCodesUseCase generateRecoveryCodesUseCase;
  final RecoverAccountUseCase recoverAccountUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUsecase,
    required this.checkAuthUsecase,
    required this.resetPasswordUseCase,
    required this.updatePasswordUseCase,
    required this.changePasswordUseCase,
    required this.deleteAccountUseCase,
    required this.resendVerificationEmailUseCase,
    required this.verify2FAUseCase,
    required this.generateRecoveryCodesUseCase,
    required this.recoverAccountUseCase,
    required this.getUserProfileUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthResetPasswordRequested>(_onAuthResetPasswordRequested);
    on<AuthUpdatePasswordRequested>(_onAuthUpdatePasswordRequested);
    on<AuthChangePasswordRequested>(_onAuthChangePasswordRequested);
    on<AuthDeleteAccountRequested>(_onAuthDeleteAccountRequested);
    on<AuthResendVerificationEmailRequested>(_onAuthResendVerificationEmailRequested);
    on<AuthVerify2FARequested>(_onAuthVerify2FARequested);
    on<AuthGenerateRecoveryCodesRequested>(_onAuthGenerateRecoveryCodesRequested);
    on<AuthRecoverAccountRequested>(_onAuthRecoverAccountRequested);
    on<AuthViewUserProfileRequested>(_onAuthViewUserProfileRequested);
  }

  Future _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await checkAuthUsecase(NoParams());

    await result.fold(
      (left) async {
        emit(AuthUnauthenticated());
      },
      (right) async {
        if (right) {
          final userResult = await getCurrentUserUsecase(NoParams());
          await userResult.fold(
            (l) {
              emit(AuthUnauthenticated());
            },
            (r) {
              if (r != null) {
                emit(AuthAuthenticated(userEntity: r));
              } else {
                emit(AuthUnauthenticated());
              }
            },
          );
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    await result.fold(
      (left) async {
        String message = 'Auth Error';
        if (left is InvalidCredentialsFailure) {
          message = 'Invalid email or password';
        } else if (left is ServerFailure) {
          message = 'Server error, please try again later';
        } else if (left is CacheFailure) {
          message = 'Cache error, please try again later';
        }
        emit(AuthError(message: message));
      },
      (right) async {
        emit(AuthAuthenticated(userEntity: right));
      },
    );
  }

  Future _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await registerUseCase(
      RegisterParams(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
      ),
    );

    await result.fold(
      (left) async {
        String message = 'Registration Error';
        if (left is ServerFailure) {
          message = 'Server error, please try again later';
        } else if (left is CacheFailure) {
          message = 'Cache error, please try again later';
        }
        emit(AuthError(message: message));
      },
      (right) async {
        emit(AuthAuthenticated(userEntity: right));
      },
    );
  }

  Future _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final results = await logoutUseCase(NoParams());
    await results.fold(
      (left) async {
        emit(AuthError(message: 'Logout Error'));
      },
      (right) async {
        emit(AuthUnauthenticated());
      },
    );
  }

  Future _onAuthResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await resetPasswordUseCase(
      ResetPasswordParams(email: event.email),
    );

    await result.fold(
      (left) async {
        emit(AuthError(message: 'Failed to send reset email'));
      },
      (right) async {
        emit(AuthPasswordResetEmailSent());
      },
    );
  }

  Future _onAuthUpdatePasswordRequested(
    AuthUpdatePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await updatePasswordUseCase(
      UpdatePasswordParams(newPassword: event.newPassword),
    );

    await result.fold(
      (left) async {
        emit(AuthError(message: 'Failed to update password'));
      },
      (right) async {
        emit(AuthPasswordUpdated());
      },
    );
  }

  Future _onAuthChangePasswordRequested(
    AuthChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await changePasswordUseCase(
      ChangePasswordParams(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      ),
    );

    await result.fold(
      (left) async {
        emit(AuthError(message: 'Failed to change password'));
      },
      (right) async {
        emit(AuthPasswordUpdated());
      },
    );
  }

  Future _onAuthDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await deleteAccountUseCase(NoParams());

    await result.fold(
      (left) async {
        emit(AuthError(message: 'Failed to delete account'));
      },
      (right) async {
        emit(AuthUnauthenticated());
      },
    );
  }

  Future _onAuthResendVerificationEmailRequested(
    AuthResendVerificationEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await resendVerificationEmailUseCase(NoParams());

    await result.fold(
      (left) async {
        emit(AuthError(message: 'Failed to resend verification email'));
      },
      (right) async {
        emit(AuthVerificationEmailSent());
      },
    );
  }

  Future _onAuthVerify2FARequested(
    AuthVerify2FARequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await verify2FAUseCase(
      Verify2FAParams(uid: event.uid, pin: event.pin),
    );

    await result.fold(
      (left) async {
        emit(AuthError(message: '2FA verification failed'));
      },
      (right) async {
        if (right) {
          emit(Auth2FAVerified());
        } else {
          emit(AuthError(message: 'Invalid 2FA PIN'));
        }
      },
    );
  }

  Future _onAuthGenerateRecoveryCodesRequested(
    AuthGenerateRecoveryCodesRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await generateRecoveryCodesUseCase(NoParams());

    await result.fold(
      (left) async {
        emit(AuthError(message: 'Failed to generate recovery codes'));
      },
      (right) async {
        emit(AuthRecoveryCodesGenerated(codes: right));
      },
    );
  }

  Future _onAuthRecoverAccountRequested(
    AuthRecoverAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await recoverAccountUseCase(
      RecoverAccountParams(
        email: event.email,
        recoveryCode: event.recoveryCode,
      ),
    );

    await result.fold(
      (left) async {
        String message = 'Account recovery failed';
        if (left is InvalidCredentialsFailure) {
          message = 'Invalid recovery code';
        } else if (left is ServerFailure) {
          message = 'Server error, please try again later';
        }
        emit(AuthError(message: message));
      },
      (right) async {
        emit(AuthAccountRecovered());
      },
    );
  }

  Future _onAuthViewUserProfileRequested(
    AuthViewUserProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getUserProfileUseCase(
      GetUserProfileParams(uid: event.uid),
    );

    await result.fold(
      (left) async {
        emit(AuthError(message: 'Failed to load user profile'));
      },
      (right) async {
        emit(AuthUserProfileLoaded(user: right));
      },
    );
  }
}
