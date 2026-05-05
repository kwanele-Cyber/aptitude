import 'package:myapp/features/admin/data/models/admin_models.dart';

abstract class AdminRemoteDataSource {
  Future<AdminDashboardDataModel> getDashboardData();
  Future<List<AdminUserModel>> getUsers();
  Future<List<AdminUserModel>> searchUsers(String query, {String? role, String? status});
  Future<void> suspendUser(String userId, String reason);
  Future<void> deleteUser(String userId);
  Future<void> bulkAction(List<String> userIds, String action);
  Future<List<FlaggedContentModel>> getFlaggedContent({String? status, String? priority, String? type});
  Future<void> dismissFlag(String flagId);
  Future<void> removeContent(String flagId, String reason);
  Future<void> bulkModeration(List<String> flagIds, String action);
  Future<List<PenaltyModel>> getPenalties();
  Future<void> applyPenalty(String userId, String type, String reason);
  Future<void> overturnPenalty(String penaltyId);
  Future<AnalyticsDataModel> getAnalytics(String dateRange, {DateTime? start, DateTime? end});
  Future<SystemConfigModel> getConfig();
  Future<void> saveConfig(Map<String, dynamic> config);
  Future<void> restoreDefaultConfig();
  Future<List<SkillCategoryModel>> getCategories();
  Future<void> createCategory(Map<String, dynamic> data);
  Future<void> updateCategory(String id, Map<String, dynamic> data);
  Future<void> deleteCategory(String id);
  Future<void> reorderCategories(List<String> orderedIds);
  Future<List<BroadcastMessageModel>> getBroadcasts();
  Future<void> sendBroadcast(String title, String message, String audience, {DateTime? scheduledAt});
  Future<List<AuditLogEntryModel>> getAuditLogs({String? admin, String? action, int page = 1, int pageSize = 25});
  Future<List<AdminRoleModel>> getRoles();
  Future<void> createRole(String name, Map<String, List<String>> permissions);
  Future<void> updateRole(String id, Map<String, dynamic> data);
  Future<void> deleteRole(String id);
  Future<DatabaseStatsModel> getDatabaseStats();
  Future<void> runBackup();
  Future<void> restoreBackup();
  Future<void> runMaintenance();
}

