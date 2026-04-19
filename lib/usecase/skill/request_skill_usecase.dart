import 'package:cloud_firestore/cloud_firestore.dart';

class RequestSkillUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> execute({
    required String userId,
    required String skillName,
  }) async {
    await _firestore.collection('skill_requests').add({
      'userId': userId,
      'skillName': skillName,
      'requestedAt': Timestamp.now(),
    });
  }
}
