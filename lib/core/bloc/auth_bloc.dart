import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Events ────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoggedIn extends AuthEvent {
  const AuthLoggedIn();
}

class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}

// ── States ────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// ── Bloc ──────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoggedIn>(_onLoggedIn);
    on<AuthLoggedOut>(_onLoggedOut);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    await FirebaseAuth.instance.authStateChanges().first;

    final user = _authService.currentUser;
    final prefs = await SharedPreferences.getInstance();

    if (user != null) {
      await prefs.setBool('logged_in', true);
      emit(const AuthAuthenticated());
    } else {
      await prefs.setBool('logged_in', false);
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', true);
    emit(const AuthAuthenticated());
  }

  Future<void> _onLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) async {
    await _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', false);
    emit(const AuthUnauthenticated());
  }
}
