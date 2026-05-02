import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/data/repositories/user_skills_repository.dart';
import 'package:myapp/core/data/repositories/chat_repository.dart';
import 'package:myapp/core/data/repositories/rating_repository.dart';
import 'package:myapp/core/services/auth_service.dart';

class DataExportService {
  final _userRepo = UserRepository();
  final _skillsRepo = UserSkillsRepository();
  final _chatRepo = ChatRepository();
  final _ratingRepo = RatingRepository();
  final _auth = AuthService();

  Future<Map<String, dynamic>> generateFullReport() async {
    final currentUser = await _auth.getCurrentUser();
    if (currentUser == null) throw Exception('User not authenticated');

    final uid = currentUser.uid;

    // 1. Profile Data
    final profile = await _userRepo.read(uid);
    
    // 2. Skills (Offers & Requests)
    final offers = _skillsRepo.getUserOffers(uid);
    final requests = _skillsRepo.getUserRequests(uid);

    // 3. Conversations (Meta only for privacy)
    final channels = await _chatRepo.listUserChannels(uid);
    final conversationSummary = channels.map((c) => {
      'channelId': c.id,
      'participants': c.participants,
      'lastMessage': c.lastMessage,
      'timestamp': (c.lastMessageTimestamp as DateTime).toIso8601String(),
    }).toList();

    // 4. Ratings
    final ratings = await _ratingRepo.getUserRatings(uid);
    final ratingsSummary = ratings.map((r) => {
      'fromId': r.fromUid,
      'rating': r.score,
      'comment': r.comment,
      'timestamp': r.createdAt.toIso8601String(),
    }).toList();

    return {
      'exportMetadata': {
        'generatedAt': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'platform': 'Aptitude',
      },
      'profile': profile?.toJson(),
      'skills': {
        'offers': offers,
        'requests': requests,
      },
      'conversations': conversationSummary,
      'reputation': {
        'ratingsReceived': ratingsSummary,
      },
    };
  }

  String formatToJson(Map<String, dynamic> data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }
}
