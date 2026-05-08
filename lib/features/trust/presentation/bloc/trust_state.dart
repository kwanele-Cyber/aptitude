import 'package:equatable/equatable.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';

abstract class TrustState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TrustInitial extends TrustState {}

class TrustLoading extends TrustState {}

class TrustScoreLoaded extends TrustState {
  final TrustEntity trust;
  TrustScoreLoaded({required this.trust});

  @override
  List<Object?> get props => [trust];
}

class TrustProfileLoaded extends TrustState {
  final TrustEntity profile;
  TrustProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class TrustFilteredUsersLoaded extends TrustState {
  final List<String> userIds;
  final int threshold;
  TrustFilteredUsersLoaded({
    required this.userIds,
    required this.threshold,
  });

  @override
  List<Object?> get props => [userIds, threshold];
}

class AppealSubmitted extends TrustState {
  final TrustAppealEntity appeal;
  AppealSubmitted({required this.appeal});

  @override
  List<Object?> get props => [appeal];
}

class AppealsLoaded extends TrustState {
  final List<TrustAppealEntity> appeals;
  AppealsLoaded({required this.appeals});

  @override
  List<Object?> get props => [appeals];
}

class TrustActionSuccess extends TrustState {
  final String message;
  TrustActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class TrustError extends TrustState {
  final String message;
  TrustError({required this.message});

  @override
  List<Object?> get props => [message];
}
