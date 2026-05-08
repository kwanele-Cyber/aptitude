import 'package:equatable/equatable.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';

abstract class AgreementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AgreementInitial extends AgreementState {}

class AgreementLoading extends AgreementState {}

class AgreementsLoaded extends AgreementState {
  final List<AgreementEntity> agreements;

  AgreementsLoaded({required this.agreements});

  @override
  List<Object?> get props => [agreements];
}

class AgreementDetailLoaded extends AgreementState {
  final AgreementEntity agreement;

  AgreementDetailLoaded({required this.agreement});

  @override
  List<Object?> get props => [agreement];
}

class AgreementCreated extends AgreementState {
  final AgreementEntity agreement;

  AgreementCreated({required this.agreement});

  @override
  List<Object?> get props => [agreement];
}

class AgreementActionSuccess extends AgreementState {
  final String message;

  AgreementActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AgreementError extends AgreementState {
  final String message;

  AgreementError({required this.message});

  @override
  List<Object?> get props => [message];
}
