import 'package:cloud_firestore/cloud_firestore.dart';

class PostSkillUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> execute({
    required String userId,
    required String skillName,
    required String description,
  }) async {
    await _firestore.collection('skills').add({
      'userId': userId,
      'skillName': skillName,
      'description': description,
      'createdAt': Timestamp.now(),
    });
  }
}
