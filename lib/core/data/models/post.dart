enum PostType { offer, request }

class Post {
  final String pid; //post id
  final String uid; //user id
  final String skillId;
  final PostType type;
  final String title;
  final String description;
  final String? location;
  final DateTime createdAt;
  final bool isOpen;

  Post({
    required this.pid,
    required this.uid,
    required this.skillId,
    required this.type,
    required this.title,
    required this.description,
    this.location,
    required this.createdAt,
    this.isOpen = true,
  });
}