class AdminRemoteDataSourceMock implements AdminRemoteDataSource {
  @override
  Future<AdminDashboardDataModel> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const AdminDashboardDataModel(totalUsers: 2847, activeMatches: 1234, sessionsThisWeek: 892, averageRating: 4.6);
  }

  @override
  Future<List<AdminUserModel>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockUsers;
  }

  @override
  Future<List<AdminUserModel>> searchUsers(String query, {String? role, String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var results = _mockUsers;
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((u) => u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q)).toList();
    }
    if (role != null && role != 'All') results = results.where((u) => u.role == role).toList();
    if (status != null && status != 'All') results = results.where((u) => u.status == status).toList();
    return results;
  }

  @override
  Future<void> suspendUser(String userId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> bulkAction(List<String> userIds, String action) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<List<FlaggedContentModel>> getFlaggedContent({String? status, String? priority, String? type}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockFlagged;
  }

  @override
  Future<void> dismissFlag(String flagId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> removeContent(String flagId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> bulkModeration(List<String> flagIds, String action) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<List<PenaltyModel>> getPenalties() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockPenalties;
  }

  @override
  Future<void> applyPenalty(String userId, String type, String reason) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> overturnPenalty(String penaltyId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<AnalyticsDataModel> getAnalytics(String dateRange, {DateTime? start, DateTime? end}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AnalyticsDataModel(
      newUsers: 847,
      totalMatches: 1234,
      sessionsCompleted: 892,
      avgRating: 4.6,
      avgTrustScore: 72.5,
      disputeRate: 0.03,
      userGrowth: [10, 18, 25, 22, 30, 45, 38, 52, 48, 60, 55, 72, 68, 85, 78, 95, 88, 102, 98, 115, 108, 125, 118, 135, 128, 142, 138, 150],
      matchSuccessByCategory: {'Technology': 0.78, 'Arts': 0.62, 'Music': 0.55, 'Academics': 0.71, 'Sports': 0.48, 'Business': 0.58},
      sessionCompletionRate: 0.78,
      sessionCancelRate: 0.12,
      sessionNoShowRate: 0.08,
      sessionRescheduleRate: 0.02,
    );
  }

  @override
  Future<SystemConfigModel> getConfig() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return SystemConfigModel(
      featureFlags: {'chatSystem': true, 'videoCalls': false, 'geoCheckin': true, 'qrScanner': true, 'e2eEncryption': false, 'trustV2': false, 'aiMatch': true},
      matchParams: {'matchRadius': 50, 'maxMatchesPerDay': 5, 'skillOverlap': 70, 'availWeight': 30, 'ratingWeight': 20},
      trustThresholds: {'excellentMin': 80, 'goodMin': 60, 'fairMin': 40, 'noShowPenalty': -15, 'sessionCredit': 2},
      generalSettings: {'sessionTimeout': 15, 'reviewEditWindow': 48, 'agreementExpiry': 90, 'maxAgreements': 10},
    );
  }

  @override
  Future<void> saveConfig(Map<String, dynamic> config) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> restoreDefaultConfig() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<List<SkillCategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockCategories;
  }

  @override
  Future<void> createCategory(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> reorderCategories(List<String> orderedIds) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<List<BroadcastMessageModel>> getBroadcasts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockBroadcasts;
  }

  @override
  Future<void> sendBroadcast(String title, String message, String audience, {DateTime? scheduledAt}) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<List<AuditLogEntryModel>> getAuditLogs({String? admin, String? action, int page = 1, int pageSize = 25}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockAuditLogs;
  }

  @override
  Future<List<AdminRoleModel>> getRoles() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockRoles;
  }

  @override
  Future<void> createRole(String name, Map<String, List<String>> permissions) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> updateRole(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> deleteRole(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<DatabaseStatsModel> getDatabaseStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return DatabaseStatsModel(
      totalDocuments: 24582,
      totalCollections: 14,
      storageUsed: '2.4 GB',
      lastBackup: 'Today 06:45',
      collections: [
        CollectionInfoModel(name: 'users', documents: 8450, size: '1.2 GB', status: 'Online'),
        CollectionInfoModel(name: 'skills', documents: 5230, size: '340 MB', status: 'Online'),
        CollectionInfoModel(name: 'matches', documents: 3890, size: '280 MB', status: 'Online'),
        CollectionInfoModel(name: 'sessions', documents: 2150, size: '190 MB', status: 'Online'),
        CollectionInfoModel(name: 'agreements', documents: 1240, size: '95 MB', status: 'Online'),
        CollectionInfoModel(name: 'reviews', documents: 3622, size: '160 MB', status: 'Online'),
        CollectionInfoModel(name: 'audit_logs', documents: 12847, size: '320 MB', status: 'Online'),
      ],
    );
  }

  @override
  Future<void> runBackup() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<void> restoreBackup() async {
    await Future.delayed(const Duration(seconds: 3));
  }

  @override
  Future<void> runMaintenance() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}

// Mock data

final _mockUsers = [
  AdminUserModel(id: '1', firstName: 'Kwanele', lastName: 'Mhlongo', email: 'kwanele@example.com', role: 'User', status: 'Active', joined: 'Jan 2026', sessions: 24, rating: 4.8),
  AdminUserModel(id: '2', firstName: 'Thandi', lastName: 'Nkosi', email: 'thandi@example.com', role: 'User', status: 'Active', joined: 'Feb 2026', sessions: 18, rating: 4.5),
  AdminUserModel(id: '3', firstName: 'Admin', lastName: 'A', email: 'admin@example.com', role: 'Admin', status: 'Active', joined: 'Dec 2025', sessions: 0, rating: 5.0),
  AdminUserModel(id: '4', firstName: 'Busi', lastName: 'Dlamini', email: 'busi@example.com', role: 'User', status: 'Suspended', joined: 'Mar 2026', sessions: 7, rating: 3.2),
  AdminUserModel(id: '5', firstName: 'Sipho', lastName: 'Zulu', email: 'sipho@example.com', role: 'Moderator', status: 'Active', joined: 'Jan 2026', sessions: 42, rating: 4.9),
  AdminUserModel(id: '6', firstName: 'Lindiwe', lastName: 'Mokoena', email: 'lindiwe@example.com', role: 'User', status: 'Active', joined: 'Apr 2026', sessions: 3, rating: 4.0),
  AdminUserModel(id: '7', firstName: 'Nomsa', lastName: 'Khumalo', email: 'nomsa@example.com', role: 'User', status: 'Banned', joined: 'Feb 2026', sessions: 1, rating: 1.0),
  AdminUserModel(id: '8', firstName: 'Themba', lastName: 'Mthembu', email: 'themba@example.com', role: 'Support', status: 'Active', joined: 'Nov 2025', sessions: 56, rating: 4.7),
];

