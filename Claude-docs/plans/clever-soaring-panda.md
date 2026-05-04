# P2 — Matchmaking System (M01-M06)

## Context
The Matchmaking System matches users based on complementary skills — users offering to teach a skill are matched with users requesting to learn it. Since no backend AI is available, the matching engine uses a rule-based scoring algorithm.

## Architecture

### 1. MatchEntity (`lib/features/matchmaking/domain/entity/match_entity.dart`)
```dart
enum MatchStatus { pending, accepted, rejected, ignored }

class MatchEntity extends Equatable {
  final String id;
  final String targetUserId;       // the matched user
  final String targetSkillId;      // the matched skill
  final String matchedSkillId;     // the user's own skill that matched
  final double score;              // 0-100
  final MatchStatus status;
  final DateTime createdAt;
  // denormalized display data for feed rendering
  final String targetUserName;
  final String targetSkillTitle;
  final String targetSkillCategory;
  final SkillLevel targetSkillLevel;
  final SkillFormat targetSkillFormat;
  final double targetTrustScore;
  final bool targetIsVerified;
}
```

### 2. Data Layer
- `MatchRemoteDataSource` (abstract + mock) — CRUD for matches in Firebase
- `MatchRemoteDataSourceFirebase` — RTDB at `matches/` node
- `MatchModel` — extends MatchEntity with fromJson/toJson
- `MatchRepositoryImpl` — implements abstract, delegates to datasource
- `MatchRepository` (abstract) — methods: fetchMatches, updateMatchStatus, saveMatch, getMatchHistory

### 3. Matching Algorithm (`GenerateMatchesUseCase`)
Located in `lib/features/matchmaking/domain/usecases/generate_matches_usecase.dart`

Logic:
1. Fetch all skills (offers + requests) and all users
2. For each of the current user's skills, find complementary skills (offer ↔ request) with:
   - Category overlap (same/related category) — +30 points max
   - Skill level compatibility — +25 points max (same = 25, adjacent = 15, far = 5)
   - Format compatibility (online/inPerson/both) — +20 points max
   - Tag keyword overlap — +15 points max
   - Trust score bonus — +10 points (trustScore / 10)
3. Rank by total score (0-100)
4. Store matches in Firebase with status `pending`
5. Return top 20 matches

### 4. BLoC
- `match_event.dart`: FetchMatchesRequested, AcceptMatchRequested, RejectMatchRequested, IgnoreMatchRequested, SaveMatchRequested, FetchMatchHistoryRequested
- `match_state.dart`: MatchInitial, MatchLoading, MatchesLoaded, MatchAccepted, MatchRejected, MatchStatusUpdated, MatchHistoryLoaded, MatchError
- `match_bloc.dart`: handlers for each event, following the same loading→use case→success/error pattern

### 5. UI
- `matchmaking_page.dart` — Card stack showing matches with accept/reject/ignore buttons
- `match_history_page.dart` — List of past accepted/rejected matches

### 6. DI & Routes
- Register all use cases, datasource, repository in `injection_container.dart`
- Add `/matches` and `/matches/history` routes

### 7. Tests
- Use case tests for generate_matches (score calculation, ranking)
- Bloc tests for each event
- Repository tests matching existing patterns

## Files to Create/Modify
**NEW files** under `lib/features/matchmaking/`:
- `domain/entity/match_entity.dart`
- `domain/repository/match_repository.dart`
- `domain/usecases/generate_matches_usecase.dart`
- `domain/usecases/update_match_status_usecase.dart`
- `domain/usecases/save_match_usecase.dart`
- `domain/usecases/fetch_match_history_usecase.dart`
- `data/datasources/match_remote_datasource.dart`
- `data/datasources/match_remote_datasource_firebase.dart`
- `data/models/match_model.dart`
- `data/repository/match_repository_impl.dart`
- `presentation/bloc/match_event.dart`
- `presentation/bloc/match_state.dart`
- `presentation/bloc/match_bloc.dart`
- `presentation/pages/matchmaking_page.dart`
- `presentation/pages/match_history_page.dart`

**Modified files**:
- `lib/injection_container.dart`
- `lib/router.dart`
- `docs/use_case_tracker.md`

**Test files** — following existing patterns under `test/features/matchmaking/`

## Verification
- `flutter test test/features/matchmaking/` — all tests pass
- Match cards display on the matchmaking page with score and user info
- Accept/Reject updates status in Firebase
