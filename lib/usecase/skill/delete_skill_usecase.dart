import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteSkillUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> execute(String skillId) async {
    await _firestore.collection('skills').doc(skillId).delete();
  }
}
