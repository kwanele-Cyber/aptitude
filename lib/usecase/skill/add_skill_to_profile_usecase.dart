import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/core/data/repositories/skill_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';

class AddSkillToProfileUseCase {
  Future<void> execute({
    required String userId,
    required String skillName,
    required String description,
    required String category,
  }) async {
    final skillRepo = SkillRepository();
    final userRepo = UserRepository();

    final skill = Skill(
      name: skillName,
      description: description,
      category: category,
    );

    await skillRepo.create(data: skill);

    final user = await userRepo.read(userId);

    if (user == null) throw Exception("User not found");

    user.skills.add(skill.sid);

    await userRepo.update(user.uid, user.toJson(), location: '', data: {});
  }
}
