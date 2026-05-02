import 'package:cloud_firestore/cloud_firestore.dart';

class RequestSkillUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> execute({
    required String userId,
    required String skillName,
    required String message,
  }) async {
    await _firestore.collection('skill_requests').add({
      'userId': userId,
      'skillName': skillName,
      'message': message,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
