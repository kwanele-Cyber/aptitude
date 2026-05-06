import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  String? get message => null;

  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  @override
  final String? message;
  ServerFailure([this.message]);

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {}

class InvalidCredentialsFailure extends Failure {}
