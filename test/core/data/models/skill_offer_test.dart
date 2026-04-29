import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/data/models/skill_offer.dart';
import 'package:myapp/core/data/models/skill_proof.dart';
import 'package:myapp/core/data/models/saved_search.dart';

void main() {
  group('SkillOffer Schema Tests', () {
    test('toJson should correctly serialize structured proofs', () {
      final proof = SkillProof(
        id: 'p1',
        type: ProofType.certification,
        title: 'AWS Certified',
        issuer: 'Amazon',
        url: 'https://aws.com/cert',
      );

      final offer = SkillOffer(
        uid: 'user123',
        sid: 'flutter-dev',
        skillName: 'Flutter',
        level: SkillLevel.expert,
        format: SkillFormat.hybrid,
        description: 'Test description',
        proofs: [proof],
        yearsOfExperience: 5,
      );

      final json = offer.toJson();

      expect(json['uid'], 'user123');
      expect(json['proofs'], isA<List>());
      expect(json['proofs'][0]['title'], 'AWS Certified');
      expect(json['proofs'][0]['type'], 'certification');
      expect(json['yearsOfExperience'], 5);
    });

    test('fromJson should correctly deserialize structured proofs and enums', () {
      final json = {
        'id': 'off123',
        'uid': 'user123',
        'sid': 'flutter-dev',
        'skillName': 'Flutter',
        'level': 'expert',
        'format': 'hybrid',
        'description': 'Test',
        'proofs': [
          {
            'id': 'p1',
            'type': 'certification',
            'title': 'AWS Certified',
            'issuer': 'Amazon',
          }
        ],
        'yearsOfExperience': 5,
        'isVerified': true,
        'isArchived': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final offer = SkillOffer.fromJson(json);

      expect(offer.level, SkillLevel.expert);
      expect(offer.format, SkillFormat.hybrid);
      expect(offer.proofs.length, 1);
      expect(offer.proofs[0].type, ProofType.certification);
      expect(offer.isVerified, true);
    });

    test('copyWith should allow updating proofs and experience', () {
      final offer = SkillOffer(
        uid: 'u1',
        sid: 's1',
        skillName: 'Name',
        level: SkillLevel.beginner,
        format: SkillFormat.online,
        description: 'Desc',
      );

      final updated = offer.copyWith(
        yearsOfExperience: 10,
        isVerified: true,
      );

      expect(updated.yearsOfExperience, 10);
      expect(updated.isVerified, true);
      expect(updated.uid, 'u1'); // Preserved
    });
  group('SavedSearch Schema Tests', () {
    test('toJson and fromJson should handle Enum Sets correctly', () {
      final search = SavedSearch(
        id: 's1',
        name: 'My Search',
        query: 'Flutter',
        levels: {SkillLevel.expert, SkillLevel.intermediate},
        formats: {SkillFormat.online},
      );

      final json = search.toJson();
      expect(json['levels'], containsAll(['expert', 'intermediate']));

      final recovered = SavedSearch.fromJson(json);
      expect(recovered.levels, containsAll([SkillLevel.expert, SkillLevel.intermediate]));
      expect(recovered.formats, contains(SkillFormat.online));
    });
  });
  });
}
