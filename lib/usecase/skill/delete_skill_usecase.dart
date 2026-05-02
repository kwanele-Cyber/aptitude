import 'package:myapp/core/data/repositories/user_repository.dart';

class DeleteSkillUseCase {
  Future<void> execute({
    required String userId,
    required String skillName,
  }) async {
    final userRepo = UserRepository();

    final user = await userRepo.read(userId);

    if (user == null) throw Exception("User not found");

    user.skills.remove(skillName);

    await userRepo.update(user.uid, user.toJson(), location: '', data: {});
  }
}
