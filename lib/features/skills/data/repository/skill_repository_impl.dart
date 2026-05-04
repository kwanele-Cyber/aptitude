import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/data/datasources/skill_remote_datasource.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/entity/saved_search_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class SkillRepositoryImpl implements SkillRepository {
  final SkillRemoteDataSource remoteDataSource;

  SkillRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SkillEntity>> createSkill(
      Map<String, dynamic> data) async {
    try {
      final skill = await remoteDataSource.createSkill(data);
      return Right(skill);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SkillEntity>> updateSkill(
      String id, Map<String, dynamic> data) async {
    try {
      final skill = await remoteDataSource.updateSkill(id, data);
      return Right(skill);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteSkill(String id) async {
    try {
      await remoteDataSource.deleteSkill(id);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SkillEntity>>> fetchUserSkills(
      String uid) async {
    try {
      final skills = await remoteDataSource.fetchUserSkills(uid);
      return Right(skills);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SkillEntity>> getSkillById(String id) async {
    try {
      final skill = await remoteDataSource.getSkillById(id);
      return Right(skill);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> archiveSkill(String id) async {
    try {
      await remoteDataSource.archiveSkill(id);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> restoreSkill(String id) async {
    try {
      await remoteDataSource.restoreSkill(id);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveSearch(Map<String, dynamic> data) async {
    try {
      await remoteDataSource.saveSearch(data);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SavedSearchEntity>>> fetchSavedSearches(
      String uid) async {
    try {
      final searches = await remoteDataSource.fetchSavedSearches(uid);
      return Right(searches);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteSavedSearch(String id) async {
    try {
      await remoteDataSource.deleteSavedSearch(id);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SkillEntity>>> searchSkills(
      String query) async {
    try {
      final skills = await remoteDataSource.searchSkills(query);
      return Right(skills);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SkillEntity>>> fetchAllSkills() async {
    try {
      final skills = await remoteDataSource.fetchAllSkills();
      return Right(skills);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
