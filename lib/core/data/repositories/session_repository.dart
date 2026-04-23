import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/core/data/models/session.dart';

import 'interfaces/session_repository_interface.dart';

class SessionRepository implements SessionRepositoryInterface {
  final FirebaseFirestore _firestore;

  SessionRepository(this._firestore);

  @override
  Future<void> add(Session session) async {
    await _firestore
        .collection('sessions')
        .doc(session.sid)
        .set(session.toJson());
  }

  @override
  Future<void> delete(String sid) async {
    await _firestore.collection('sessions').doc(sid).delete();
  }

  @override
  Future<Session> get(String sid) async {
    final snapshot = await _firestore.collection('sessions').doc(sid).get();
    if (snapshot.exists) {
      return Session.fromJson(snapshot.data()!);
    } else {
      throw Exception('Session not found');
    }
  }

  @override
  Future<void> update(Session session) async {
    await _firestore
        .collection('sessions')
        .doc(session.sid)
        .update(session.toJson());
  }
}
