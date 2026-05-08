import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class SessionMaterialEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSessionMaterialsRequested extends SessionMaterialEvent {
  final String sessionId;

  LoadSessionMaterialsRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class UploadMaterialRequested extends SessionMaterialEvent {
  final String sessionId;
  final File file;
  final String uploadedBy;

  UploadMaterialRequested({
    required this.sessionId,
    required this.file,
    required this.uploadedBy,
  });

  @override
  List<Object?> get props => [sessionId, file, uploadedBy];
}

class DeleteMaterialRequested extends SessionMaterialEvent {
  final String materialId;
  final String sessionId;

  DeleteMaterialRequested({
    required this.materialId,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [materialId, sessionId];
}
