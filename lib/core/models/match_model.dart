class MatchModel {
  final String id;
  final String teacherUid;
  final String learnerUid;
  final String skillName;
  final double confidenceScore; // 0.0 to 1.0
  final String status; // 'pending', 'accepted', 'declined'
  final DateTime? createdAt;

  MatchModel({
    required this.id,
    required this.teacherUid,
    required this.learnerUid,
    required this.skillName,
    required this.confidenceScore,
    this.status = 'pending',
    this.createdAt,
  });

  MatchModel copyWith({
    String? id,
    String? teacherUid,
    String? learnerUid,
    String? skillName,
    double? confidenceScore,
    String? status,
    DateTime? createdAt,
  }) {
    return MatchModel(
      id: id ?? this.id,
      teacherUid: teacherUid ?? this.teacherUid,
      learnerUid: learnerUid ?? this.learnerUid,
      skillName: skillName ?? this.skillName,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherUid': teacherUid,
      'learnerUid': learnerUid,
      'skillName': skillName,
      'confidenceScore': confidenceScore,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      teacherUid: json['teacherUid'] as String,
      learnerUid: json['learnerUid'] as String,
      skillName: json['skillName'] as String,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }
}
