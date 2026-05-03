import 'package:flutter/foundation.dart';
import 'package:myapp/core/data/models/invite.dart';
import 'package:myapp/core/data/models/location_model.dart';
import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/data/models/skill_offer.dart';
import 'package:myapp/core/data/models/skill_request.dart';
import 'package:myapp/core/data/models/user_role.dart';
import 'package:myapp/core/data/models/user.dart' as user_model;
import 'package:myapp/core/data/models/chat_channel.dart';
import 'package:myapp/core/data/models/chat_message.dart';
import 'package:myapp/core/data/models/agreement.dart';
import 'package:myapp/core/data/models/session.dart';
import 'package:myapp/core/data/models/session_material.dart';
import 'package:myapp/core/data/models/session_note.dart';
import 'package:myapp/core/data/models/match.dart';
import 'package:myapp/core/data/repositories/invite_repository.dart';
import 'package:myapp/core/data/repositories/skills_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/data/repositories/user_skills_repository.dart';
import 'package:myapp/core/data/repositories/chat_repository.dart';
import 'package:myapp/core/data/repositories/agreement_repository.dart';
import 'package:myapp/core/data/repositories/session_repository.dart';
import 'package:myapp/core/data/repositories/material_repository.dart';
import 'package:myapp/core/data/repositories/note_repository.dart';
import 'package:myapp/core/data/repositories/match_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';

class SeedDataService {
  final _userRepo = UserRepository();
  final _skillsRepo = SkillsRepository();
  final _userSkillsRepo = UserSkillsRepository();
  final _inviteRepo = InviteRepository();
  final _chatRepo = ChatRepository();
  final _agreementRepo = AgreementRepository();
  final _sessionRepo = SessionRepository();
  final _materialRepo = MaterialRepository();
  final _noteRepo = NoteRepository();
  final _matchRepo = MatchRepository();

