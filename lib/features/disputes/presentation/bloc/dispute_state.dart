import 'package:equatable/equatable.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';

abstract class DisputeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DisputeInitial extends DisputeState {}

class DisputeLoading extends DisputeState {}

class DisputeReported extends DisputeState {
  final DisputeEntity dispute;

  DisputeReported({required this.dispute});

  @override
  List<Object?> get props => [dispute];
}

class DisputeCreated extends DisputeState {
  final DisputeEntity dispute;

  DisputeCreated({required this.dispute});

  @override
  List<Object?> get props => [dispute];
}

class DisputeResolved extends DisputeState {
  final DisputeEntity dispute;

  DisputeResolved({required this.dispute});

  @override
  List<Object?> get props => [dispute];
}

class DisputeAppealed extends DisputeState {
  final DisputeEntity dispute;

  DisputeAppealed({required this.dispute});

  @override
  List<Object?> get props => [dispute];
}

class DisputesLoaded extends DisputeState {
  final List<DisputeEntity> disputes;

  DisputesLoaded({required this.disputes});

  @override
  List<Object?> get props => [disputes];
}

class DisputeDetailLoaded extends DisputeState {
  final DisputeEntity dispute;

  DisputeDetailLoaded({required this.dispute});

  @override
  List<Object?> get props => [dispute];
}

class DisputeError extends DisputeState {
  final String message;

  DisputeError({required this.message});

  @override
  List<Object?> get props => [message];
}
