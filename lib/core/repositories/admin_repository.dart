import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/models/agreement_model.dart';
import 'package:myapp/core/services/base_database_service.dart';

abstract class AdminRepository {
  Future<List<UserModel>> getAllUsers();
  Future<List<AgreementModel>> getAllAgreements();
  Future<void> deleteUser(String uid);
  Future<void> updateUserRole(String uid, UserRole role);
  Future<void> toggleUserSuspension(String uid, bool isSuspended);
}

class AdminRepositoryImpl extends BaseDatabaseService implements AdminRepository {
  AdminRepositoryImpl({super.database, super.pathPrefix});

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await getData('users');
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> usersMap = snapshot.value as Map;
        return usersMap.entries.map((e) {
          return UserModel.fromJson(Map<String, dynamic>.from(e.value as Map));
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<AgreementModel>> getAllAgreements() async {
    try {
      final snapshot = await getData('agreements');
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> agreementsMap = snapshot.value as Map;
        return agreementsMap.entries.map((e) {
          return AgreementModel.fromJson(Map<String, dynamic>.from(e.value as Map));
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    await deleteData('users/$uid');
  }

  @override
  Future<void> updateUserRole(String uid, UserRole role) async {
    await updateData(
      path: 'users/$uid',
      data: {'role': role.name},
    );
  }

  @override
  Future<void> toggleUserSuspension(String uid, bool isSuspended) async {
    await updateData(
      path: 'users/$uid',
      data: {'isSuspended': isSuspended},
    );
  }
}
