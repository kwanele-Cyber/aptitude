import 'package:myapp/features/feedback/data/models/feedback_model.dart';

abstract class FeedbackRemoteDataSource {
  Future<void> createFeedback(FeedbackModel feedback);
  Future<void> updateFeedback(String feedbackId, Map<String, dynamic> data);
  Future<FeedbackModel?> getFeedback(String feedbackId);
  Future<List<FeedbackModel>> fetchFeedbacksForUser(String userId);
  Future<List<FeedbackModel>> fetchFeedbackBySession(String sessionId);
}

