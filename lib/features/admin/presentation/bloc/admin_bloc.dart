import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/core/seeder/seeder_service.dart';
import 'package:myapp/features/admin/domain/usecases/admin_usecases.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_event.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final SeederService? _seederService;
  final GetDashboardDataUseCase? getDashboardData;
  final GetUsersUseCase? getUsers;
  final SearchUsersUseCase? searchUsers;
  final SuspendUserUseCase? suspendUser;
  final DeleteUserUseCase? deleteUser;
  final BulkUserActionUseCase? bulkUserAction;
  final GetFlaggedContentUseCase? getFlaggedContent;
  final DismissFlagUseCase? dismissFlag;
  final RemoveContentUseCase? removeContent;
  final BulkModerationUseCase? bulkModeration;
  final GetPenaltiesUseCase? getPenalties;
  final ApplyPenaltyUseCase? applyPenalty;
  final OverturnPenaltyUseCase? overturnPenalty;
  final GetAnalyticsUseCase? getAnalytics;
  final GetConfigUseCase? getConfig;
  final SaveConfigUseCase? saveConfig;
  final RestoreDefaultConfigUseCase? restoreConfig;
  final GetCategoriesUseCase? getCategories;
  final CreateCategoryUseCase? createCategory;
  final UpdateCategoryUseCase? updateCategory;
  final DeleteCategoryUseCase? deleteCategory;
  final ReorderCategoriesUseCase? reorderCategories;
  final GetBroadcastsUseCase? getBroadcasts;
  final SendBroadcastUseCase? sendBroadcast;
  final GetAuditLogsUseCase? getAuditLogs;
  final GetRolesUseCase? getRoles;
  final CreateRoleUseCase? createRole;
  final UpdateRoleUseCase? updateRole;
  final DeleteRoleUseCase? deleteRole;
  final GetDatabaseStatsUseCase? getDatabaseStats;
  final RunBackupUseCase? runBackup;
  final RestoreBackupUseCase? restoreBackup;
  final RunMaintenanceUseCase? runMaintenance;

  AdminBloc({
    this.getDashboardData,
    this.getUsers,
    this.searchUsers,
    this.suspendUser,
    this.deleteUser,
    this.bulkUserAction,
    this.getFlaggedContent,
    this.dismissFlag,
    this.removeContent,
    this.bulkModeration,
    this.getPenalties,
    this.applyPenalty,
    this.overturnPenalty,
    this.getAnalytics,
    this.getConfig,
    this.saveConfig,
    this.restoreConfig,
    this.getCategories,
    this.createCategory,
    this.updateCategory,
    this.deleteCategory,
    this.reorderCategories,
    this.getBroadcasts,
    this.sendBroadcast,
    this.getAuditLogs,
    this.getRoles,
    this.createRole,
    this.updateRole,
    this.deleteRole,
    this.getDatabaseStats,
    this.runBackup,
    this.restoreBackup,
    this.runMaintenance,
    SeederService? seederService,
  })  : _seederService = seederService,
        super(AdminInitial()) {
    on<AdminLoadDashboard>(_onLoadDashboard);
    on<AdminLoadUsers>(_onLoadUsers);
    on<AdminSearchUsers>(_onSearchUsers);
    on<AdminSuspendUser>(_onSuspendUser);
    on<AdminDeleteUser>(_onDeleteUser);
    on<AdminBulkUserAction>(_onBulkUserAction);
    on<AdminLoadFlaggedContent>(_onLoadFlaggedContent);
    on<AdminDismissFlag>(_onDismissFlag);
    on<AdminRemoveContent>(_onRemoveContent);
    on<AdminBulkModeration>(_onBulkModeration);
    on<AdminLoadPenalties>(_onLoadPenalties);
    on<AdminApplyPenalty>(_onApplyPenalty);
    on<AdminOverturnPenalty>(_onOverturnPenalty);
    on<AdminLoadAnalytics>(_onLoadAnalytics);
    on<AdminLoadConfig>(_onLoadConfig);
    on<AdminSaveConfig>(_onSaveConfig);
    on<AdminRestoreConfig>(_onRestoreConfig);
    on<AdminLoadCategories>(_onLoadCategories);
    on<AdminCreateCategory>(_onCreateCategory);
    on<AdminUpdateCategory>(_onUpdateCategory);
    on<AdminDeleteCategory>(_onDeleteCategory);
    on<AdminReorderCategories>(_onReorderCategories);
    on<AdminLoadBroadcasts>(_onLoadBroadcasts);
    on<AdminSendBroadcast>(_onSendBroadcast);
    on<AdminLoadAuditLogs>(_onLoadAuditLogs);
    on<AdminLoadRoles>(_onLoadRoles);
    on<AdminCreateRole>(_onCreateRole);
    on<AdminUpdateRole>(_onUpdateRole);
    on<AdminDeleteRole>(_onDeleteRole);
    on<AdminLoadDatabaseStats>(_onLoadDatabaseStats);
    on<AdminRunBackup>(_onRunBackup);
    on<AdminRestoreBackup>(_onRestoreBackup);
    on<AdminRunMaintenance>(_onRunMaintenance);
    on<AdminSeedDatabase>(_onSeedDatabase);
    on<AdminClearOperationStatus>(_onClearOperationStatus);
  }

  // Dashboard
  Future<void> _onLoadDashboard(AdminLoadDashboard event, Emitter<AdminState> emit) async {
    emit(AdminDashboardLoading());
    if (getDashboardData == null) {
      emit(const AdminDashboardLoaded(totalUsers: 0, activeMatches: 0, sessionsThisWeek: 0, averageRating: 0.0));
      return;
    }
    final result = await getDashboardData!();
    result.fold(
      (l) => emit(const AdminError('Failed to load dashboard data')),
      (r) => emit(AdminDashboardLoaded(totalUsers: r.totalUsers, activeMatches: r.activeMatches, sessionsThisWeek: r.sessionsThisWeek, averageRating: r.averageRating)),
    );
  }

  // Users
  Future<void> _onLoadUsers(AdminLoadUsers event, Emitter<AdminState> emit) async {
    emit(AdminUsersLoading());
    if (getUsers == null) return;
    final result = await getUsers!();
    result.fold((l) => emit(const AdminError('Failed to load users')), (r) => emit(AdminUsersLoaded(r)));
  }

  Future<void> _onSearchUsers(AdminSearchUsers event, Emitter<AdminState> emit) async {
    emit(AdminUsersLoading());
    if (searchUsers == null) return;
    final result = await searchUsers!(event.query, role: event.role, status: event.status);
    result.fold((l) => emit(const AdminError('Search failed')), (r) => emit(AdminUsersLoaded(r)));
  }

  Future<void> _onSuspendUser(AdminSuspendUser event, Emitter<AdminState> emit) async {
    if (suspendUser == null) return;
    final result = await suspendUser!(event.userId, event.reason);
    result.fold((l) => emit(const AdminError('Failed to suspend user')), (r) => emit(const AdminOperationSuccess('User suspended')));
  }

  Future<void> _onDeleteUser(AdminDeleteUser event, Emitter<AdminState> emit) async {
    if (deleteUser == null) return;
    final result = await deleteUser!(event.userId);
    result.fold((l) => emit(const AdminError('Failed to delete user')), (r) => emit(const AdminOperationSuccess('User deleted')));
  }

  Future<void> _onBulkUserAction(AdminBulkUserAction event, Emitter<AdminState> emit) async {
    if (bulkUserAction == null) return;
    final result = await bulkUserAction!(event.userIds, event.action);
    result.fold((l) => emit(const AdminError('Bulk action failed')), (r) => emit(AdminOperationSuccess('${event.action} applied to ${event.userIds.length} users')));
  }

  // Moderation
  Future<void> _onLoadFlaggedContent(AdminLoadFlaggedContent event, Emitter<AdminState> emit) async {
    emit(AdminModerationLoading());
    if (getFlaggedContent == null) return;
    final result = await getFlaggedContent!(status: event.status, priority: event.priority, type: event.type);
    result.fold((l) => emit(const AdminError('Failed to load flagged content')), (r) => emit(AdminModerationLoaded(r)));
  }

  Future<void> _onDismissFlag(AdminDismissFlag event, Emitter<AdminState> emit) async {
    if (dismissFlag == null) return;
    final result = await dismissFlag!(event.flagId);
    result.fold((l) => emit(const AdminError('Failed to dismiss flag')), (r) => emit(const AdminOperationSuccess('Flag dismissed')));
  }

  Future<void> _onRemoveContent(AdminRemoveContent event, Emitter<AdminState> emit) async {
    if (removeContent == null) return;
    final result = await removeContent!(event.flagId, event.reason);
    result.fold((l) => emit(const AdminError('Failed to remove content')), (r) => emit(const AdminOperationSuccess('Content removed')));
  }

  Future<void> _onBulkModeration(AdminBulkModeration event, Emitter<AdminState> emit) async {
    if (bulkModeration == null) return;
    final result = await bulkModeration!(event.flagIds, event.action);
    result.fold((l) => emit(const AdminError('Bulk moderation failed')), (r) => emit(AdminOperationSuccess('${event.action} applied to ${event.flagIds.length} items')));
  }

  // Penalties
  Future<void> _onLoadPenalties(AdminLoadPenalties event, Emitter<AdminState> emit) async {
    emit(AdminPenaltiesLoading());
    if (getPenalties == null) return;
    final result = await getPenalties!();
    result.fold((l) => emit(const AdminError('Failed to load penalties')), (r) => emit(AdminPenaltiesLoaded(r)));
  }

  Future<void> _onApplyPenalty(AdminApplyPenalty event, Emitter<AdminState> emit) async {
    if (applyPenalty == null) return;
    final result = await applyPenalty!(event.userId, event.type, event.reason);
    result.fold((l) => emit(const AdminError('Failed to apply penalty')), (r) => emit(const AdminOperationSuccess('Penalty applied')));
  }

  Future<void> _onOverturnPenalty(AdminOverturnPenalty event, Emitter<AdminState> emit) async {
    if (overturnPenalty == null) return;
    final result = await overturnPenalty!(event.penaltyId);
    result.fold((l) => emit(const AdminError('Failed to overturn penalty')), (r) => emit(const AdminOperationSuccess('Penalty overturned')));
  }

  // Analytics
  Future<void> _onLoadAnalytics(AdminLoadAnalytics event, Emitter<AdminState> emit) async {
    emit(AdminAnalyticsLoading());
    if (getAnalytics == null) return;
    final result = await getAnalytics!(event.dateRange, start: event.start, end: event.end);
    result.fold((l) => emit(const AdminError('Failed to load analytics')), (r) => emit(AdminAnalyticsLoaded(r)));
  }

  // Config
  Future<void> _onLoadConfig(AdminLoadConfig event, Emitter<AdminState> emit) async {
    emit(AdminConfigLoading());
    if (getConfig == null) return;
    final result = await getConfig!();
    result.fold((l) => emit(const AdminError('Failed to load config')), (r) => emit(AdminConfigLoaded(r)));
  }

  Future<void> _onSaveConfig(AdminSaveConfig event, Emitter<AdminState> emit) async {
    if (saveConfig == null) return;
    final result = await saveConfig!(event.config);
    result.fold((l) => emit(const AdminError('Failed to save config')), (r) => emit(const AdminOperationSuccess('Configuration saved')));
  }

  Future<void> _onRestoreConfig(AdminRestoreConfig event, Emitter<AdminState> emit) async {
    if (restoreConfig == null) return;
    final result = await restoreConfig!();
    result.fold((l) => emit(const AdminError('Failed to restore config')), (r) => emit(const AdminOperationSuccess('Defaults restored')));
  }

  // Categories
  Future<void> _onLoadCategories(AdminLoadCategories event, Emitter<AdminState> emit) async {
    emit(AdminCategoriesLoading());
    if (getCategories == null) return;
    final result = await getCategories!();
    result.fold((l) => emit(const AdminError('Failed to load categories')), (r) => emit(AdminCategoriesLoaded(r)));
  }

  Future<void> _onCreateCategory(AdminCreateCategory event, Emitter<AdminState> emit) async {
    if (createCategory == null) return;
    final result = await createCategory!(event.data);
    result.fold((l) => emit(const AdminError('Failed to create category')), (r) => emit(const AdminOperationSuccess('Category created')));
  }

  Future<void> _onUpdateCategory(AdminUpdateCategory event, Emitter<AdminState> emit) async {
    if (updateCategory == null) return;
    final result = await updateCategory!(event.id, event.data);
    result.fold((l) => emit(const AdminError('Failed to update category')), (r) => emit(const AdminOperationSuccess('Category updated')));
  }

  Future<void> _onDeleteCategory(AdminDeleteCategory event, Emitter<AdminState> emit) async {
    if (deleteCategory == null) return;
    final result = await deleteCategory!(event.id);
    result.fold((l) => emit(const AdminError('Failed to delete category')), (r) => emit(const AdminOperationSuccess('Category deleted')));
  }

  Future<void> _onReorderCategories(AdminReorderCategories event, Emitter<AdminState> emit) async {
    if (reorderCategories == null) return;
    final result = await reorderCategories!(event.orderedIds);
    result.fold((l) => emit(const AdminError('Failed to reorder')), (r) => emit(const AdminOperationSuccess('Categories reordered')));
  }

  // Broadcasts
  Future<void> _onLoadBroadcasts(AdminLoadBroadcasts event, Emitter<AdminState> emit) async {
    emit(AdminBroadcastsLoading());
    if (getBroadcasts == null) return;
    final result = await getBroadcasts!();
    result.fold((l) => emit(const AdminError('Failed to load broadcasts')), (r) => emit(AdminBroadcastsLoaded(r)));
  }

  Future<void> _onSendBroadcast(AdminSendBroadcast event, Emitter<AdminState> emit) async {
    if (sendBroadcast == null) return;
    final result = await sendBroadcast!(event.title, event.message, event.audience, scheduledAt: event.scheduledAt);
    result.fold((l) => emit(const AdminError('Failed to send broadcast')), (r) => emit(const AdminOperationSuccess('Broadcast sent')));
  }

  // Audit Log
  Future<void> _onLoadAuditLogs(AdminLoadAuditLogs event, Emitter<AdminState> emit) async {
    emit(AdminAuditLogLoading());
    if (getAuditLogs == null) return;
    final result = await getAuditLogs!(admin: event.admin, action: event.action, page: event.page, pageSize: event.pageSize);
    result.fold((l) => emit(const AdminError('Failed to load audit logs')), (r) => emit(AdminAuditLogLoaded(r, page: event.page, hasMore: r.length >= event.pageSize)));
  }

  // Roles
  Future<void> _onLoadRoles(AdminLoadRoles event, Emitter<AdminState> emit) async {
    emit(AdminRolesLoading());
    if (getRoles == null) return;
    final result = await getRoles!();
    result.fold((l) => emit(const AdminError('Failed to load roles')), (r) => emit(AdminRolesLoaded(r)));
  }

  Future<void> _onCreateRole(AdminCreateRole event, Emitter<AdminState> emit) async {
    if (createRole == null) return;
    final result = await createRole!(event.name, event.permissions);
    result.fold((l) => emit(const AdminError('Failed to create role')), (r) => emit(const AdminOperationSuccess('Role created')));
  }

  Future<void> _onUpdateRole(AdminUpdateRole event, Emitter<AdminState> emit) async {
    if (updateRole == null) return;
    final result = await updateRole!(event.id, event.data);
    result.fold((l) => emit(const AdminError('Failed to update role')), (r) => emit(const AdminOperationSuccess('Role updated')));
  }

  Future<void> _onDeleteRole(AdminDeleteRole event, Emitter<AdminState> emit) async {
    if (deleteRole == null) return;
    final result = await deleteRole!(event.id);
    result.fold((l) => emit(const AdminError('Failed to delete role')), (r) => emit(const AdminOperationSuccess('Role deleted')));
  }

  // Database
  Future<void> _onLoadDatabaseStats(AdminLoadDatabaseStats event, Emitter<AdminState> emit) async {
    emit(AdminDatabaseLoading());
    if (getDatabaseStats == null) return;
    final result = await getDatabaseStats!();
    result.fold((l) => emit(const AdminError('Failed to load database stats')), (r) => emit(AdminDatabaseLoaded(r)));
  }

  Future<void> _onRunBackup(AdminRunBackup event, Emitter<AdminState> emit) async {
    if (runBackup == null) return;
    final result = await runBackup!();
    result.fold((l) => emit(const AdminError('Backup failed')), (r) => emit(const AdminOperationSuccess('Backup completed')));
  }

  Future<void> _onRestoreBackup(AdminRestoreBackup event, Emitter<AdminState> emit) async {
    if (restoreBackup == null) return;
    final result = await restoreBackup!();
    result.fold((l) => emit(const AdminError('Restore failed')), (r) => emit(const AdminOperationSuccess('Backup restored')));
  }

  Future<void> _onRunMaintenance(AdminRunMaintenance event, Emitter<AdminState> emit) async {
    if (runMaintenance == null) return;
    final result = await runMaintenance!();
    result.fold((l) => emit(const AdminError('Maintenance failed')), (r) => emit(const AdminOperationSuccess('Maintenance completed')));
  }

  // Seed
  Future<void> _onSeedDatabase(AdminSeedDatabase event, Emitter<AdminState> emit) async {
    if (_seederService == null) return;
    await for (final progress in _seederService.run()) {
      if (progress.isError) {
        emit(AdminSeedError(progress.step));
        return;
      }
      emit(AdminSeedInProgress(step: progress.step, progress: progress.progress));
    }
    emit(AdminSeedComplete(_seederService.lastResults));
  }

  void _onClearOperationStatus(AdminClearOperationStatus event, Emitter<AdminState> emit) {
    emit(AdminInitial());
  }
}
