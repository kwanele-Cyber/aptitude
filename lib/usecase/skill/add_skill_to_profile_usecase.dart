import 'package:cloud_firestore/cloud_firestore.dart';

class AddSkillToProfileUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> execute({
    required String userId,
    required String skillName,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'skills': FieldValue.arrayUnion([skillName]),
    });
  }
}
