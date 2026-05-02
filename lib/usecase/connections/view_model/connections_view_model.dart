import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/chat_channel.dart';
import 'package:myapp/core/data/models/invite.dart';
import 'package:myapp/core/data/repositories/chat_repository.dart';
import 'package:myapp/core/data/repositories/invite_repository.dart';
import 'package:myapp/core/services/auth_service.dart';

class ConnectionsViewModel extends ChangeNotifier {
  final InviteRepository _inviteRepo;
  final ChatRepository _chatRepo;
  final AuthService _auth;

  ConnectionsViewModel({
    InviteRepository? inviteRepo,
    ChatRepository? chatRepo,
    AuthService? auth,
  })  : _inviteRepo = inviteRepo ?? InviteRepository(),
        _chatRepo = chatRepo ?? ChatRepository(),
        _auth = auth ?? AuthService();

  List<Invite> _received = [];
  List<Invite> get received => _received;

  List<Invite> _sent = [];
  List<Invite> get sent => _sent;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _myUid;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final user = await _auth.getCurrentUser();
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _myUid = user.uid;

    _received = await _inviteRepo.listByRecipient(_myUid!);
    _sent = await _inviteRepo.listBySender(_myUid!);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> acceptInvite(Invite invite) async {
    // 1. Update status
    await _inviteRepo.updateStatus(invite.id, InviteStatus.accepted);

    // 2. Create Chat Channel (C01)
    final channelId = _chatRepo.getChannelId(invite.from, invite.to);
    
    // Check if exists first to avoid overwriting
    final existing = await _chatRepo.getChannel(channelId);
    if (existing == null) {
      final newChannel = ChatChannel(
        id: channelId,
        participants: [invite.from, invite.to],
        commonSkills: invite.commonSkills,
        lastMessage: 'Match accepted! Start chatting.',
        lastMessageTimestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await _chatRepo.createChannel(newChannel);
    }

    await load();
  }

  Future<void> rejectInvite(String inviteId) async {
    await _inviteRepo.updateStatus(inviteId, InviteStatus.rejected);
    await load();
  }
}
