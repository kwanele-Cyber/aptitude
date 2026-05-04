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
  Future<void> deleteAccount();
  Future<void> resendVerificationEmail();
  Future<bool> verify2FAPin(String uid, String pin);
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<List<String>> generateRecoveryCodes();
  Future<void> recoverAccount(String email, String recoveryCode);
  Future<UserModel> getUserProfile(String uid);
}

class AuthRemoteDataSourceMock implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    Future.delayed(Duration(seconds: 1));

    if (email == "test@test.com" && password == "password") {
      return UserModel(id: "1", firstName: "Test", lastName: "User", email: "testuser@test.com");
    } else {
      throw InvalidCredentialsException();
    }
  }

  @override
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    Future.delayed(Duration(seconds: 1));

    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
  }

  @override
  Future<void> logout() async {
    Future.delayed(Duration(seconds: 1));
  }

  @override
  Future<void> resetPassword(String email) async {
    Future.delayed(Duration(seconds: 1));
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    Future.delayed(Duration(seconds: 1));
  }

  @override
  Future<void> deleteAccount() async {
    Future.delayed(Duration(seconds: 1));
  }

  @override
  Future<void> resendVerificationEmail() async {
    Future.delayed(Duration(seconds: 1));
  }

  @override
  Future<bool> verify2FAPin(String uid, String pin) async {
    Future.delayed(Duration(seconds: 1));
    return pin == '123456';
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    Future.delayed(Duration(seconds: 1));
    return UserModel(
      id: (data['uid'] as String?) ?? '1',
      firstName: (data['firstName'] as String?) ?? 'Test',
      lastName: (data['lastName'] as String?) ?? 'User',
      email: (data['email'] as String?) ?? 'test@test.com',
      phone: data['phone'] as String?,
      twoFactorEnabled: (data['twoFactorEnabled'] as bool?) ?? false,
      twoFactorPin: data['twoFactorPin'] as String?,
    );
  }

  @override
  Future<List<String>> generateRecoveryCodes() async {
    Future.delayed(Duration(seconds: 1));
    return List.generate(10, (i) => 'RECOVERY_CODE_$i');
  }

  @override
  Future<void> recoverAccount(String email, String recoveryCode) async {
    Future.delayed(Duration(seconds: 1));
    if (recoveryCode != 'VALID_CODE') {
      throw InvalidCredentialsException();
    }
  }

  @override
  Future<UserModel> getUserProfile(String uid) async {
    Future.delayed(Duration(seconds: 1));
    return UserModel(
      id: uid,
      firstName: 'Test',
      lastName: 'User',
      email: 'test@test.com',
    );
  }
}
