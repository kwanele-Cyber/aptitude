import 'package:equatable/equatable.dart';

class RoomEntity extends Equatable {
  final String id;
  final String name;
  final String createdBy;
  final List<String> memberIds;
  final DateTime createdAt;

  const RoomEntity({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.memberIds,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, createdBy, memberIds, createdAt];
}
