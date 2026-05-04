import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/auth/domain/entity/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> isAuthenticated();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> updatePassword(String newPassword);
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, void>> resendVerificationEmail();
  Future<Either<Failure, bool>> verify2FAPin(String uid, String pin);
  Future<Either<Failure, UserEntity>> updateProfile(Map<String, dynamic> data);
  Future<Either<Failure, List<String>>> generateRecoveryCodes();
  Future<Either<Failure, void>> recoverAccount(String email, String recoveryCode);
  Future<Either<Failure, UserEntity>> getUserProfile(String uid);
}