final _mockFlagged = [
  FlaggedContentModel(id: 'f1', priority: 'HIGH', reason: 'Inappropriate message', preview: '"You are so..." in chat conversation', reportedBy: 'Thandi Nkosi', fromUser: 'Kwanele Mhlongo', timestamp: '5m ago', type: 'Message'),
  FlaggedContentModel(id: 'f2', priority: 'MED', reason: 'Spam review', preview: '"Check out my..." on Busi\'s profile', reportedBy: 'Auto-flagged', fromUser: 'Busi Dlamini', timestamp: '15m ago', type: 'Review'),
  FlaggedContentModel(id: 'f3', priority: 'LOW', reason: 'Offensive avatar', preview: 'Profile picture flagged as inappropriate', reportedBy: 'Auto-flagged', fromUser: 'Unknown', timestamp: '1h ago', type: 'Profile'),
  FlaggedContentModel(id: 'f4', priority: 'HIGH', reason: 'Harassment report', preview: 'Repeated messages in direct chat', reportedBy: 'Sipho Zulu', fromUser: 'Lindiwe Mokoena', timestamp: '2h ago', type: 'Message'),
  FlaggedContentModel(id: 'f5', priority: 'MED', reason: 'Misleading content', preview: 'False information in skill description', reportedBy: 'Nomsa Khumalo', fromUser: 'Themba Mthembu', timestamp: '3h ago', type: 'Skills'),
];

final _mockPenalties = [
  PenaltyModel(id: 'p1', severity: 'High', type: 'Permanent Ban', user: 'Nomsa Khumalo', userId: '7', reason: 'Repeated harassment', date: '2 days ago', duration: 'Permanent', strikes: 3),
  PenaltyModel(id: 'p2', severity: 'High', type: 'Suspension', user: 'Busi Dlamini', userId: '4', reason: 'False skill claims', date: '5 days ago', duration: '14 days remaining', strikes: 2),
  PenaltyModel(id: 'p3', severity: 'Medium', type: 'Warning', user: 'Sipho Zulu', userId: '5', reason: 'Inappropriate language', date: '1 week ago', duration: 'N/A', strikes: 1),
  PenaltyModel(id: 'p4', severity: 'Medium', type: 'Trust Score Reduction', user: 'Lindiwe Mokoena', userId: '6', reason: 'No-show on session', date: '2 weeks ago', duration: '-15 points', strikes: 1),
  PenaltyModel(id: 'p5', severity: 'Low', type: 'Content Removal', user: 'Themba Mthembu', userId: '8', reason: 'Spam listing', date: '3 weeks ago', duration: 'Listing removed', strikes: 0),
];

final _mockBroadcasts = [
  BroadcastMessageModel(id: 'b1', title: 'Platform Update v2.1', message: 'We\'re excited to announce...', audience: 'All Users', recipientCount: 2847, sentDate: 'Feb 10, 2026', openRate: 68),
  BroadcastMessageModel(id: 'b2', title: 'Maintenance Notice', message: 'Scheduled maintenance...', audience: 'All Users', recipientCount: 2801, sentDate: 'Feb 5, 2026', openRate: 82),
  BroadcastMessageModel(id: 'b3', title: 'Community Guidelines Update', message: 'Please review...', audience: 'All Users', recipientCount: 2750, sentDate: 'Jan 28, 2026', openRate: 74),
];

final _mockAuditLogs = [
  AuditLogEntryModel(id: 'l1', time: '10:32:15', admin: 'Admin_A', action: 'Suspended user Kwanele Mhlongo (#2847)', detail: 'Reason: Violation of Rule 3', severity: 'critical', ip: '192.168.1.1', device: 'Chrome/Windows', changes: 'Status: Active → Suspended'),
  AuditLogEntryModel(id: 'l2', time: '10:15:22', admin: 'Admin_B', action: 'Modified agreement #D-2026-0042 terms', detail: 'Change: Duration 8→12 weeks', severity: 'info', changes: 'Duration: 8 → 12 weeks'),
  AuditLogEntryModel(id: 'l3', time: '09:58:44', admin: 'System', action: 'User registered Thandi Nkosi (#2848)', detail: 'Email: thandi@example.com | Signup via: Google OAuth', severity: 'info'),
  AuditLogEntryModel(id: 'l4', time: '09:30:00', admin: 'Admin_A', action: 'Login successful', detail: 'Admin_A authenticated successfully', severity: 'info', ip: '10.0.0.5', device: 'Chrome/Windows'),
  AuditLogEntryModel(id: 'l5', time: '09:12:33', admin: 'Admin_C', action: 'Deleted review #1568 by Busi D', detail: 'Reason: Inappropriate content', severity: 'warning', changes: 'Review: visible → hidden'),
  AuditLogEntryModel(id: 'l6', time: '08:45:10', admin: 'System', action: 'Auto-flagged content in chat #2291', detail: 'Pattern: spam link detected', severity: 'warning'),
  AuditLogEntryModel(id: 'l7', time: '08:22:00', admin: 'Admin_B', action: 'Applied penalty to Sipho Zulu', detail: 'Type: Warning | Strike: 1/3', severity: 'warning'),
  AuditLogEntryModel(id: 'l8', time: '07:55:30', admin: 'Admin_A', action: 'Updated system config: match radius', detail: 'Changed from 30km to 50km', severity: 'info', changes: 'Match Radius: 30 → 50'),
  AuditLogEntryModel(id: 'l9', time: '07:30:00', admin: 'Admin_C', action: 'Resolved dispute #DSP-2026-0089', detail: 'Decision: In favor of reporter', severity: 'info'),
  AuditLogEntryModel(id: 'l10', time: '06:45:20', admin: 'System', action: 'Daily backup completed', detail: 'Size: 2.4GB | Duration: 12m 34s', severity: 'info'),
];

