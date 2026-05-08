class PolicyAcknowledgmentEntity {
  final String policyId;
  final DateTime acknowledgedAt;
  final String version;

  const PolicyAcknowledgmentEntity({
    required this.policyId,
    required this.acknowledgedAt,
    required this.version,
  });
}
