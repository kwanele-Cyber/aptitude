import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/core/data/repositories/skill_repository.dart';

class PostSkillUseCase {
  Future<void> execute({
    required String name,
    required String description,
    required String category,
  }) async {
    final repo = SkillRepository();

    final skill = Skill(
      name: name,
      description: description,
      category: category,
    );

    await repo.create(data: skill);
  }
}
