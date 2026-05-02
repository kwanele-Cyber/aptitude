import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/chat_channel.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/repositories/chat_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/core/data/repositories/block_repository.dart';

class ChatListEntry {
  final ChatChannel channel;
  final User peer;

  ChatListEntry({required this.channel, required this.peer});
}

class ChatListViewModel extends ChangeNotifier {
  final ChatRepository _chatRepo = ChatRepository();
  final UserRepository _userRepo = UserRepository();
  final BlockRepository _blockRepo = BlockRepository();
  final AuthService _auth = AuthService();

  List<ChatListEntry> _entries = [];
  List<ChatListEntry> get entries => _entries;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadChannels() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = await _auth.getCurrentUser();
      if (currentUser == null) return;

      final channels = await _chatRepo.listUserChannels(currentUser.uid);
      final blockedUids = await _blockRepo.getBlockedList(currentUser.uid);
      
      List<ChatListEntry> newEntries = [];
      for (var channel in channels) {
        final peerId = channel.participants.firstWhere((id) => id != currentUser.uid);
        
        // Safety Filter: Skip blocked users
        if (blockedUids.contains(peerId)) continue;

        final peer = await _userRepo.read(peerId);
        if (peer != null) {
          newEntries.add(ChatListEntry(channel: channel, peer: peer));
        }
      }

      // Sort by timestamp descending
      newEntries.sort((a, b) => b.channel.lastMessageTimestamp.compareTo(a.channel.lastMessageTimestamp));
      
      _entries = newEntries;
    } catch (e) {
      debugPrint('Error loading chat channels: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
