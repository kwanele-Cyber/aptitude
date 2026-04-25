import 'package:cloud_firestore/cloud_firestore.dart';

class EditSkillUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> execute({
    required String skillId,
    required String newSkillName,
    required String newDescription,
  }) async {
    await _firestore.collection('skills').doc(skillId).update({
      'skillName': newSkillName,
      'description': newDescription,
    });
  }
}
