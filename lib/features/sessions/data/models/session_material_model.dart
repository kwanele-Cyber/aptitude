import 'package:myapp/features/sessions/domain/entity/session_material_entity.dart';

class SessionMaterialModel extends SessionMaterialEntity {
  const SessionMaterialModel({
    required super.id,
    required super.sessionId,
    required super.fileName,
    required super.fileUrl,
    required super.fileSize,
    required super.mimeType,
    required super.uploadedBy,
    required super.uploadedAt,
  });

  factory SessionMaterialModel.fromJson(String id, Map<String, dynamic> json) {
    return SessionMaterialModel(
      id: id,
      sessionId: json['sessionId'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
      uploadedBy: json['uploadedBy'] as String? ?? '',
      uploadedAt: DateTime.tryParse(json['uploadedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}
