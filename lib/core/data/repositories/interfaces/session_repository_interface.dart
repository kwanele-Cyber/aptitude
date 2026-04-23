
import '../../models/session.dart';

abstract class SessionRepositoryInterface {
  Future<void> add(Session session);
  Future<Session> get(String sid);
  Future<void> update(Session session);
  Future<void> delete(String sid);
}
