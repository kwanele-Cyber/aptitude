import 'package:uuid/uuid.dart';

enum PostType { offer, request }

class Post {
  String pid;
  final String uid;
  final String skillId;
  final PostType type;
  final String title;
  final String description;
  final String? location;
  final DateTime createdAt;
  final bool isOpen;

  Post({
    String? pid,
    required this.uid,
    required this.skillId,
    required this.type,
    required this.title,
    required this.description,
    this.location,
    required this.createdAt,
    this.isOpen = true,
  }) : pid = pid ?? const Uuid().v4();


  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'uid': uid,
      'skillId': skillId,
      'type': type.name,
      'title': title,
      'description': description,
      'location': location,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isOpen': isOpen,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      pid: json['pid'],
      uid: json['uid'],
      skillId: json['skillId'],
      type: PostType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      description: json['description'],
      location: json['location'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      isOpen: json['isOpen'],
    );
  }
}
