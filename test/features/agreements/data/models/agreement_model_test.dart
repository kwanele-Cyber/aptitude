import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/agreements/data/models/agreement_model.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';

void main() {
  group('AgreementModel', () {
    final tModel = AgreementModel(
      id: 'agreement1',
      initiatorId: 'user1',
      initiatorName: 'User One',
      partnerId: 'user2',
      partnerName: 'User Two',
      initiatorSkillId: 'skill1',
      initiatorSkillTitle: 'Flutter',
      partnerSkillId: 'skill2',
      partnerSkillTitle: 'Photography',
      status: AgreementStatus.pending,
      duration: '4 weeks',
      frequency: '1x/week',
      sessionsCount: 4,
      notes: 'Test notes',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

    test('fromJson should parse correctly', () {
      final json = {
        'initiatorId': 'user1',
        'initiatorName': 'User One',
        'partnerId': 'user2',
        'partnerName': 'User Two',
        'initiatorSkillId': 'skill1',
        'initiatorSkillTitle': 'Flutter',
        'partnerSkillId': 'skill2',
        'partnerSkillTitle': 'Photography',
        'status': 'pending',
        'duration': '4 weeks',
        'frequency': '1x/week',
        'sessionsCount': 4,
        'notes': 'Test notes',
        'createdAt': '2025-01-01T00:00:00.000',
        'updatedAt': '2025-01-01T00:00:00.000',
        'modifiedBy': null,
        'cancelledBy': null,
        'cancelledAt': null,
      };

      final model = AgreementModel.fromJson('agreement1', json);

      expect(model.id, 'agreement1');
      expect(model.initiatorId, 'user1');
      expect(model.initiatorName, 'User One');
      expect(model.partnerId, 'user2');
      expect(model.partnerName, 'User Two');
      expect(model.initiatorSkillId, 'skill1');
      expect(model.initiatorSkillTitle, 'Flutter');
      expect(model.partnerSkillId, 'skill2');
      expect(model.partnerSkillTitle, 'Photography');
      expect(model.status, AgreementStatus.pending);
      expect(model.duration, '4 weeks');
      expect(model.frequency, '1x/week');
      expect(model.sessionsCount, 4);
      expect(model.notes, 'Test notes');
      expect(model.createdAt, DateTime(2025, 1, 1));
      expect(model.updatedAt, DateTime(2025, 1, 1));
      expect(model.modifiedBy, null);
      expect(model.cancelledBy, null);
      expect(model.cancelledAt, null);
    });

    test('fromJson should handle null/missing fields', () {
      final json = <String, dynamic>{};

      final model = AgreementModel.fromJson('agreement1', json);

      expect(model.id, 'agreement1');
      expect(model.initiatorId, '');
      expect(model.initiatorName, '');
      expect(model.status, AgreementStatus.pending);
      expect(model.sessionsCount, 1);
      expect(model.notes, null);
    });

    test('fromJson should parse all statuses', () {
      for (final status in AgreementStatus.values) {
        final json = {
          'initiatorId': 'u1',
          'initiatorName': 'U1',
          'partnerId': 'u2',
          'partnerName': 'U2',
          'initiatorSkillId': 's1',
          'initiatorSkillTitle': 'S1',
          'partnerSkillId': 's2',
          'partnerSkillTitle': 'S2',
          'status': status.name,
          'duration': '4 weeks',
          'frequency': '1x/week',
          'sessionsCount': 4,
          'createdAt': '2025-01-01T00:00:00.000',
          'updatedAt': '2025-01-01T00:00:00.000',
        };

        final model = AgreementModel.fromJson('agreement1', json);
        expect(model.status, status);
      }
    });

    test('fromJson should fallback to pending for invalid status', () {
      final json = {
        'initiatorId': 'u1',
        'initiatorName': 'U1',
        'partnerId': 'u2',
        'partnerName': 'U2',
        'initiatorSkillId': 's1',
        'initiatorSkillTitle': 'S1',
        'partnerSkillId': 's2',
        'partnerSkillTitle': 'S2',
        'status': 'invalid_status',
        'duration': '4 weeks',
        'frequency': '1x/week',
        'sessionsCount': 4,
        'createdAt': '2025-01-01T00:00:00.000',
        'updatedAt': '2025-01-01T00:00:00.000',
      };

      final model = AgreementModel.fromJson('agreement1', json);
      expect(model.status, AgreementStatus.pending);
    });

    test('toJson should produce correct map', () {
      final json = tModel.toJson();

      expect(json['initiatorId'], 'user1');
      expect(json['initiatorName'], 'User One');
      expect(json['status'], 'pending');
      expect(json['duration'], '4 weeks');
      expect(json['frequency'], '1x/week');
      expect(json['sessionsCount'], 4);
      expect(json['notes'], 'Test notes');
      expect(json['createdAt'], '2025-01-01T00:00:00.000');
      expect(json['modifiedBy'], null);
      expect(json['cancelledAt'], null);
    });

    test('toJson should include cancelled fields when set', () {
      final cancelledModel = AgreementModel(
        id: 'agreement1',
        initiatorId: 'user1',
        initiatorName: 'User One',
        partnerId: 'user2',
        partnerName: 'User Two',
        initiatorSkillId: 'skill1',
        initiatorSkillTitle: 'Flutter',
        partnerSkillId: 'skill2',
        partnerSkillTitle: 'Photography',
        status: AgreementStatus.cancelled,
        duration: '4 weeks',
        frequency: '1x/week',
        sessionsCount: 4,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 2),
        cancelledBy: 'user1',
        cancelledAt: DateTime(2025, 1, 2),
      );

      final json = cancelledModel.toJson();

      expect(json['status'], 'cancelled');
      expect(json['cancelledBy'], 'user1');
      expect(json['cancelledAt'], '2025-01-02T00:00:00.000');
    });
  });
}
