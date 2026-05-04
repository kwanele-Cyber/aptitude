import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceMock implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    Future.delayed(Duration(seconds: 1));

    if (email == "test@test.com" && password == "password") {
      return UserModel(id: "1", name: "Test User", email: "testuser@test.com");
    } else {
      throw InvalidCredentialsException();
    }
  }

  @override
  Future<void> logout() async {
    Future.delayed(Duration(seconds: 1));
  }
}
