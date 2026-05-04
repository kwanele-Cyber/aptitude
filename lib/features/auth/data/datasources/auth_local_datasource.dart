import 'dart:convert';

import 'package:myapp/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<void> cacheUser(UserModel user);
  Future<String?> getCachedToken();
  Future<UserModel?> getCachedUser();
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedToken = "CACHED_TOKEN";
  static const String cachedUser = "CACHED_USER";

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(cachedToken, token);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(cachedUser, json.encode(user.toJson()));
  }

  @override
  Future<String?> getCachedToken() async {
    return sharedPreferences.getString(cachedToken);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = sharedPreferences.getString(cachedUser);
    UserModel? user;

    if (jsonString != null) {
      user = UserModel.fromJson(json.decode(jsonString));
    }

    return user;
  }

  @override
  Future<void> clearToken() async {
    await sharedPreferences.remove(cachedUser);
    await sharedPreferences.remove(cachedToken);
  }
}
