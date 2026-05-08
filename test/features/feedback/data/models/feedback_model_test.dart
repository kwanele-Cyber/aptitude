import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/feedback/data/models/feedback_model.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';

void main() {
  group('FeedbackModel', () {
    final tJson = {
      'sessionId': 'session1',
      'reviewerId': 'reviewer1',
      'reviewerName': 'Alice',
      'revieweeId': 'reviewee1',
      'revieweeName': 'Bob',
      'rating': 4,
      'review': 'Great session!',
      'response': 'Thank you!',
      'respondedAt': '2024-01-16T12:00:00.000',
      'createdAt': '2024-01-15T10:00:00.000',
      'updatedAt': '2024-01-16T12:00:00.000',
    };

    test('fromJson should return a valid model', () {
      final model = FeedbackModel.fromJson('feedback1', tJson);

      expect(model.id, 'feedback1');
      expect(model.sessionId, 'session1');
      expect(model.reviewerId, 'reviewer1');
      expect(model.reviewerName, 'Alice');
      expect(model.revieweeId, 'reviewee1');
      expect(model.revieweeName, 'Bob');
      expect(model.rating, 4);
      expect(model.review, 'Great session!');
      expect(model.response, 'Thank you!');
      expect(model.respondedAt, DateTime(2024, 1, 16, 12, 0));
      expect(model.createdAt, DateTime(2024, 1, 15, 10, 0));
      expect(model.updatedAt, DateTime(2024, 1, 16, 12, 0));
    });

    test('fromJson should handle missing optional fields', () {
      final minimalJson = {
        'sessionId': 'session1',
        'reviewerId': 'reviewer1',
        'reviewerName': 'Alice',
        'revieweeId': 'reviewee1',
        'revieweeName': 'Bob',
        'rating': 5,
        'createdAt': '2024-01-15T10:00:00.000',
        'updatedAt': '2024-01-15T10:00:00.000',
      };

      final model = FeedbackModel.fromJson('feedback1', minimalJson);

      expect(model.id, 'feedback1');
      expect(model.rating, 5);
      expect(model.review, isNull);
      expect(model.response, isNull);
      expect(model.respondedAt, isNull);
    });

    test('toJson should return a valid JSON map', () {
      final model = FeedbackModel(
        id: 'feedback1',
        sessionId: 'session1',
        reviewerId: 'reviewer1',
        reviewerName: 'Alice',
        revieweeId: 'reviewee1',
        revieweeName: 'Bob',
        rating: 4,
        review: 'Great session!',
        response: 'Thank you!',
        respondedAt: DateTime(2024, 1, 16, 12, 0),
        createdAt: DateTime(2024, 1, 15, 10, 0),
        updatedAt: DateTime(2024, 1, 16, 12, 0),
      );

      final json = model.toJson();

      expect(json['sessionId'], 'session1');
      expect(json['reviewerId'], 'reviewer1');
      expect(json['reviewerName'], 'Alice');
      expect(json['revieweeId'], 'reviewee1');
      expect(json['revieweeName'], 'Bob');
      expect(json['rating'], 4);
      expect(json['review'], 'Great session!');
      expect(json['response'], 'Thank you!');
      expect(json['respondedAt'], '2024-01-16T12:00:00.000');
      expect(json['createdAt'], '2024-01-15T10:00:00.000');
      expect(json['updatedAt'], '2024-01-16T12:00:00.000');
    });

    test('toJson should omit null optional fields', () {
      final model = FeedbackModel(
        id: 'feedback1',
        sessionId: 'session1',
        reviewerId: 'reviewer1',
        reviewerName: 'Alice',
        revieweeId: 'reviewee1',
        revieweeName: 'Bob',
        rating: 5,
        createdAt: DateTime(2024, 1, 15, 10, 0),
        updatedAt: DateTime(2024, 1, 15, 10, 0),
      );

      final json = model.toJson();

      expect(json['review'], isNull);
      expect(json['response'], isNull);
      expect(json['respondedAt'], isNull);
    });

    test('fromJson should clamp rating to 1-5', () {
      final highJson = {...tJson, 'rating': 10};
      final model = FeedbackModel.fromJson('f1', highJson);
      expect(model.rating, 5);

      final lowJson = {...tJson, 'rating': 0};
      final lowModel = FeedbackModel.fromJson('f2', lowJson);
      expect(lowModel.rating, 1);
    });

    test('fromJson should handle missing rating', () {
      final json = Map<String, dynamic>.from(tJson)..remove('rating');
      final model = FeedbackModel.fromJson('f1', json);
      expect(model.rating, 1);
    });

    test('fromJson should handle double rating', () {
      final json = {...tJson, 'rating': 4.7};
      final model = FeedbackModel.fromJson('f1', json);
      expect(model.rating, 5);
    });

    test('FeedbackEntity canEditReview returns true within 48 hours', () {
      final entity = FeedbackEntity(
        id: 'f1',
        sessionId: 's1',
        reviewerId: 'r1',
        reviewerName: 'A',
        revieweeId: 'r2',
        revieweeName: 'B',
        rating: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now(),
      );

      expect(entity.canEditReview, isTrue);
    });

    test('FeedbackEntity canEditReview returns false after 48 hours', () {
      final entity = FeedbackEntity(
        id: 'f1',
        sessionId: 's1',
        reviewerId: 'r1',
        reviewerName: 'A',
        revieweeId: 'r2',
        revieweeName: 'B',
        rating: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 49)),
        updatedAt: DateTime.now(),
      );

      expect(entity.canEditReview, isFalse);
    });
  });
}