  Future<String?> _getPersonaUid(String email, String password) async {
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
      if (e.code == 'admin-restricted-operation') {
        debugPrint('Email/Password auth not enabled in Firebase Console — skipping persona $email');
      } else {
        debugPrint('Error with persona $email: ${e.message}');
      }
    }
    return null;
  }

  Future<void> seed(String currentUid) async {
    debugPrint('🌱 Starting data seed for UID: $currentUid');

    // 0. Ensure Current User has a profile
    final currentUser = await _userRepo.read(currentUid);
    if (currentUser == null) {
      await _userRepo.create(user_model.User(
        uid: currentUid,
        email: 'you@example.com',
        firstName: 'You',
        lastName: '(Dev)',
        title: 'Aptitude Explorer',
        photoURL: 'https://i.pravatar.cc/150?u=$currentUid',
        skills: ['flutter'],
        interests: ['ui_design', 'python'],
        bio: 'I am testing the ultimate skill swap platform!',
        location: AddressModel.empty(),
        createdAt: DateTime.now(),
        profileComplete: true,
        role: UserRole.user,
        trustScore: 0.0,
        isVerified: false,
      ));

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
      Skill(sid: 'flutter', name: 'Flutter Development', category: 'Technology',
          description: 'Cross-platform mobile dev'),
      Skill(sid: 'ui_design', name: 'UI/UX Design', category: 'Design',
          description: 'Modern interface design'),
      Skill(sid: 'python', name: 'Python Programming', category: 'Technology',
          description: 'Data science and backend'),
      Skill(sid: 'cooking', name: 'Italian Cooking', category: 'Culinary',
          description: 'Authentic pasta and pizza'),
      Skill(sid: 'guitar', name: 'Classical Guitar', category: 'Music',
          description: 'Music theory and performance'),
      Skill(sid: 'spanish', name: 'Spanish Language', category: 'Language',
          description: 'Conversational Spanish'),
      Skill(sid: 'photography', name: 'Photography', category: 'Arts',
          description: 'Digital photography and editing'),
    ];

    for (var s in globalSkills) {
      await _skillsRepo.addSkill(s);
    }

    // 2. Create Personas and get their REAL UIDs
    final alexUid = await _getPersonaUid('alex@example.com', 'Password123!') ?? 'seed_user_1';
    final sarahUid = await _getPersonaUid('sarah@example.com', 'Password123!') ?? 'seed_user_2';
    final marcoUid = await _getPersonaUid('marco@example.com', 'Password123!') ?? 'seed_user_3';

    final users = [
      user_model.User(
        uid: alexUid, email: 'alex@example.com',
        firstName: 'Alex', lastName: 'Rivera',
        title: 'Product Designer',
        photoURL: 'https://i.pravatar.cc/150?u=alex',
        skills: ['ui_design'], interests: ['flutter'],
        bio: 'Passionate about building beautiful products. Looking to learn mobile dev!',
        location: AddressModel.empty(), createdAt: DateTime.now(),
        profileComplete: true, role: UserRole.admin, trustScore: 78.0, isVerified: true,
      ),
      user_model.User(
        uid: sarahUid, email: 'sarah@example.com',
        firstName: 'Sarah', lastName: 'Chen',
        title: 'Software Engineer',
        photoURL: 'https://i.pravatar.cc/150?u=sarah',
        skills: ['python'], interests: ['guitar'],
        bio: 'Backend pro. I want to learn some classical guitar in my free time.',
        location: AddressModel.empty(), createdAt: DateTime.now(),
        profileComplete: true, role: UserRole.user, trustScore: 92.0, isVerified: true,
      ),
      user_model.User(
        uid: marcoUid, email: 'marco@example.com',
        firstName: 'Marco', lastName: 'Rossi',
        title: 'Chef',
        photoURL: 'https://i.pravatar.cc/150?u=marco',
        skills: ['cooking'], interests: ['spanish'],
        bio: 'Pasta master. Moving to Spain soon, need to brush up on my Spanish!',
        location: AddressModel.empty(), createdAt: DateTime.now(),
        profileComplete: true, role: UserRole.user, trustScore: 85.0, isVerified: true,
      ),
    ];

    for (var u in users) {
      await _userRepo.create(u);
    }

    // 3. Seed Skill Offers & Requests
    // Alex OFFERS UI Design, WANTS Flutter
    await _userSkillsRepo.addOffer(SkillOffer(
      uid: alexUid, sid: 'ui_design', skillName: 'UI/UX Design',
      level: SkillLevel.expert, format: SkillFormat.online,
      description: 'Expert in Figma and design systems.',
      yearsOfExperience: 6, isVerified: true,
    ));
    await _userSkillsRepo.addRequest(SkillRequest(
      uid: alexUid, sid: 'flutter', skillName: 'Flutter Development',
      targetLevel: SkillLevel.intermediate, preferredFormat: SkillFormat.online,
      description: 'Want to build my designs in Flutter.',
    ));

    // Sarah OFFERS Python, WANTS Guitar
    await _userSkillsRepo.addOffer(SkillOffer(
      uid: sarahUid, sid: 'python', skillName: 'Python Programming',
      level: SkillLevel.expert, format: SkillFormat.online,
      description: '10 years of experience in AI and Web.',
      yearsOfExperience: 10, isVerified: true,
    ));
    await _userSkillsRepo.addRequest(SkillRequest(
      uid: sarahUid, sid: 'guitar', skillName: 'Classical Guitar',
      targetLevel: SkillLevel.beginner, preferredFormat: SkillFormat.inPerson,
      description: 'Always wanted to learn classical guitar.',
    ));

    // Marco OFFERS Cooking, WANTS Spanish
    await _userSkillsRepo.addOffer(SkillOffer(
      uid: marcoUid, sid: 'cooking', skillName: 'Italian Cooking',
      level: SkillLevel.expert, format: SkillFormat.inPerson,
      description: 'Authentic pasta, pizza, and tiramisu.',
      yearsOfExperience: 15, isVerified: true,
    ));
    await _userSkillsRepo.addRequest(SkillRequest(
      uid: marcoUid, sid: 'spanish', skillName: 'Spanish Language',
      targetLevel: SkillLevel.intermediate, preferredFormat: SkillFormat.online,
      description: 'Moving to Barcelona next year!',
    ));

    // 4. Seed Matches (so the user sees suggestions)
    // Alex & Current User — pending match (mutual skill swap)
    await _matchRepo.createMatch(Match(
      id: const Uuid().v4(),
      participants: [currentUid, alexUid],
      status: MatchStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ));
    // Sarah & Current User — pending match
    await _matchRepo.createMatch(Match(
      id: const Uuid().v4(),
      participants: [currentUid, sarahUid],
      status: MatchStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ));
    // Marco & Current User — pending match
    await _matchRepo.createMatch(Match(
      id: const Uuid().v4(),
      participants: [currentUid, marcoUid],
      status: MatchStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ));

    // 5. Seed Invites
    // Received invite from Alex
    await _inviteRepo.sendInvite(Invite(
      id: 'seed_invite_1',
      from: alexUid, to: currentUid,
      fromName: 'Alex Rivera', toName: 'You',
      commonSkills: ['ui_design', 'flutter'],
      status: InviteStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    ));
    // Sent invite to Sarah
    await _inviteRepo.sendInvite(Invite(
      id: 'seed_invite_2',
      from: currentUid, to: sarahUid,
      fromName: 'You', toName: 'Sarah Chen',
      commonSkills: ['python'],
      status: InviteStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
    ));

    // 6. Seed Chat Channels & Messages
    final channelId = _chatRepo.getChannelId(currentUid, alexUid);
    final channel = ChatChannel(
      id: channelId,
      participants: [currentUid, alexUid],
      commonSkills: ['ui_design', 'flutter'],
      lastMessage: 'Looking forward to our first session!',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(minutes: 5)).millisecondsSinceEpoch,
    );
    await _chatRepo.createChannel(channel);

    await _chatRepo.sendMessage(channelId, ChatMessage(
      id: const Uuid().v4(),
      senderId: alexUid,
      content: 'Hey! I saw your profile. I can definitely help with UI/UX!',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
    ));
    await _chatRepo.sendMessage(channelId, ChatMessage(
      id: const Uuid().v4(),
      senderId: currentUid,
      content: 'That would be great! I can help you with Flutter too.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)).millisecondsSinceEpoch,
    ));
    await _chatRepo.sendMessage(channelId, ChatMessage(
      id: const Uuid().v4(),
      senderId: alexUid,
      content: 'Perfect! Let me send you an agreement proposal.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)).millisecondsSinceEpoch,
    ));

    // 7. Seed Agreement
    final agreementId = 'seed_agreement_1';
    await _agreementRepo.createAgreement(Agreement(
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
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)).millisecondsSinceEpoch,
    ));

    await _chatRepo.sendMessage(channelId, ChatMessage(
      id: const Uuid().v4(),
      senderId: alexUid,
      content: 'Agreement Proposal',
      type: MessageType.agreement,
      metadata: {'agreementId': agreementId},
      timestamp: DateTime.now().subtract(const Duration(minutes: 24)).millisecondsSinceEpoch,
    ));

    // 8. Seed Sessions tied to the agreement
    final now = DateTime.now();
    final pastSession = Session(
      id: const Uuid().v4(),
      agreementId: agreementId,
      title: 'Intro to Design Systems',
      startTime: now.subtract(const Duration(days: 2)),
      durationMinutes: 60,
      status: SessionStatus.completed,
      format: SessionFormat.online,
      location: 'Google Meet',
      attendeeIds: [currentUid, alexUid],
      capacity: 2,
      isRated: false,
    );
    await _sessionRepo.createSession(pastSession);

    final currentSession = Session(
      id: const Uuid().v4(),
      agreementId: agreementId,
      title: 'Flutter Widget Workshop',
      startTime: now.add(const Duration(days: 5)),
      durationMinutes: 90,
      status: SessionStatus.scheduled,
      format: SessionFormat.online,
      location: 'Google Meet',
      attendeeIds: [currentUid, alexUid],
      capacity: 2,
      reminderOffsetsMinutes: const [1440, 60],
    );
    await _sessionRepo.createSession(currentSession);

    // 9. Seed Session Materials for the past session
    await _materialRepo.uploadMaterial(SessionMaterial(
      id: const Uuid().v4(),
      sessionId: pastSession.id,
      name: 'Design System Slides',
      url: 'https://docs.example.com/design-slides.pdf',
      type: SessionMaterialType.document,
      uploadedBy: alexUid,
      uploadedAt: now.subtract(const Duration(days: 2)),
      fileSize: 2_500_000,
    ));
    await _materialRepo.uploadMaterial(SessionMaterial(
      id: const Uuid().v4(),
      sessionId: pastSession.id,
      name: 'Figma Community File',
      url: 'https://figma.com/file/demo',
      type: SessionMaterialType.link,
      uploadedBy: alexUid,
      uploadedAt: now.subtract(const Duration(days: 2)),
      fileSize: 0,
    ));

    // 10. Seed Session Notes (collaborative)
    await _noteRepo.addNote(SessionNote(
      id: const Uuid().v4(),
      sessionId: pastSession.id,
      content: 'Key takeaway: Use design tokens for consistent spacing and color.',
      createdBy: currentUid,
      createdAt: now.subtract(const Duration(days: 2)),
      isPinned: true,
    ));
    await _noteRepo.addNote(SessionNote(
      id: const Uuid().v4(),
      sessionId: pastSession.id,
      content: 'Recommended book: "Refactoring UI" by Adam Wathan.',
      createdBy: alexUid,
      createdAt: now.subtract(const Duration(days: 2, hours: -1)),
    ));
    await _noteRepo.addNote(SessionNote(
      id: const Uuid().v4(),
      sessionId: pastSession.id,
      content: 'Next session: Bring your own Flutter project for review.',
      createdBy: alexUid,
      createdAt: now.subtract(const Duration(days: 1)),
    ));

    debugPrint('✅ Seeding complete!');
    debugPrint('   Persona credentials:');
    debugPrint('   - alex@example.com / Password123!');
    debugPrint('   - sarah@example.com / Password123!');
    debugPrint('   - marco@example.com / Password123!');
  }
}
