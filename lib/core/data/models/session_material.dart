enum SessionMaterialType { document, image, video, link, other }

class SessionMaterial {
  final String id;
  final String sessionId;
  final String name;
  final String url;
  final SessionMaterialType type;
  final String uploadedBy;
  final DateTime uploadedAt;
  final int fileSize;

  SessionMaterial({
    required this.id,
    required this.sessionId,
    required this.name,
    required this.url,
    this.type = SessionMaterialType.document,
    required this.uploadedBy,
    required this.uploadedAt,
    this.fileSize = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'name': name,
      'url': url,
      'type': type.index,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
      'fileSize': fileSize,
    };
  }

  factory SessionMaterial.fromJson(Map<String, dynamic> json) {
    return SessionMaterial(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      type: SessionMaterialType.values[json['type'] as int? ?? 0],
      uploadedBy: json['uploadedBy'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      fileSize: json['fileSize'] as int? ?? 0,
    );
  }

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
