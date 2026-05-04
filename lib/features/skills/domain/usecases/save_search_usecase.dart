import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class SaveSearchUseCase {
  final SkillRepository repository;

  SaveSearchUseCase({required this.repository});

  Future<Either<Failure, void>> call(SaveSearchParams params) async {
    return repository.saveSearch(params.toMap());
  }
}

class SaveSearchParams extends Equatable {
  final String userId;
  final String query;
  final String? category;
  final String? level;
  final String? format;
  final String? type;

  const SaveSearchParams({
    required this.userId,
    required this.query,
    this.category,
    this.level,
    this.format,
    this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'query': query,
      'category': category,
      'level': level,
      'format': format,
      'type': type,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [userId, query, category, level, format, type];
}
