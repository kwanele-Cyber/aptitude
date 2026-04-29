enum ProofType { certification, portfolio, project, workExperience }

class SkillProof {
  final String id;
  final ProofType type;
  final String title;
  final String? issuer; // Only for certifications
  final String? url;
  final DateTime? issueDate;
  final String? credentialId;

  SkillProof({
    required this.id,
    required this.type,
    required this.title,
    this.issuer,
    this.url,
    this.issueDate,
    this.credentialId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'issuer': issuer,
      'url': url,
      'issueDate': issueDate?.toIso8601String(),
      'credentialId': credentialId,
    };
  }

  factory SkillProof.fromJson(Map<String, dynamic> json) {
    return SkillProof(
      id: json['id'] as String,
      type: ProofType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'] as String,
      issuer: json['issuer'] as String?,
      url: json['url'] as String?,
      issueDate: json['issueDate'] != null ? DateTime.parse(json['issueDate'] as String) : null,
      credentialId: json['credentialId'] as String?,
    );
  }
}
