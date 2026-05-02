import 'package:flutter/foundation.dart';
import 'package:myapp/core/data/models/invite.dart';
import 'package:myapp/core/data/models/location_model.dart';
import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/data/models/skill_offer.dart';
import 'package:myapp/core/data/models/skill_request.dart';
import 'package:myapp/core/data/models/user.dart' as userModel;
import 'package:myapp/core/data/models/chat_channel.dart';
import 'package:myapp/core/data/models/chat_message.dart';
import 'package:myapp/core/data/models/agreement.dart';
import 'package:myapp/core/data/repositories/invite_repository.dart';
import 'package:myapp/core/data/repositories/skills_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/data/repositories/user_skills_repository.dart';
import 'package:myapp/core/data/repositories/chat_repository.dart';
import 'package:myapp/core/data/repositories/agreement_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SeedDataService {
  final _userRepo = UserRepository();
  final _skillsRepo = SkillsRepository();
  final _userSkillsRepo = UserSkillsRepository();
  final _mainAuth = FirebaseAuth.instance;

  Future<String?> _getPersonaUid(String email, String password) async {
    // Create a secondary app to avoid logging out the current user
    FirebaseApp secondaryApp;
    try {
      secondaryApp = Firebase.app('Seeder');
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: 'Seeder',
        options: Firebase.app().options,
      );
    }

    FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    
    try {
      final cred = await secondaryAuth.createUserWithEmailAndPassword(email: email, password: password);
      return cred.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final cred = await secondaryAuth.signInWithEmailAndPassword(email: email, password: password);
        return cred.user?.uid;
      }
      debugPrint('Error with persona $email: ${e.message}');
    }
    return null;
  }

  Future<void> seed(String currentUid) async {
    print('🌱 Starting data seed for UID: $currentUid');

    // 0. Ensure Current User has a profile
    final currentUser = await _userRepo.read(currentUid);
    if (currentUser == null) {
      await _userRepo.create(
        userModel.User(
          uid: currentUid,
          email: 'you@example.com',
          firstName: 'You',
          lastName: '(Dev)',
          title: 'Aptitude Explorer',
          photoURL: 'https://i.pravatar.cc/150?u=$currentUid',
          skills: ['flutter'],
          interests: ['ui_design'],
          bio: 'I am testing the ultimate skill swap platform!',
          location: AddressModel.empty(),
          createdAt: DateTime.now(),
          profileComplete: true,
        ),
      );

      // Also need to add the actual SkillOffer/Request objects for matching
      await _userSkillsRepo.addOffer(SkillOffer(
        uid: currentUid,
        sid: 'flutter',
        skillName: 'Flutter Development',
        level: SkillLevel.intermediate,
        format: SkillFormat.online,
        description: 'Building this awesome app!',
      ));
      await _userSkillsRepo.addRequest(SkillRequest(
        uid: currentUid,
        sid: 'ui_design',
        skillName: 'UI/UX Design',
        targetLevel: SkillLevel.expert,
        preferredFormat: SkillFormat.online,
        description: 'Need help making it look premium.',
      ));
    }

    // 1. Seed Global Skills
    final globalSkills = [
      Skill(
        sid: 'flutter',
        name: 'Flutter Development',
        category: 'Technology',
        description: 'Cross-platform mobile dev',
      ),
      Skill(
        sid: 'ui_design',
        name: 'UI/UX Design',
        category: 'Design',
        description: 'Modern interface design',
      ),
      Skill(
        sid: 'python',
        name: 'Python Programming',
        category: 'Technology',
        description: 'Data science and backend',
      ),
      Skill(
        sid: 'cooking',
        name: 'Italian Cooking',
        category: 'Culinary',
        description: 'Authentic pasta and pizza',
      ),
      Skill(
        sid: 'guitar',
        name: 'Classical Guitar',
        category: 'Music',
        description: 'Music theory and performance',
      ),
      Skill(
        sid: 'spanish',
        name: 'Spanish Language',
        category: 'Language',
        description: 'Conversational Spanish',
      ),
    ];

    for (var s in globalSkills) {
      await _skillsRepo.addSkill(s);
    }

    // 2. Create Personas and get their REAL UIDs
    final alexUid = await _getPersonaUid('alex@example.com', 'Password123!') ?? 'seed_user_1';
    final sarahUid = await _getPersonaUid('sarah@example.com', 'Password123!') ?? 'seed_user_2';
    final marcoUid = await _getPersonaUid('marco@example.com', 'Password123!') ?? 'seed_user_3';

    final users = [
      userModel.User(
        uid: alexUid,
        email: 'alex@example.com',
        firstName: 'Alex',
        lastName: 'Rivera',
        title: 'Product Designer',
        photoURL: 'https://i.pravatar.cc/150?u=alex',
        skills: ['ui_design'],
        interests: ['flutter'],
        bio: 'Passionate about building beautiful products. Looking to learn mobile dev!',
        location: AddressModel.empty(),
        createdAt: DateTime.now(),
        profileComplete: true,
      ),
      userModel.User(
        uid: sarahUid,
        email: 'sarah@example.com',
        firstName: 'Sarah',
        lastName: 'Chen',
        title: 'Software Engineer',
        photoURL: 'https://i.pravatar.cc/150?u=sarah',
        skills: ['python'],
        interests: ['guitar'],
        bio: 'Backend pro. I want to learn some classical guitar in my free time.',
        location: AddressModel.empty(),
        createdAt: DateTime.now(),
        profileComplete: true,
      ),
      userModel.User(
        uid: marcoUid,
        email: 'marco@example.com',
        firstName: 'Marco',
        lastName: 'Rossi',
        title: 'Chef',
        photoURL: 'https://i.pravatar.cc/150?u=marco',
        skills: ['cooking'],
        interests: ['spanish'],
        bio: 'Pasta master. Moving to Spain soon, need to brush up on my Spanish!',
        location: AddressModel.empty(),
        createdAt: DateTime.now(),
        profileComplete: true,
      ),
    ];

    for (var u in users) {
      await _userRepo.create(u);
    }

    // 3. Create Specific Skill Offers/Requests to trigger matches for Current User
    
    // Alex OFFERS UI Design and WANTS Flutter
    await _userSkillsRepo.addOffer(SkillOffer(
      uid: alexUid,
      sid: 'ui_design',
      skillName: 'UI/UX Design',
      level: SkillLevel.expert,
      format: SkillFormat.online,
      description: 'Expert in Figma and design systems.',
    ));
    await _userSkillsRepo.addRequest(SkillRequest(
      uid: alexUid,
      sid: 'flutter',
      skillName: 'Flutter Development',
      targetLevel: SkillLevel.intermediate,
      preferredFormat: SkillFormat.online,
      description: 'Want to build my designs in Flutter.',
    ));

    // Sarah OFFERS Python
    await _userSkillsRepo.addOffer(SkillOffer(
      uid: sarahUid,
      sid: 'python',
      skillName: 'Python Programming',
      level: SkillLevel.expert,
      format: SkillFormat.online,
      description: '10 years of experience in AI and Web.',
    ));

    // 4. Seed sample invites
    final inviteRepo = InviteRepository();
    
    // Received invite from Alex
    await inviteRepo.sendInvite(Invite(
      id: 'seed_invite_1',
      from: alexUid,
      to: currentUid,
      fromName: 'Alex Rivera',
      toName: 'You',
      commonSkills: ['ui_design', 'flutter'],
      status: InviteStatus.pending,
      createdAt: DateTime.now().toIso8601String(),
    ));

    // Sent invite to Sarah
    await inviteRepo.sendInvite(Invite(
      id: 'seed_invite_2',
      from: currentUid,
      to: sarahUid,
      fromName: 'You',
      toName: 'Sarah Chen',
      commonSkills: ['python'],
      status: InviteStatus.pending,
      createdAt: DateTime.now().toIso8601String(),
    ));

    // 5. Seed Chat Channels & Messages
    final chatRepo = ChatRepository();
    final channelId = chatRepo.getChannelId(currentUid, alexUid);
    
    await chatRepo.createChannel(ChatChannel(
      id: channelId,
      participants: [currentUid, alexUid],
      commonSkills: ['ui_design', 'flutter'],
      lastMessage: 'Let\'s start our swap!',
      lastMessageTimestamp: DateTime.now().millisecondsSinceEpoch,
    ));

    await chatRepo.sendMessage(channelId, ChatMessage(
      id: 'seed_msg_1',
      senderId: alexUid,
      content: 'Hey! I saw your profile. I can definitely help with UI/UX!',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
    ));

    // 6. Seed a sample Agreement
    final agreementRepo = AgreementRepository();
    final agreementId = 'seed_agreement_1';
    
    await agreementRepo.createAgreement(Agreement(
      id: agreementId,
      channelId: channelId,
      proposerId: alexUid,
      receiverId: currentUid,
      offerSkillId: 'ui_design',
      requestSkillId: 'flutter',
      sessionsCount: 5,
      minutesPerSession: 60,
      frequency: 'Weekly',
      status: AgreementStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)).millisecondsSinceEpoch,
    ));

    // Add the agreement message to chat
    await chatRepo.sendMessage(channelId, ChatMessage(
      id: 'seed_msg_agreement',
      senderId: alexUid,
      content: 'Agreement Proposal',
      type: MessageType.agreement,
      metadata: {'agreementId': agreementId},
      timestamp: DateTime.now().subtract(const Duration(minutes: 29)).millisecondsSinceEpoch,
    ));

    print('✅ Seeding complete!');
  }
}
