import 'package:equatable/equatable.dart';

class SessionMaterialEntity extends Equatable {
  final String id;
  final String sessionId;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String mimeType;
  final String uploadedBy;
  final DateTime uploadedAt;

  const SessionMaterialEntity({
    required this.id,
    required this.sessionId,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.mimeType,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  SessionMaterialEntity copyWith({
    String? id,
    String? sessionId,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    String? mimeType,
    String? uploadedBy,
    DateTime? uploadedAt,
  }) {
    return SessionMaterialEntity(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, sessionId, fileName, fileUrl, fileSize, mimeType, uploadedBy, uploadedAt];
}
