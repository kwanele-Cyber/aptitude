import 'package:cloud_firestore/cloud_firestore.dart';

class AddSkillToProfileUseCase {
  //ReviewNotes: Please use the created in lib/core/services/firebase_service.dart to centralize all data base related logic.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //ReviewNotes: The DataSchema used here is not compatible with the model for lib/core/data/models/skill.dart
  //to query
  Future<void> execute({
    required String userId,
    required String skillName,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'skills': FieldValue.arrayUnion([skillName]),
    });
  }
}
