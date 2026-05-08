import 'package:myapp/features/rules/data/models/platform_rule_model.dart';

abstract class RulesRemoteDataSource {
  Future<List<PlatformRuleModel>> getPlatformRules();
}

class RulesRemoteDataSourceMock implements RulesRemoteDataSource {
  @override
  Future<List<PlatformRuleModel>> getPlatformRules() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      PlatformRuleModel(
        id: 'rule_1',
        title: 'Be Respectful',
        description:
            'Treat all members with respect and kindness. Harassment, hate speech, and discrimination will not be tolerated.',
        category: 'Conduct',
        order: 1,
      ),
      PlatformRuleModel(
        id: 'rule_2',
        title: 'Honest Communication',
        description:
            'Be transparent about your skills, availability, and intentions. Misrepresentation undermines trust in our community.',
        category: 'Conduct',
        order: 2,
      ),
      PlatformRuleModel(
        id: 'rule_3',
        title: 'No Spam or Self-Promotion',
        description:
            'Do not use the platform for unsolicited advertising, spam, or excessive self-promotion.',
        category: 'Conduct',
        order: 3,
      ),
      PlatformRuleModel(
        id: 'rule_4',
        title: 'Honor Your Commitments',
        description:
            'Show up on time for scheduled sessions and honor the agreements you make. Repeated cancellations harm the community.',
        category: 'Commitments',
        order: 4,
      ),
      PlatformRuleModel(
        id: 'rule_5',
        title: 'Keep Personal Information Safe',
        description:
            'Protect your privacy and the privacy of others. Do not share personal contact information or sensitive data.',
        category: 'Privacy',
        order: 5,
      ),
      PlatformRuleModel(
        id: 'rule_6',
        title: 'Report Violations',
        description:
            'If you see something that violates these rules, report it through the platform. We rely on community members to keep each other accountable.',
        category: 'Community',
        order: 6,
      ),
      PlatformRuleModel(
        id: 'rule_7',
        title: 'Constructive Feedback',
        description:
            'Provide constructive feedback to help others improve. Personal attacks and unconstructive criticism are not acceptable.',
        category: 'Conduct',
        order: 7,
      ),
      PlatformRuleModel(
        id: 'rule_8',
        title: 'No Unauthorized Access',
        description:
            'Do not attempt to access another user\'s account, exploit platform vulnerabilities, or interfere with platform operations.',
        category: 'Security',
        order: 8,
      ),
    ];
  }
}
