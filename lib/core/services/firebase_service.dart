import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class FirebaseService implements IDatabaseService<DataSnapshot> {
  final _firebaseDatabase = FirebaseDatabase.instance;

  DatabaseReference _getReference(String path) {
    return _firebaseDatabase.ref().child(path);
  }

  @override
  Future<void> create({
    required String location,
    required Map<String, dynamic> data,
  }) async {
    await _getReference(location).set(data);
  }

  @override
  Future<void> delete({required String location}) async {
    await _getReference(location).remove();
  }

  @override
  Future<DataSnapshot?> read({required String location}) async {
    final DataSnapshot data = await _getReference(location).ref.get();

    return data;
  }

  @override
  Future<void> update({
    required String location,
    required Map<String, dynamic> data,
  }) async {
    await _getReference(location).update(data);
  }
}
