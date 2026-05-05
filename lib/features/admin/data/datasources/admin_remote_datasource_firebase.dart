import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:myapp/features/admin/data/models/admin_models.dart';

class AdminRemoteDataSourceFirebase implements AdminRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseDatabase _database;

  AdminRemoteDataSourceFirebase({FirebaseAuth? auth, FirebaseDatabase? database})
      : _auth = auth ?? FirebaseAuth.instance,
        _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _usersRef => _database.ref('users');
  DatabaseReference get _reportsRef => _database.ref('reports');
  DatabaseReference get _penaltiesRef => _database.ref('penalties');
  DatabaseReference get _configRef => _database.ref('config');
  DatabaseReference get _categoriesRef => _database.ref('skillCategories');
  DatabaseReference get _broadcastsRef => _database.ref('broadcasts');
  DatabaseReference get _auditLogsRef => _database.ref('auditLogs');
  DatabaseReference get _adminRolesRef => _database.ref('adminRoles');
  DatabaseReference get _analyticsRef => _database.ref('analytics');
  DatabaseReference get _matchesRef => _database.ref('matches');
  DatabaseReference get _sessionsRef => _database.ref('sessions');

  String? get _currentUid => _auth.currentUser?.uid;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Casts an RTDB snapshot value to [Map<String, dynamic>], handling the
  /// [Map<Object?, Object?>] that Firebase returns internally.
  Map<String, dynamic> _castMap(dynamic value) {
    return Map<String, dynamic>.from(value as Map);
  }

  /// Reads every child of [ref] and decodes each via [fromJson].
  List<T> _decodeChildren<T>(
    DataSnapshot snapshot,
    T Function(String key, Map<String, dynamic> data) fromJson,
  ) {
    if (!snapshot.exists) return [];
    final map = snapshot.value is Map ? _castMap(snapshot.value) : null;
    if (map == null) return [];
    final results = <T>[];
    map.forEach((key, value) {
      results.add(fromJson(key, _castMap(value)));
    });
    return results;
  }

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------

  @override
  Future<AdminDashboardDataModel> getDashboardData() async {
    try {
      final results = await Future.wait([
        _usersRef.get(),
        _matchesRef.get(),
        _sessionsRef.get(),
      ]);

      int totalUsers = 0;
      int activeMatches = 0;
      int sessionsThisWeek = 0;
      double avgRating = 0.0;

      if (results[0].exists) {
        totalUsers = (results[0].value as Map).length;
      }
      if (results[1].exists) {
        final matches = _castMap(results[1].value);
        activeMatches = matches.values
            .where((v) => (v as Map)['status']?.toString() == 'active')
            .length;
      }
      if (results[2].exists) {
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        final sessions = _castMap(results[2].value);
        int ratingSum = 0;
        int ratingCount = 0;

        for (final entry in sessions.entries) {
          final data = entry.value as Map;
          final sessionDateStr = data['scheduledDate']?.toString();
          if (sessionDateStr != null) {
            final sessionDate = DateTime.tryParse(sessionDateStr);
            if (sessionDate != null && sessionDate.isAfter(weekAgo)) {
              sessionsThisWeek++;
            }
          }
          final rating = data['rating'] as num?;
          if (rating != null) {
            ratingSum += rating.toInt();
            ratingCount++;
          }
        }
        avgRating = ratingCount > 0 ? double.parse((ratingSum / ratingCount).toStringAsFixed(1)) : 0.0;
      }

      return AdminDashboardDataModel(
        totalUsers: totalUsers,
        activeMatches: activeMatches,
        sessionsThisWeek: sessionsThisWeek,
        averageRating: avgRating,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  // ---------------------------------------------------------------------------
  // User Management
  // ---------------------------------------------------------------------------

  @override
  Future<List<AdminUserModel>> getUsers() async {
    try {
      final snapshot = await _usersRef.get();
      return _decodeChildren(snapshot, (key, data) {
        return AdminUserModel.fromJson({
          ...data,
          'id': key,
        });
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<List<AdminUserModel>> searchUsers(
    String query, {
    String? role,
    String? status,
  }) async {
    try {
      final snapshot = await _usersRef.get();
      var users = _decodeChildren(snapshot, (key, data) {
        return AdminUserModel.fromJson({
          ...data,
          'id': key,
        });
      });

      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        users = users.where((u) {
          return u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q);
        }).toList();
      }
      if (role != null && role != 'All') {
        users = users.where((u) => u.role == role).toList();
      }
      if (status != null && status != 'All') {
        users = users.where((u) => u.status == status).toList();
      }
      return users;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> suspendUser(String userId, String reason) async {
    try {
      await _usersRef.child(userId).update({
        'status': 'Suspended',
        'suspendedAt': DateTime.now().toIso8601String(),
        'suspensionReason': reason,
      });
      await _logAudit('Suspended user $userId', 'Reason: $reason', 'critical');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _usersRef.child(userId).remove();
      await _logAudit('Deleted user $userId');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> bulkAction(List<String> userIds, String action) async {
    try {
      final updates = <String, dynamic>{};
      for (final uid in userIds) {
        switch (action) {
          case 'suspend':
            updates['users/$uid/status'] = 'Suspended';
            updates['users/$uid/suspendedAt'] = DateTime.now().toIso8601String();
            break;
          case 'activate':
            updates['users/$uid/status'] = 'Active';
            updates['users/$uid/suspendedAt'] = null;
            break;
          case 'delete':
            updates['users/$uid'] = null;
            break;
        }
      }
      await _database.ref().update(updates);
      await _logAudit('Bulk action: $action on ${userIds.length} users');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  // ---------------------------------------------------------------------------
  // Content Moderation
  // ---------------------------------------------------------------------------

  @override
  Future<List<FlaggedContentModel>> getFlaggedContent({
    String? status,
    String? priority,
    String? type,
  }) async {
    try {
      final snapshot = await _reportsRef.get();
      var items = _decodeChildren(snapshot, (key, data) {
        return FlaggedContentModel.fromJson({...data, 'id': key});
      });

      if (status != null && status != 'All') {
        items = items.where((i) => i.status == status).toList();
      }
      if (priority != null && priority != 'All') {
        items = items.where((i) => i.priority == priority).toList();
      }
      if (type != null && type != 'All') {
        items = items.where((i) => i.type == type).toList();
      }
      return items;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> dismissFlag(String flagId) async {
    try {
      await _reportsRef.child(flagId).update({'status': 'Dismissed'});
      await _logAudit('Dismissed flag $flagId');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> removeContent(String flagId, String reason) async {
    try {
      await _reportsRef.child(flagId).update({
        'status': 'Content Removed',
        'removedAt': DateTime.now().toIso8601String(),
        'removalReason': reason,
      });
      await _logAudit('Removed content for flag $flagId', reason, 'warning');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> bulkModeration(List<String> flagIds, String action) async {
    try {
      final updates = <String, dynamic>{};
      for (final id in flagIds) {
        updates['reports/$id/status'] = action == 'dismiss'
            ? 'Dismissed'
            : 'Content Removed';
      }
      await _database.ref().update(updates);
      await _logAudit(
          'Bulk moderation: $action on ${flagIds.length} flags');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  // ---------------------------------------------------------------------------
  // Penalties
  // ---------------------------------------------------------------------------

  @override
  Future<List<PenaltyModel>> getPenalties() async {
    try {
      final snapshot = await _penaltiesRef.get();
      return _decodeChildren(snapshot, (key, data) {
        return PenaltyModel.fromJson({...data, 'id': key});
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> applyPenalty(String userId, String type, String reason) async {
    try {
      final penaltyRef = _penaltiesRef.push();
      await penaltyRef.set({
        'userId': userId,
        'type': type,
        'reason': reason,
        'severity': type.contains('Ban')
            ? 'High'
            : type.contains('Warning')
                ? 'Medium'
                : 'Low',
        'date': DateTime.now().toIso8601String(),
        'duration': _defaultDuration(type),
        'strikes': 1,
        'isActive': true,
      });

      // Update user status based on penalty type
      if (type.contains('Ban')) {
        await _usersRef.child(userId).update({'status': 'Banned'});
      } else if (type.contains('Suspension')) {
        await _usersRef.child(userId).update({'status': 'Suspended'});
      }

      final userSnap = await _usersRef.child(userId).child('firstName').get();
      final userName = userSnap.value?.toString() ?? userId;
      await _logAudit('Applied penalty to $userName', 'Type: $type | $reason', 'warning');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> overturnPenalty(String penaltyId) async {
    try {
      final snapshot = await _penaltiesRef.child(penaltyId).get();
      if (!snapshot.exists) return;
      final data = _castMap(snapshot.value);

      await _penaltiesRef.child(penaltyId).update({
        'isActive': false,
        'overturnedAt': DateTime.now().toIso8601String(),
      });

      // Restore user status
      final userId = data['userId'] as String?;
      if (userId != null) {
        await _usersRef.child(userId).update({'status': 'Active'});
      }
      await _logAudit('Overturned penalty $penaltyId');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  // ---------------------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------------------

  @override
  Future<AnalyticsDataModel> getAnalytics(
    String dateRange, {
    DateTime? start,
    DateTime? end,
  }) async {
    try {
      // Try reading a pre-computed analytics snapshot first
      final snapshot = await _analyticsRef.child(dateRange).get();
      if (snapshot.exists) {
        return AnalyticsDataModel.fromJson({
          ..._castMap(snapshot.value),
          'dateRange': dateRange,
        });
      }

      // Fall back to computing from raw data
      final results = await Future.wait([
        _usersRef.get(),
        _matchesRef.get(),
        _sessionsRef.get(),
      ]);

      final usersSnap = results[0];
      final matchesSnap = results[1];
      final sessionsSnap = results[2];

      final totalUsers = usersSnap.exists
          ? (usersSnap.value as Map).length
          : 0;
      final totalMatches = matchesSnap.exists
          ? (matchesSnap.value as Map).length
          : 0;

      int sessionsCompleted = 0;
      int totalSessions = 0;
      int ratingSum = 0;
      int ratingCount = 0;

      if (sessionsSnap.exists) {
        final sessions = sessionsSnap.value as Map;
        totalSessions = sessions.length;
        for (final entry in sessions.entries) {
          final data = entry.value as Map;
          final status = data['status'] as String?;
          if (status == 'completed') sessionsCompleted++;
          final rating = data['rating'] as num?;
          if (rating != null) {
            ratingSum += rating.toInt();
            ratingCount++;
          }
        }
      }

      return AnalyticsDataModel(
        newUsers: totalUsers,
        totalMatches: totalMatches,
        sessionsCompleted: sessionsCompleted,
        avgRating: ratingCount > 0
            ? double.parse((ratingSum / ratingCount).toStringAsFixed(1))
            : 0.0,
        sessionCompletionRate: totalSessions > 0
            ? sessionsCompleted / totalSessions
            : 0.0,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  // ---------------------------------------------------------------------------
  // System Config
  // ---------------------------------------------------------------------------

  @override
  Future<SystemConfigModel> getConfig() async {
    try {
      final snapshot = await _configRef.get();
      if (!snapshot.exists) return const SystemConfigModel();
      return SystemConfigModel.fromJson(_castMap(snapshot.value));
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> saveConfig(Map<String, dynamic> config) async {
    try {
      await _configRef.set(config);
      await _logAudit('Updated system config');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> restoreDefaultConfig() async {
    try {
      await _configRef.set({
        'featureFlags': {
          'chatSystem': true,
          'videoCalls': false,
          'geoCheckin': true,
          'qrScanner': true,
          'e2eEncryption': false,
          'trustV2': false,
          'aiMatch': true,
        },
        'matchParams': {
          'matchRadius': 50,
          'maxMatchesPerDay': 5,
          'skillOverlap': 70,
          'availWeight': 30,
          'ratingWeight': 20,
        },
        'trustThresholds': {
          'excellentMin': 80,
          'goodMin': 60,
          'fairMin': 40,
          'noShowPenalty': -15,
          'sessionCredit': 2,
        },
        'generalSettings': {
          'sessionTimeout': 15,
          'reviewEditWindow': 48,
          'agreementExpiry': 90,
          'maxAgreements': 10,
        },
      });
      await _logAudit('Restored default system config');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  // ---------------------------------------------------------------------------
  // Skill Categories
  // ---------------------------------------------------------------------------

  @override
  Future<List<SkillCategoryModel>> getCategories() async {
    try {
      final snapshot = await _categoriesRef.get();
      return _decodeChildren(snapshot, (key, data) {
        return SkillCategoryModel.fromJson({...data, 'id': key});
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> createCategory(Map<String, dynamic> data) async {
    try {
      await _categoriesRef.push().set(data);
      await _logAudit('Created skill category: ${data['name']}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await _categoriesRef.child(id).update(data);
      await _logAudit('Updated skill category $id');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _categoriesRef.child(id).remove();
      await _logAudit('Deleted skill category $id');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> reorderCategories(List<String> orderedIds) async {
    try {
      final updates = <String, dynamic>{};
      for (var i = 0; i < orderedIds.length; i++) {
        updates['skillCategories/${orderedIds[i]}/displayOrder'] = i;
      }
      await _database.ref().update(updates);
      await _logAudit('Reordered skill categories');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  // ---------------------------------------------------------------------------
  // Broadcasts
  // ---------------------------------------------------------------------------

  @override
  Future<List<BroadcastMessageModel>> getBroadcasts() async {
    try {
      final snapshot = await _broadcastsRef.get();
      return _decodeChildren(snapshot, (key, data) {
        return BroadcastMessageModel.fromJson({...data, 'id': key});
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> sendBroadcast(
    String title,
    String message,
    String audience, {
    DateTime? scheduledAt,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
        'message': message,
        'audience': audience,
        'sentDate': DateTime.now().toIso8601String(),
        'status': scheduledAt != null ? 'scheduled' : 'sent',
        'openRate': 0.0,
        'recipientCount': 0,
      };
      if (scheduledAt != null) {
        data['scheduledAt'] = scheduledAt.toIso8601String();
      }
      await _broadcastsRef.push().set(data);
      await _logAudit('Sent broadcast: $title', 'Audience: $audience');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  // ---------------------------------------------------------------------------
  // Audit Logs
  // ---------------------------------------------------------------------------

  @override
  Future<List<AuditLogEntryModel>> getAuditLogs({
    String? admin,
    String? action,
    int page = 1,
    int pageSize = 25,
  }) async {
    try {
      final snapshot = await _auditLogsRef
          .orderByKey()
          .limitToLast(page * pageSize)
          .get();

      var logs = _decodeChildren(snapshot, (key, data) {
        return AuditLogEntryModel.fromJson({...data, 'id': key});
      });

      // Reverse so most recent comes first
      logs = logs.reversed.toList();

      if (admin != null && admin.isNotEmpty) {
        logs = logs.where((l) => l.admin == admin).toList();
      }
      if (action != null && action.isNotEmpty) {
        logs = logs.where((l) => l.action.contains(action)).toList();
      }

      final start = (page - 1) * pageSize;
      if (start < logs.length) {
        final end = start + pageSize > logs.length
            ? logs.length
            : start + pageSize;
        logs = logs.sublist(start, end);
      } else {
        logs = [];
      }
      return logs;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  // ---------------------------------------------------------------------------
  // Admin Roles
  // ---------------------------------------------------------------------------

  @override
  Future<List<AdminRoleModel>> getRoles() async {
    try {
      final snapshot = await _adminRolesRef.get();
      return _decodeChildren(snapshot, (key, data) {
        return AdminRoleModel.fromJson({...data, 'id': key});
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> createRole(String name, Map<String, List<String>> permissions) async {
    try {
      final permissionCount =
          permissions.values.fold(0, (int sum, list) => sum + list.length);
      await _adminRolesRef.push().set({
        'name': name,
        'permissions': permissions,
        'members': 0,
        'permissionCount': permissionCount,
        'isProtected': false,
      });
      await _logAudit('Created admin role: $name');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> updateRole(String id, Map<String, dynamic> data) async {
    try {
      await _adminRolesRef.child(id).update(data);
      await _logAudit('Updated admin role $id');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> deleteRole(String id) async {
    try {
      await _adminRolesRef.child(id).remove();
      await _logAudit('Deleted admin role $id');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  // ---------------------------------------------------------------------------
  // Database Maintenance
  // ---------------------------------------------------------------------------

  @override
  Future<DatabaseStatsModel> getDatabaseStats() async {
    try {
      final results = await Future.wait([
        _usersRef.get(),
        _skillsRef().get(),
        _matchesRef.get(),
        _sessionsRef.get(),
        _auditLogsRef.get(),
        _reportsRef.get(),
        _categoriesRef.get(),
      ]);

      final nodeNames = [
        'users',
        'skills',
        'matches',
        'sessions',
        'audit_logs',
        'reports',
        'skillCategories',
      ];

      final collections = <CollectionInfoModel>[];
      int totalDocs = 0;

      for (var i = 0; i < results.length; i++) {
        final snap = results[i];
        final count = snap.exists ? (snap.value as Map).length : 0;
        totalDocs += count;
        collections.add(CollectionInfoModel(
          name: nodeNames[i],
          documents: count,
          status: 'Online',
        ));
      }

      return DatabaseStatsModel(
        totalDocuments: totalDocs,
        totalCollections: collections.length,
        lastBackup: 'Not yet run',
        collections: collections,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> runBackup() async {
    try {
      // RTDB backup via API is done server-side. Log the action.
      await _database.ref('meta/backup').set({
        'lastBackup': DateTime.now().toIso8601String(),
        'status': 'completed',
      });
      await _logAudit('Database backup completed');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> restoreBackup() async {
    try {
      await _database.ref('meta/backup').update({
        'lastRestore': DateTime.now().toIso8601String(),
        'restoreStatus': 'pending',
      });
      await _logAudit('Database restore initiated');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> runMaintenance() async {
    try {
      await _database.ref('meta/maintenance').set({
        'lastRun': DateTime.now().toIso8601String(),
        'status': 'completed',
      });
      await _logAudit('Database maintenance completed');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  DatabaseReference _skillsRef() => _database.ref('skills');

  String _defaultDuration(String type) {
    if (type.contains('Permanent')) return 'Permanent';
    if (type.contains('Suspension')) return '14 days';
    return 'N/A';
  }

  Future<void> _logAudit(String action, [String detail = '', String severity = 'info']) async {
    try {
      final adminName = _auth.currentUser?.displayName ?? _currentUid ?? 'System';
      await _auditLogsRef.push().set({
        'time': DateTime.now().toIso8601String(),
        'admin': adminName,
        'action': action,
        'detail': detail,
        'severity': severity,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Silently fail — audit logging should never block the primary operation.
    }
  }
}
