import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthRegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  AuthRegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, password];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  AuthResetPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthUpdatePasswordRequested extends AuthEvent {
  final String newPassword;

  AuthUpdatePasswordRequested({required this.newPassword});

  @override
  List<Object?> get props => [newPassword];
}

class AuthChangePasswordRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  AuthChangePasswordRequested({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}

class AuthDeleteAccountRequested extends AuthEvent {}

class AuthResendVerificationEmailRequested extends AuthEvent {}

class AuthVerify2FARequested extends AuthEvent {
  final String uid;
  final String pin;

  AuthVerify2FARequested({required this.uid, required this.pin});

  @override
  List<Object?> get props => [uid, pin];
}

class AuthGenerateRecoveryCodesRequested extends AuthEvent {}

class AuthViewUserProfileRequested extends AuthEvent {
  final String uid;

  AuthViewUserProfileRequested({required this.uid});

  @override
  List<Object?> get props => [uid];
}

class AuthRecoverAccountRequested extends AuthEvent {
  final String email;
  final String recoveryCode;

  AuthRecoverAccountRequested({
    required this.email,
    required this.recoveryCode,
  });

  @override
  List<Object?> get props => [email, recoveryCode];
}
