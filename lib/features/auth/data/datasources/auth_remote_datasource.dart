import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<void> updatePassword(String newPassword);
  Future<void> changePassword(String email, String oldPassword, String newPassword);
  Future<void> deleteAccount();
  Future<void> resendVerificationEmail();
  Future<bool> verify2FAPin(String uid, String pin);
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<List<String>> generateRecoveryCodes();
  Future<void> recoverAccount(String email, String recoveryCode);
  Future<UserModel> getUserProfile(String uid);
  Future<Map<String, dynamic>> exportUserData();
}

