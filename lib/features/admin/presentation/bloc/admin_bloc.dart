import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_event.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(AdminInitial()) {
    on<AdminLoadDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    AdminLoadDashboard event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminDashboardLoading());
    try {
      // TODO: Load real dashboard data from use cases
      emit(const AdminDashboardLoaded(
        totalUsers: 0,
        activeMatches: 0,
        sessionsThisWeek: 0,
        averageRating: 0.0,
      ));
    } catch (e) {
      emit(AdminError('Failed to load dashboard data'));
    }
  }
}
