import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/disputes/data/models/dispute_model.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';

void main() {
  group('DisputeModel', () {
    final json = {
      'type': 'report',
      'reporterId': 'user1',
      'reporterName': 'Alice',
      'reportedUserId': 'user2',
      'reportedUserName': 'Bob',
      'respondentId': null,
      'agreementId': null,
      'sessionId': null,
      'reason': 'Harassment',
      'description': 'Inappropriate messages',
      'evidenceUrls': ['https://example.com/evidence1'],
      'status': 'pending',
      'resolution': null,
      'resolvedBy': null,
      'resolvedAt': null,
      'appealReason': null,
      'appealDecision': null,
      'appealedAt': null,
      'appealDecisionAt': null,
      'createdAt': '2024-01-15T10:00:00.000',
      'updatedAt': '2024-01-15T10:00:00.000',
    };

    test('fromJson should parse correctly', () {
      final model = DisputeModel.fromJson('dispute1', json);

      expect(model.id, 'dispute1');
      expect(model.type, DisputeType.report);
      expect(model.reporterId, 'user1');
      expect(model.reporterName, 'Alice');
      expect(model.reportedUserId, 'user2');
      expect(model.reportedUserName, 'Bob');
      expect(model.reason, 'Harassment');
      expect(model.description, 'Inappropriate messages');
      expect(model.evidenceUrls, ['https://example.com/evidence1']);
      expect(model.status, DisputeStatus.pending);
      expect(model.createdAt, DateTime(2024, 1, 15, 10, 0));
    });

    test('fromJson should handle dispute type', () {
      final disputeJson = Map<String, dynamic>.from(json)
        ..['type'] = 'dispute'
        ..['respondentId'] = 'user3'
        ..['agreementId'] = 'agreement1';

      final model = DisputeModel.fromJson('dispute2', disputeJson);

      expect(model.type, DisputeType.dispute);
      expect(model.respondentId, 'user3');
      expect(model.agreementId, 'agreement1');
    });

    test('fromJson should handle resolved status', () {
      final resolvedJson = Map<String, dynamic>.from(json)
        ..['status'] = 'resolved'
        ..['resolution'] = 'Resolved amicably'
        ..['resolvedBy'] = 'admin1'
        ..['resolvedAt'] = '2024-01-16T10:00:00.000';

      final model = DisputeModel.fromJson('dispute3', resolvedJson);

      expect(model.status, DisputeStatus.resolved);
      expect(model.resolution, 'Resolved amicably');
      expect(model.resolvedBy, 'admin1');
      expect(model.resolvedAt, DateTime(2024, 1, 16, 10, 0));
    });

    test('fromJson should handle appealed status', () {
      final appealedJson = Map<String, dynamic>.from(json)
        ..['status'] = 'appealed'
        ..['appealReason'] = 'Unfair decision'
        ..['appealedAt'] = '2024-01-17T10:00:00.000';

      final model = DisputeModel.fromJson('dispute4', appealedJson);

      expect(model.status, DisputeStatus.appealed);
      expect(model.appealReason, 'Unfair decision');
      expect(model.appealedAt, DateTime(2024, 1, 17, 10, 0));
    });

    test('fromJson should default missing values', () {
      final minimalJson = <String, dynamic>{};

      final model = DisputeModel.fromJson('dispute5', minimalJson);

      expect(model.id, 'dispute5');
      expect(model.type, DisputeType.report);
      expect(model.reporterId, '');
      expect(model.reporterName, '');
      expect(model.reason, '');
      expect(model.description, '');
      expect(model.evidenceUrls, []);
      expect(model.status, DisputeStatus.pending);
    });

    test('toJson should serialize correctly', () {
      final model = DisputeModel.fromJson('dispute1', json);
      final serialized = model.toJson();

      expect(serialized['type'], 'report');
      expect(serialized['reporterId'], 'user1');
      expect(serialized['reason'], 'Harassment');
      expect(serialized['status'], 'pending');
      expect(serialized['evidenceUrls'], ['https://example.com/evidence1']);
      expect(serialized['createdAt'], '2024-01-15T10:00:00.000');
    });
  });
}
