import 'package:equatable/equatable.dart';

class FileAttachmentEntity extends Equatable {
  final String id;
  final String fileName;
  final String fileUrl;
  final int fileSizeBytes;
  final String mimeType;
  final DateTime uploadedAt;

  const FileAttachmentEntity({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileSizeBytes,
    required this.mimeType,
    required this.uploadedAt,
  });

  /// Get file size in human-readable format
  String get fileSizeFormatted {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (fileSizeBytes >= gb) {
      return '${(fileSizeBytes / gb).toStringAsFixed(2)} GB';
    } else if (fileSizeBytes >= mb) {
      return '${(fileSizeBytes / mb).toStringAsFixed(2)} MB';
    } else if (fileSizeBytes >= kb) {
      return '${(fileSizeBytes / kb).toStringAsFixed(2)} KB';
    } else {
      return '$fileSizeBytes B';
    }
  }

  /// Determine if file is an image
  bool get isImage => mimeType.startsWith('image/');

  /// Determine if file is a video
  bool get isVideo => mimeType.startsWith('video/');

  /// Determine if file is a PDF
  bool get isPdf => mimeType == 'application/pdf';

  /// Get file extension from fileName
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : 'FILE';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSizeBytes': fileSizeBytes,
      'mimeType': mimeType,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        fileName,
        fileUrl,
        fileSizeBytes,
        mimeType,
        uploadedAt,
      ];
}
