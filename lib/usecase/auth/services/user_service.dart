import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // In a real app, you would have a more robust user model
  Stream<Map<String, dynamic>> getUser(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      return doc.data() as Map<String, dynamic>;
    });
  }
}
