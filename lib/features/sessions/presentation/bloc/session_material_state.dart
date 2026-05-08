import 'package:equatable/equatable.dart';
import 'package:myapp/features/sessions/domain/entity/session_material_entity.dart';

abstract class SessionMaterialState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SessionMaterialInitial extends SessionMaterialState {}

class SessionMaterialLoading extends SessionMaterialState {}

class SessionMaterialUploading extends SessionMaterialState {}

class SessionMaterialsLoaded extends SessionMaterialState {
  final List<SessionMaterialEntity> materials;

  SessionMaterialsLoaded({required this.materials});

  @override
  List<Object?> get props => [materials];
}

class SessionMaterialUploaded extends SessionMaterialState {
  final SessionMaterialEntity material;

  SessionMaterialUploaded({required this.material});

  @override
  List<Object?> get props => [material];
}

class SessionMaterialDeleted extends SessionMaterialState {
  final String materialId;

  SessionMaterialDeleted({required this.materialId});

  @override
  List<Object?> get props => [materialId];
}

class SessionMaterialError extends SessionMaterialState {
  final String message;

  SessionMaterialError({required this.message});

  @override
  List<Object?> get props => [message];
}
