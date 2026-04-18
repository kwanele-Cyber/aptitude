import 'dart:js_interop';

import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/services/firebase_service.dart';

class UserRepository {
  final String path = "users";
  final firebaseService = FirebaseService();

  Future<void> create({required User user}) async {
    firebaseService.create(location: 'users/${user.uid}', data: user.toJson());
  }

  Future<User?> read(String userId) async {
    // 1. Call the service (returns DataSnapshot?)
    final snapshot = await firebaseService.read(location: 'users/$userId');

    // 2. Check if the snapshot has data
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      // 3. Cast the Object? value to a Map
      // Realtime Database returns data as Map<dynamic, dynamic>
      final Map<String, dynamic> data = snapshot.value as Map<String, dynamic>;

      // 4. Convert the Map to your User class using the factory constructor
      return User.fromJson(data);
    }

    // 5. Return null if user not found
    return null;
  }
}
