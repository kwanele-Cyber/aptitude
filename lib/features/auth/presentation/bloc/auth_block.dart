import 'dart:async';

import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final CheckAuthUsecase checkAuthUsecase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUsecase,
    required this.checkAuthUsecase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
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
              emit(
                AuthUnauthenticated(),
              ); //Errors occured so treat as unauthenticated
            },
            (r) {
              if (r != null) {
                emit(
                  AuthAuthenticated(userEntity: r),
                ); //user is authenticated...
              } else {
                emit(
                  AuthUnauthenticated(),
                ); //...but no user data found, treat as unauthenticated
              }
            },
          );
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

    result.fold(
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

  Future _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final results = await logoutUseCase(NoParams());
    results.fold(
      (left) async {
        emit(AuthError(message: 'Logout Error'));
      },
      (right) async {
        emit(AuthUnauthenticated());
      },
    );
  }
}
