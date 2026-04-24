import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get onAuthStateChanged;
  Future<UserModel> signUpWithEmail({required String email, required String password, required String displayName});
  Future<UserModel> signInWithEmail({required String email, required String password});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> updateUser(UserModel user);
}
