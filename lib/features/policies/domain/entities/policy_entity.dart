class PolicyEntity {
  final String id;
  final String title;
  final String content;
  final String version;
  final DateTime publishedAt;
  final bool requiresAcknowledgement;

  const PolicyEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.version,
    required this.publishedAt,
    required this.requiresAcknowledgement,
  });
}
