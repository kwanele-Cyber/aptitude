import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:myapp/features/feedback/data/models/feedback_model.dart';

class FeedbackRemoteDataSourceFirebase implements FeedbackRemoteDataSource {
  final FirebaseDatabase _database;

  FeedbackRemoteDataSourceFirebase({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _feedbacksRef => _database.ref('feedbacks');

  @override
  Future<void> createFeedback(FeedbackModel feedback) async {
    try {
      await _feedbacksRef.child(feedback.id).set(feedback.toJson());
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateFeedback(
      String feedbackId, Map<String, dynamic> data) async {
    try {
      await _feedbacksRef.child(feedbackId).update(data);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<FeedbackModel?> getFeedback(String feedbackId) async {
    try {
      final snapshot = await _feedbacksRef.child(feedbackId).get();
      if (!snapshot.exists) return null;

      final data =
          Map<String, dynamic>.from(snapshot.value as Map);
      return FeedbackModel.fromJson(feedbackId, data);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<FeedbackModel>> fetchFeedbacksForUser(String userId) async {
    try {
      final snapshot = await _feedbacksRef
          .orderByChild('revieweeId')
          .equalTo(userId)
          .get();

      if (!snapshot.exists) return [];

      final feedbacks = <FeedbackModel>[];
      final map = snapshot.value is Map
          ? Map<String, dynamic>.from(snapshot.value as Map)
          : null;

      if (map != null) {
        map.forEach((key, value) {
          feedbacks.add(FeedbackModel.fromJson(
              key, Map<String, dynamic>.from(value as Map)));
        });
      }

      feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return feedbacks;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<FeedbackModel>> fetchFeedbackBySession(String sessionId) async {
    try {
      final snapshot = await _feedbacksRef
          .orderByChild('sessionId')
          .equalTo(sessionId)
          .get();

      if (!snapshot.exists) return [];

      final feedbacks = <FeedbackModel>[];
      final map = snapshot.value is Map
          ? Map<String, dynamic>.from(snapshot.value as Map)
          : null;

      if (map != null) {
        map.forEach((key, value) {
          feedbacks.add(FeedbackModel.fromJson(
              key, Map<String, dynamic>.from(value as Map)));
        });
      }

      feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return feedbacks;
    } catch (e) {
      throw ServerException();
    }
  }
}
