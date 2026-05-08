import 'package:equatable/equatable.dart';

abstract class TrustEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CalculateTrustScoreRequested extends TrustEvent {
  final String userId;
  CalculateTrustScoreRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateReputationRequested extends TrustEvent {
  final String userId;
  final String event;
  final Map<String, dynamic> data;
  UpdateReputationRequested({
    required this.userId,
    required this.event,
    required this.data,
  });

  @override
  List<Object?> get props => [userId, event, data];
}

class FilterByTrustRequested extends TrustEvent {
  final int threshold;
  FilterByTrustRequested({required this.threshold});

  @override
  List<Object?> get props => [threshold];
}

class GetTrustProfileRequested extends TrustEvent {
  final String userId;
  GetTrustProfileRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SubmitAppealRequested extends TrustEvent {
  final String userId;
  final String reason;
  SubmitAppealRequested({required this.userId, required this.reason});

  @override
  List<Object?> get props => [userId, reason];
}

class GetAppealsRequested extends TrustEvent {
  final String userId;
  GetAppealsRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
