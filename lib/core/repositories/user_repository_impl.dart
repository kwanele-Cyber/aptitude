import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/services/base_database_service.dart';
import 'package:myapp/core/repositories/user_repository.dart';

class UserRepositoryImpl extends BaseDatabaseService implements UserRepository {
  UserRepositoryImpl({super.database, super.pathPrefix});
  
  @override
  Future<UserModel?> getUser(String uid) async {
    try {
      final snapshot = await getData('users/$uid');
      if (snapshot.exists && snapshot.value != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await setData(path: 'users/${user.uid}', data: user.toJson());
  }
}

