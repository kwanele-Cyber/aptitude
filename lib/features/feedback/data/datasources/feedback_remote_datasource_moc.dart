import 'package:myapp/features/feedback/data/models/feedback_model.dart';
import 'package:myapp/features/feedback/data/datasources/feedback_remote_datasource.dart';

class FeedbackRemoteDataSourceMock implements FeedbackRemoteDataSource {
  @override
  Future<void> createFeedback(FeedbackModel feedback) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> updateFeedback(String feedbackId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<FeedbackModel?> getFeedback(String feedbackId) async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  @override
  Future<List<FeedbackModel>> fetchFeedbacksForUser(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<List<FeedbackModel>> fetchFeedbackBySession(String sessionId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}