final _mockRoles = [
  AdminRoleModel(id: 'r1', name: 'Super Admin', members: 2, permissionCount: 47, totalPermissions: 47, isProtected: true, permissions: {
    'userManagement': ['View users', 'Edit users', 'Suspend users', 'Delete users'],
    'contentModeration': ['View flagged content', 'Dismiss flags', 'Remove content', 'Bulk moderation'],
    'disputeManagement': ['View disputes', 'Assign disputes', 'Resolve disputes', 'Close disputes'],
    'systemConfig': ['View config', 'Edit config', 'Manage feature flags'],
    'broadcast': ['Compose', 'Send', 'Schedule', 'View history'],
    'analytics': ['View analytics', 'Export data'],
    'auditLog': ['View log', 'Export log'],
  }),
  AdminRoleModel(id: 'r2', name: 'Moderator', members: 5, permissionCount: 32, totalPermissions: 47, isProtected: false, permissions: {
    'userManagement': ['View users', 'Edit users', 'Suspend users'],
    'contentModeration': ['View flagged content', 'Dismiss flags', 'Remove content'],
    'disputeManagement': ['View disputes', 'Assign disputes'],
    'broadcast': ['Compose', 'View history'],
    'analytics': ['View analytics'],
    'auditLog': ['View log'],
  }),
  AdminRoleModel(id: 'r3', name: 'Support', members: 3, permissionCount: 18, totalPermissions: 47, isProtected: false, permissions: {
    'userManagement': ['View users', 'Edit users'],
    'contentModeration': ['View flagged content', 'Dismiss flags'],
    'disputeManagement': ['View disputes'],
    'broadcast': ['View history'],
  }),
  AdminRoleModel(id: 'r4', name: 'Analyst', members: 2, permissionCount: 10, totalPermissions: 47, isProtected: false, permissions: {
    'userManagement': ['View users'],
    'broadcast': ['View history'],
    'analytics': ['View analytics', 'Export data'],
    'auditLog': ['View log', 'Export log'],
  }),
];

final _mockCategories = [
  SkillCategoryModel(id: 'c1', name: 'Technology & Programming', emoji: '📘', skillCount: 124, active: true, displayOrder: 1, subcategories: ['Web Development', 'Mobile Development', 'Data Science', 'DevOps & Cloud']),
  SkillCategoryModel(id: 'c2', name: 'Arts & Design', emoji: '🎨', skillCount: 89, active: true, displayOrder: 2, subcategories: ['Graphic Design', 'UI/UX', 'Animation', 'Photography']),
  SkillCategoryModel(id: 'c3', name: 'Music & Performance', emoji: '🎵', skillCount: 67, active: true, displayOrder: 3, subcategories: ['Guitar', 'Piano', 'Vocals', 'Drums', 'Production']),
  SkillCategoryModel(id: 'c4', name: 'Academics & Languages', emoji: '📚', skillCount: 156, active: true, displayOrder: 4, subcategories: ['Mathematics', 'English', 'French', 'Science']),
  SkillCategoryModel(id: 'c5', name: 'Sports & Fitness', emoji: '⚽', skillCount: 45, active: false, displayOrder: 5, subcategories: ['Soccer', 'Basketball', 'Yoga']),
  SkillCategoryModel(id: 'c6', name: 'Business & Finance', emoji: '💼', skillCount: 78, active: true, displayOrder: 6, subcategories: ['Marketing', 'Accounting', 'Entrepreneurship']),
];
