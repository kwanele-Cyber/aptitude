import 'package:equatable/equatable.dart';
import 'package:myapp/features/auth/domain/entity/user_entity.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity userEntity;

  AuthAuthenticated({required this.userEntity});

  @override
  List<Object?> get props => [userEntity];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetEmailSent extends AuthState {}

class AuthPasswordUpdated extends AuthState {}

class AuthVerificationEmailSent extends AuthState {}

class Auth2FAVerified extends AuthState {}

class AuthRecoveryCodesGenerated extends AuthState {
  final List<String> codes;

  AuthRecoveryCodesGenerated({required this.codes});

  @override
  List<Object?> get props => codes;
}

class AuthAccountRecovered extends AuthState {}

class AuthUserDataExported extends AuthState {
  final String data;

  AuthUserDataExported({required this.data});

  @override
  List<Object?> get props => [data];
}

class AuthUserProfileLoaded extends AuthState {
  final UserEntity user;

  AuthUserProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}
