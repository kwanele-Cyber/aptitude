import 'package:myapp/features/policies/data/models/policy_acknowledgment_model.dart';
import 'package:myapp/features/policies/data/models/policy_model.dart';

abstract class PoliciesRemoteDataSource {
  Future<List<PolicyModel>> getPolicies();
  Future<List<PolicyAcknowledgmentModel>> getAcknowledgments(String userId);
  Future<void> acknowledgePolicy(
      String userId, String policyId, String version);
}

class PoliciesRemoteDataSourceMock implements PoliciesRemoteDataSource {
  @override
  Future<List<PolicyModel>> getPolicies() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      PolicyModel(
        id: 'policy_1',
        title: 'Terms of Service',
        content:
            'By using Aptitude, you agree to these Terms of Service. '
            'You are responsible for maintaining the confidentiality of your account '
            'and for all activities under your account. We reserve the right to '
            'suspend or terminate accounts that violate these terms.\n\n'
            '1. Eligibility: You must be at least 13 years old to use this platform.\n'
            '2. Account Responsibility: You are responsible for all activity on your account.\n'
            '3. Prohibited Activities: You may not use the platform for any illegal purpose.\n'
            '4. Termination: We may suspend or terminate your access at any time for violations.',
        version: '2.1',
        publishedAt: DateTime(2026, 3, 1),
        requiresAcknowledgement: true,
      ),
      PolicyModel(
        id: 'policy_2',
        title: 'Privacy Policy',
        content:
            'We take your privacy seriously. This policy describes what information '
            'we collect, how we use it, and how we protect your data.\n\n'
            '1. Information We Collect: Name, email address, skills, ratings, and usage data.\n'
            '2. How We Use Your Data: To match you with skill partners, process transactions, '
            'and improve our services.\n'
            '3. Data Sharing: We do not sell your personal data to third parties.\n'
            '4. Data Retention: We retain your data for as long as your account is active.\n'
            '5. Your Rights: You may request access, correction, or deletion of your data.',
        version: '2.0',
        publishedAt: DateTime(2026, 1, 15),
        requiresAcknowledgement: true,
      ),
      PolicyModel(
        id: 'policy_3',
        title: 'Code of Conduct',
        content:
            'All users are expected to adhere to our Code of Conduct to maintain '
            'a positive and productive community.\n\n'
            '1. Respect: Treat all members with dignity and respect.\n'
            '2. Integrity: Be honest about your skills and availability.\n'
            '3. Collaboration: Foster a spirit of mutual learning and growth.\n'
            '4. Accountability: Take responsibility for your actions and commitments.\n'
            '5. Inclusivity: Embrace diversity and make everyone feel welcome.',
        version: '1.5',
        publishedAt: DateTime(2025, 11, 1),
        requiresAcknowledgement: false,
      ),
    ];
  }

  @override
  Future<List<PolicyAcknowledgmentModel>> getAcknowledgments(
      String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  @override
  Future<void> acknowledgePolicy(
      String userId, String policyId, String version) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
