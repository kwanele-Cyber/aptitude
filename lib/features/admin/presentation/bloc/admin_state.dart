import 'package:equatable/equatable.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminDashboardLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final int totalUsers;
  final int activeMatches;
  final int sessionsThisWeek;
  final double averageRating;

  const AdminDashboardLoaded({
    this.totalUsers = 0,
    this.activeMatches = 0,
    this.sessionsThisWeek = 0,
    this.averageRating = 0.0,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        activeMatches,
        sessionsThisWeek,
        averageRating,
      ];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
