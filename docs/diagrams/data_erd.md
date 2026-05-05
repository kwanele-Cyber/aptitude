# Data Entity Relationship Diagram

**Coverage**: Auth, Skills, Matchmaking, Communication, Agreement, Session, Trust, Notification, Dispute, Progress, Safety, Admin domains
**Storage**: Firebase Realtime Database (NoSQL)
**Naming**: `camelCase` fields, ISO 8601 timestamps, push IDs for list items

## Legend

```
PK  = Primary Key (partition key in RTDB)
FK  = Foreign Key (reference to another entity's PK)
[]  = Array field
{}  = Map field
?   = Nullable
*   = Denormalized (copied for read performance)
```

---

## Domain Overview

```mermaid
erDiagram
    USER ||--o{ SKILL : "userId (FK) owns"
    USER ||--o{ SAVED_SEARCH : "userId (FK) owns"
    USER ||--o{ MATCH : "targetUserId (FK) is target"
    USER ||--o{ CHAT_THREAD : "participantIds (FK) includes"
    USER ||--o{ AGREEMENT : "initiatorId / partnerId (FK)"
    USER ||--o{ SESSION : "participantIds (FK) includes"
    USER ||--o{ REVIEW : "reviewerId / targetUserId (FK)"
    USER ||--o{ TRUST_APPEAL : "userId (FK)"
    USER ||--o{ NOTIFICATION : "userId (FK)"
    USER ||--o{ NOTIFICATION_PREFERENCE : "userId (FK)"
    USER ||--o{ DISPUTE : "initiatorId / respondentId (FK)"
    USER ||--o{ REPORT : "reporterId / reportedUserId (FK)"
    USER ||--o{ LEARNING_GOAL : "userId (FK)"
    USER ||--o{ ACHIEVEMENT : "userId (FK, via lookup)"
    USER ||--o{ BLOCKED_USER : "blockerId / blockedUserId (FK)"
    USER ||--o{ PENALTY : "userId (FK)"
    USER ||--o{ SUPPORT_TICKET : "userId (FK)"

    SKILL ||--o{ MATCH : "matchedSkillId / targetSkillId (FK)"
    SKILL ||--o{ AGREEMENT : "skillId (FK)"
    AGREEMENT ||--o{ SESSION : "agreementId (FK)"
    SESSION ||--o{ SESSION_MATERIAL : "sessionId (FK)"
    SESSION ||--o{ SESSION_NOTE : "sessionId (FK)"
    SESSION ||--o{ CHECK_IN : "sessionId (FK)"
    SESSION ||--o{ REVIEW : "sessionId (FK)"
    DISPUTE ||--o{ DISPUTE_MESSAGE : "disputeId (FK)"

    USER {
        string uid PK
        string email
        string firstName
        string lastName
        string title
        string photoURL
        string bio
        array skills
        array interests
        object location
        string phone
        bool profileComplete
        bool twoFactorEnabled
        string twoFactorPin
        double trustScore
        bool isVerified
        string role
        datetime createdAt
        datetime updatedAt
    }
    SKILL {
        string pushId PK
        string title
        string description
        string category
        enum type
        enum level
        enum format
        string userId FK
        array tags
        datetime createdAt
        datetime updatedAt
        datetime archivedAt
        bool isVerified
        array portfolioUrls
        double latitude
        double longitude
        array availability
    }
    MATCH {
        string compositeId PK
        string targetUserId FK
        string targetSkillId FK
        string matchedSkillId FK
        double score
        enum status
        datetime createdAt
        string targetUserName
        string targetSkillTitle
        string targetSkillCategory
        enum targetSkillLevel
        enum targetSkillFormat
        double targetTrustScore
        bool targetIsVerified
        double distance
        array targetAvailability
    }
    CHAT_THREAD {
        string pushId PK
        array participantIds FK
        string lastMessagePreview
        string lastMessageTimestamp
        string lastMessageSenderId
        map unreadCount "userId -> count"
        datetime createdAt
    }
    MESSAGE {
        string pushId PK
        string threadId FK
        string senderId FK
        string body
        string timestamp
        enum readStatus "delivered | read"
        string messageType "text | image | file"
    }
    AGREEMENT {
        string pushId PK
        string initiatorId FK
        string partnerId FK
        string skillId FK
        string skillName
        enum initiatorRole "teacher | learner"
        enum partnerRole "teacher | learner"
        int durationWeeks
        int sessionsPerWeek
        array preferredDays
        enum format
        string location
        string materialsNeeded
        string notes
        enum status
        datetime createdAt
        datetime updatedAt
    }
    SESSION {
        string pushId PK
        string agreementId FK
        array participantIds FK
        string skillName
        int sessionNumber
        date sessionDate
        string startTime
        string endTime
        string timezone
        enum format
        string location
        enum status
        datetime createdAt
    }
    CHECK_IN {
        string pushId PK
        string sessionId FK
        string userId FK
        enum method "qr | manual | location"
        string code
        datetime timestamp
        bool verified
    }
    SESSION_MATERIAL {
        string pushId PK
        string sessionId FK
        string uploaderId FK
        string fileName
        int fileSize
        string fileType
        string fileUrl
        int downloadCount
        datetime uploadedAt
    }
    SESSION_NOTE {
        string pushId PK
        string sessionId FK
        string content
        string lastEditedBy FK
        datetime lastEditedAt
        array collaboratorIds FK
    }
    REVIEW {
        string pushId PK
        string sessionId FK
        string reviewerId FK
        string targetUserId FK
        int starRating
        string reviewText
        datetime createdAt
        datetime updatedAt
        bool verified
    }
    TRUST_APPEAL {
        string pushId PK
        string userId FK
        double currentScore
        double previousScore
        string dropReason
        string sessionId FK
        string category
        string description
        array evidenceFiles
        enum status
        datetime createdAt
        datetime resolvedAt
    }
    NOTIFICATION {
        string pushId PK
        string userId FK
        enum type
        string title
        string body
        bool read
        string targetRoute
        datetime createdAt
    }
    NOTIFICATION_PREFERENCE {
        string userId PK
        bool pushEnabled
        bool emailEnabled
        map matchSettings "type -> bool"
        map messageSettings "type -> bool"
        map sessionSettings "type -> bool"
        map agreementSettings "type -> bool"
        map trustSettings "type -> bool"
        map systemSettings "type -> bool"
    }
    DISPUTE {
        string pushId PK
        string initiatorId FK
        string respondentId FK
        string sessionId FK
        string agreementId FK
        enum category
        string description
        string desiredOutcome
        enum status
        string adminId
        datetime createdAt
        datetime resolvedAt
    }
    DISPUTE_MESSAGE {
        string pushId PK
        string disputeId FK
        string senderId FK
        enum senderRole "user | admin | other"
        string body
        datetime createdAt
    }
    REPORT {
        string pushId PK
        string reporterId FK
        string reportedUserId FK
        enum category
        string description
        array attachments
        enum status
        datetime createdAt
    }
    LEARNING_GOAL {
        string pushId PK
        string userId FK
        string title
        string skillId FK
        int progressPercent
        date targetDate
        enum status
        datetime createdAt
        datetime completedAt
    }
    ACHIEVEMENT {
        string id PK
        string name
        string icon
        string description
        string unlockCriteria
        enum rarity
        string category
        int sortOrder
    }
    ACHIEVEMENT_UNLOCK {
        string pushId PK
        string userId FK
        string achievementId FK
        datetime unlockedAt
    }
    SKILL_PROGRESS {
        string pushId PK
        string userId FK
        string skillId FK
        int sessionsCompleted
        int totalSessions
        int progressPercent
        datetime lastSessionDate
    }
    BLOCKED_USER {
        string pushId PK
        string blockerId FK
        string blockedUserId FK
        datetime createdAt
    }
    PLATFORM_RULE {
        string id PK
        int version
        string content
        bool requiresAcknowledgment
        datetime publishedAt
    }
    USER_ACKNOWLEDGMENT {
        string pushId PK
        string userId FK
        string ruleId FK
        int ruleVersion
        datetime acknowledgedAt
    }
    SUPPORT_TICKET {
        string pushId PK
        string userId FK
        string subject
        string body
        enum priority
        enum status
        string assignedAdminId
        datetime createdAt
        datetime resolvedAt
    }
    LOCATION {
        string address
        double latitude
        double longitude
    }
```

---

## Auth / User Domain

**RTDB Path**: `users/{uid}`, `blockedUsers/{pushId}`

```mermaid
erDiagram
    USER {
        string uid PK "Firebase Auth UID"
        string email "unique, login identifier"
        string firstName "display name part"
        string lastName "display name part"
        string title "professional headline"
        string photoURL "avatar URL"
        array skills "list of skill names"
        array interests "list of interest tags"
        object location "nested AddressModel"
        string phone "optional contact"
        bool profileComplete "onboarding flag"
        bool twoFactorEnabled "2FA status"
        string twoFactorPin "TOTP secret (nullable)"
        double trustScore "0-100 reputation"
        bool isVerified "email verified flag"
        string role "'member' | 'admin' — drives authZ"
        datetime createdAt "ISO 8601"
        datetime updatedAt "ISO 8601"
    }

    LOCATION {
        string address "human-readable"
        double latitude "geo point"
        double longitude "geo point"
    }

    USER ||--|| LOCATION : "contains embedded"
```

### Enums

| Field | Values |
|-------|--------|
| `role` | `member`, `admin` |

### Key Relationships

| FK Field | References | Type |
|----------|------------|------|
| `uid` | Firebase Auth `User.uid` | 1:1 |

### Usage Notes

- `UserRole.fromString()` normalizes case — always store lowercase
- `skills` and `interests` stored as flat string arrays for simplicity
- `location` is embedded, not a separate node (queried together with user)
- `twoFactorPin` stores the HMAC-based TOTP secret; null when 2FA is off
- `trustScore` updated by session completions, no-shows, and reviews
- Role-based access control uses the `role` field — gate checks via `userEntity.isAdmin`

---

## Skills Domain

**RTDB Paths**: `skills/{pushId}`, `savedSearches/{pushId}`

```mermaid
erDiagram
    SKILL {
        string pushId PK "Firebase push ID"
        string title "skill name"
        string description "free-text"
        string category "grouping key"
        enum type "offer | request"
        enum level "beginner | intermediate | advanced"
        enum format "online | inPerson | both"
        string userId FK "owner reference"
        array tags "searchable keywords"
        datetime createdAt "ISO 8601"
        datetime updatedAt "ISO 8601"
        datetime archivedAt "null = active"
        bool isVerified "admin moderation"
        array portfolioUrls "media attachments"
        double latitude "location for geo queries"
        double longitude "location for geo queries"
        array availability "time slot strings"
    }

    SAVED_SEARCH {
        string pushId PK "Firebase push ID"
        string userId FK "owner reference"
        string query "free-text search term"
        string category "filter value"
        enum level "filter value"
        enum format "filter value"
        enum type "filter value"
        string createdAt "ISO 8601 string (sort key)"
    }

    USER ||--o{ SKILL : "userId"
    USER ||--o{ SAVED_SEARCH : "userId"
```

### Enums

| Field | Values |
|-------|--------|
| `type` | `offer`, `request` |
| `level` | `beginner`, `intermediate`, `advanced` |
| `format` | `online`, `inPerson`, `both` |

### Key Relationships

| FK Field | References | Type |
|----------|------------|------|
| `skill.userId` | `users/{uid}` | N:1 |
| `savedSearch.userId` | `users/{uid}` | N:1 |

### Usage Notes

- `archivedAt` is the soft-delete mechanism — null = active, non-null = archived
- `latitude`/`longitude` enable geo-proximity sorting in matchmaking
- `availability` values use `weekday_morning`, `weekday_afternoon`, `weekday_evening`, `weekend_morning`, `weekend_afternoon`
- `category` is a free-text grouping key (e.g. "Technology", "Music")

---

## Matchmaking Domain

**RTDB Path**: `matches/{compositeId}`

```mermaid
erDiagram
    MATCH {
        string compositeId PK "skillAId_skillBId (sorted)"
        string targetUserId FK "the user this match is for"
        string targetSkillId FK "the target user's skill"
        string matchedSkillId FK "the matched user's skill"
        double score "0-100 match score"
        enum status "pending | accepted | rejected | ignored"
        datetime createdAt "ISO 8601"
        string targetUserName "denormalized *"
        string targetSkillTitle "denormalized *"
        string targetSkillCategory "denormalized *"
        enum targetSkillLevel "denormalized *"
        enum targetSkillFormat "denormalized *"
        double targetTrustScore "denormalized *"
        bool targetIsVerified "denormalized *"
        double distance "km between users *"
        array targetAvailability "denormalized *"
    }

    USER ||--o{ MATCH : "targetUserId"
    SKILL ||--o{ MATCH : "targetSkillId / matchedSkillId"
```

### Enums

| Field | Values |
|-------|--------|
| `status` | `pending`, `accepted`, `rejected`, `ignored` |

### Key Relationships

| FK Field | References | Type |
|----------|------------|------|
| `targetUserId` | `users/{uid}` | N:1 |
| `targetSkillId` | `skills/{pushId}` | N:1 |
| `matchedSkillId` | `skills/{pushId}` | N:1 |

### Usage Notes

- Matches are **denormalized** — user name, skill title, trust score copied at match-creation time so they remain readable even if the original profile changes
- The `compositeId` is `{matchedSkillId}_{targetSkillId}` (sorted alphabetically) to prevent duplicates
- Bidirectional: for each pair, two match records are created (one per direction)
- Score: category overlap (30pts) + level compatibility (25pts) + format match (20pts) + tag overlap (15pts) + geo-proximity (10pts) + availability overlap (5pts)

---

## Communication Domain

**RTDB Paths**: `chats/{pushId}`, `chats/{pushId}/messages/{pushId}`

**Status**: ❌ Not yet implemented

```mermaid
erDiagram
    CHAT_THREAD {
        string pushId PK "created post-match"
        array participantIds FK "[uid1, uid2] sorted"
        string lastMessagePreview "denormalized for list"
        string lastMessageTimestamp "denormalized for sorting"
        string lastMessageSenderId "for alignment"
        map unreadCount "userId -> unread count"
        datetime createdAt "thread creation time"
    }

    MESSAGE {
        string pushId PK "auto-generated"
        string threadId FK "parent thread"
        string senderId FK "who sent it"
        string body "text content"
        string timestamp "ISO 8601"
        enum readStatus "delivered | read"
        string messageType "text | image | file"
    }

    USER ||--o{ CHAT_THREAD : "participantIds"
    CHAT_THREAD ||--o{ MESSAGE : "threadId"
```

### Enums

| Field | Values |
|-------|--------|
| `readStatus` | `delivered`, `read` |
| `messageType` | `text`, `image`, `file` |

### Key Relationships

| FK Field | References | Type |
|----------|------------|------|
| `message.threadId` | `chats/{pushId}` | N:1 |
| `message.senderId` | `users/{uid}` | N:1 |

### Usage Notes

- Messages are stored as a **sub-collection** under the chat thread node for efficient pagination
- `lastMessagePreview/timestamp/senderId` are denormalized on the thread so the chat list screen can display without querying all messages
- `unreadCount` is a map keyed by userId so each participant can see their own unread count independently
- `readStatus` starts as `delivered` and transitions to `read` when the recipient opens the thread
- Threads created automatically when a match is accepted (C01)

---

## Agreement Domain

**RTDB Path**: `agreements/{pushId}`

**Status**: ❌ Not yet implemented

```mermaid
erDiagram
    AGREEMENT {
        string pushId PK "created after match acceptance"
        string initiatorId FK "who proposed"
        string partnerId FK "who accepted/modified"
        string skillId FK "what skill is being exchanged"
        string skillName "denormalized *"
        enum initiatorRole "teacher | learner"
        enum partnerRole "teacher | learner"
        int durationWeeks "e.g. 8 weeks"
        int sessionsPerWeek "e.g. 2"
        array preferredDays "[monday, wednesday]"
        enum format "online | inPerson | both"
        string location "address or video link"
        string materialsNeeded "optional notes"
        string notes "free-text"
        enum status "draft | pending | active | completed | cancelled | modified"
        datetime createdAt "ISO 8601"
        datetime updatedAt "ISO 8601"
    }

    USER ||--o{ AGREEMENT : "initiatorId"
    USER ||--o{ AGREEMENT : "partnerId"
    SKILL ||--o{ AGREEMENT : "skillId"
```

### Enums

| Field | Values |
|-------|--------|
| `initiatorRole` / `partnerRole` | `teacher`, `learner` |
| `format` | `online`, `inPerson`, `both` |
| `status` | `draft`, `pending`, `active`, `completed`, `cancelled`, `modified` |

### Key Relationships

| FK Field | References | Type |
|----------|------------|------|
| `initiatorId` | `users/{uid}` | N:1 |
| `partnerId` | `users/{uid}` | N:1 |
| `skillId` | `skills/{pushId}` | N:1 |

### Usage Notes

- `status` flows: `draft` → `pending` → `active` → `completed` (or `cancelled`)
- `modified` status triggers when a counter-proposal is accepted; the original is preserved for audit
- `skillName` is denormalized so agreement cards can display without a separate skill lookup
- Both `initiatorRole` and `partnerRole` are explicit so the agreement knows who teaches vs learns
- `preferredDays` stores weekday names for scheduling (e.g. `["monday", "wednesday"]`)

---

## Session Domain

**RTDB Paths**: `sessions/{pushId}`, `sessions/{pushId}/checkIns/{pushId}`, `sessions/{pushId}/materials/{pushId}`, `sessions/{pushId}/notes/{pushId}`, `skillProgress/{pushId}`

**Status**: ❌ Not yet implemented

```mermaid
erDiagram
    SESSION {
        string pushId PK "scheduled from agreement"
        string agreementId FK "parent agreement"
        array participantIds FK "[uid1, uid2]"
        string skillName "denormalized *"
        int sessionNumber "ordinal, e.g. #4"
        date sessionDate "YYYY-MM-DD"
        string startTime "HH:mm"
        string endTime "HH:mm"
        string timezone "IANA tz"
        enum format "online | inPerson | hybrid"
        string location "address or link"
        enum status "upcoming | inProgress | checkedIn | completed | cancelled | noShow"
        datetime createdAt "ISO 8601"
    }

    CHECK_IN {
        string pushId PK "attendance record"
        string sessionId FK "which session"
        string userId FK "who checked in"
        enum method "qr | manual | location"
        string code "6-char alphanumeric"
        datetime timestamp "when checked in"
        bool verified "admin override flag"
    }

    SESSION_MATERIAL {
        string pushId PK "uploaded resource"
        string sessionId FK "which session"
        string uploaderId FK "who uploaded"
        string fileName "display name"
        int fileSize "bytes"
        string fileType "pdf | image | code | link"
        string fileUrl "storage download URL"
        int downloadCount "counter"
        datetime uploadedAt "ISO 8601"
    }

    SESSION_NOTE {
        string pushId PK "collaborative note"
        string sessionId FK "which session"
        string content "markdown / rich text"
        string lastEditedBy FK "who last edited"
        datetime lastEditedAt "ISO 8601"
        array collaboratorIds FK "users currently editing"
    }

    SKILL_PROGRESS {
        string pushId PK "per-user per-skill"
        string userId FK "who is learning"
        string skillId FK "which skill"
        int sessionsCompleted "so far"
        int totalSessions "target"
        int progressPercent "0-100"
        datetime lastSessionDate "most recent"
    }

    AGREEMENT ||--o{ SESSION : "agreementId"
    SESSION ||--o{ CHECK_IN : "sessionId"
    SESSION ||--o{ SESSION_MATERIAL : "sessionId"
    SESSION ||--o{ SESSION_NOTE : "sessionId"
    USER ||--o{ SKILL_PROGRESS : "userId"
    SKILL ||--o{ SKILL_PROGRESS : "skillId"
```

### Enums

| Field | Values |
|-------|--------|
| `status` | `upcoming`, `inProgress`, `checkedIn`, `completed`, `cancelled`, `noShow` |
| `format` | `online`, `inPerson`, `hybrid` |
| `checkIn.method` | `qr`, `manual`, `location` |

### Key Relationships

| FK Field | References | Type |
|----------|------------|------|
| `session.agreementId` | `agreements/{pushId}` | N:1 |
| `checkIn.sessionId` | `sessions/{pushId}` | N:1 |
| `material.sessionId` | `sessions/{pushId}` | N:1 |
| `note.sessionId` | `sessions/{pushId}` | N:1 |

### Usage Notes

- Sessions are scheduled from an agreement — one agreement produces many sessions
- `sessionNumber` is a human-readable ordinal (not a DB sequence) computed at creation
- Check-ins support three methods: QR scan, manual 6-char code, or geo-proximity
- Materials and notes are stored as **sub-collections** under the session node for lifecycle scoping
- `SkillProgress` tracks learning progress per-user per-skill, updated when sessions complete
- `participantIds` is a sorted 2-element array `[uid1, uid2]` for querying sessions by user

---

## Trust & Review Domain

**RTDB Paths**: `reviews/{pushId}`, `trustAppeals/{pushId}`

**Status**: ❌ Not yet implemented

```mermaid
erDiagram
    REVIEW {
        string pushId PK "submitted after session"
        string sessionId FK "which session"
        string reviewerId FK "who rated"
        string targetUserId FK "who was rated"
        int starRating "1-5"
        string reviewText "optional, max 1000"
        datetime createdAt "ISO 8601"
        datetime updatedAt "modified if within 48h"
        bool verified "confirmed session flag"
    }

    TRUST_APPEAL {
        string pushId PK "user-initiated"
        string userId FK "who appealed"
        double currentScore "at time of appeal"
        double previousScore "before the drop"
        string dropReason "system-generated"
        string sessionId FK "related session, if any"
        enum category "attended | technicalIssue | unfairRating | mistakenIdentity | systemError | other"
        string description "free-text, max 2000"
        array evidenceFiles "[{name, url, size}]"
        enum status "pending | underReview | approved | denied"
        datetime createdAt "ISO 8601"
        datetime resolvedAt "ISO 8601, when admin acts"
    }

    USER ||--o{ REVIEW : "reviewerId (FK)"
    USER ||--o{ REVIEW : "targetUserId (FK)"
    SESSION ||--o{ REVIEW : "sessionId (FK)"
    USER ||--o{ TRUST_APPEAL : "userId"
```

### Enums

| Field | Values |
|-------|--------|
| `starRating` | 1–5 |
| `appeal.category` | `attended`, `technicalIssue`, `unfairRating`, `mistakenIdentity`, `systemError`, `other` |
| `appeal.status` | `pending`, `underReview`, `approved`, `denied` |

### Key Relationships

| FK Field | References | Type |
|----------|------------|------|
| `review.sessionId` | `sessions/{pushId}` | N:1 |
| `review.reviewerId` | `users/{uid}` | N:1 |
| `review.targetUserId` | `users/{uid}` | N:1 |
| `appeal.sessionId` | `sessions/{pushId}` | N:1 |

### Usage Notes

- Reviews are created after a session completes; `verified=true` means the review is linked to a confirmed session
- Edit window is 48 hours from `createdAt` — enforced in the UI layer
- Trust score is computed from: session completion rate, average rating, behavior flags, review responsiveness, account age, and verification status
- An appeal is the user's mechanism to contest a trust score drop
- `evidenceFiles` stores metadata only; actual files go to Firebase Storage

---

## Notification Domain

**RTDB Paths**: `notifications/{userId}/{pushId}`, `notificationPreferences/{userId}`

**Status**: ❌ Not yet implemented

```mermaid
erDiagram
    NOTIFICATION {
        string pushId PK "auto-generated"
        string userId FK "recipient"
        enum type "agreement | session | match | message | trust | system"
        string title "short header"
        string body "preview text"
        bool read "false by default"
        string targetRoute "deep-link route"
        datetime createdAt "ISO 8601"
    }

    NOTIFICATION_PREFERENCE {
        string userId PK "one doc per user"
        bool pushEnabled "global push toggle"
        bool emailEnabled "global email toggle"
        map matchSettings "type -> bool"
        map messageSettings "type -> bool"
        map sessionSettings "type -> bool"
        map agreementSettings "type -> bool"
        map trustSettings "type -> bool"
        map systemSettings "type -> bool"
    }

    USER ||--o{ NOTIFICATION : "userId"
    USER ||--|| NOTIFICATION_PREFERENCE : "userId"
```

### Enums

| Field | Values |
|-------|--------|
| `notification.type` | `agreement`, `session`, `match`, `message`, `trust`, `system` |

### Key Relationships

| FK Field | References | Type |
|----------|------------|------|
| `notification.userId` | `users/{uid}` | N:1 |
| `preference.userId` | `users/{uid}` | 1:1 |

### Usage Notes

- Notifications are stored under a `userId` partition for efficient queries (`orderByChild` by userId)
- `targetRoute` enables deep-linking: when tapped, navigates to the relevant screen
- `notificationPreferences` is a single document per user containing all toggle settings
- Each settings map (e.g. `sessionSettings`) stores sub-toggles like `reminder: true`, `changeAlert: false`
- Global toggles (`pushEnabled`, `emailEnabled`) act as kill-switches over the per-type settings

---

## Dispute & Safety Domain

**RTDB Paths**: `disputes/{pushId}`, `disputes/{pushId}/messages/{pushId}`, `reports/{pushId}`, `blockedUsers/{blockerId}/{blockedUserId}`

**Status**: ❌ Not yet implemented

```mermaid
erDiagram
    DISPUTE {
        string pushId PK "filed by user"
        string initiatorId FK "who filed"
        string respondentId FK "the other party"
        string sessionId FK "related session"
        string agreementId FK "related agreement"
        enum category "noShow | cutShort | poorQuality | unprepared | misrepresentation | termsNotFollowed | communicationBreakdown | other"
        string description "max 2000 chars"
        string desiredOutcome "reschedule | amendTerms | cancel | warning | trustAdjustment | suspension | other"
        enum status "opened | underReview | resolved | appealed | closed"
        string adminId "assigned moderator"
        datetime createdAt "ISO 8601"
        datetime resolvedAt "ISO 8601"
    }

    DISPUTE_MESSAGE {
        string pushId PK "timeline event"
        string disputeId FK "parent dispute"
        string senderId FK "who wrote it"
        enum senderRole "user | admin | other"
        string body "message text"
        datetime createdAt "ISO 8601"
    }

    REPORT {
        string pushId PK "user report"
        string reporterId FK "who reported"
        string reportedUserId FK "who is reported"
        enum category "inappropriateBehavior | harassment | fakeProfile | spam | offensiveContent | sessionNoShow | agreementViolation | other"
        string description "max 1000 chars"
        array attachments "[file metadata]"
        enum status "pending | reviewed | dismissed"
        datetime createdAt "ISO 8601"
    }

    BLOCKED_USER {
        string pushId PK "block record"
        string blockerId FK "who blocked"
        string blockedUserId FK "who is blocked"
        datetime createdAt "when blocked"
    }

    USER ||--o{ DISPUTE : "initiatorId"
    USER ||--o{ DISPUTE : "respondentId"
    SESSION ||--o{ DISPUTE : "sessionId"
    DISPUTE ||--o{ DISPUTE_MESSAGE : "disputeId"
    USER ||--o{ REPORT : "reporterId"
    USER ||--o{ REPORT : "reportedUserId"
    USER ||--o{ BLOCKED_USER : "blockerId"
    USER ||--o{ BLOCKED_USER : "blockedUserId"
```

### Enums

| Entity | Field | Values |
|--------|-------|--------|
| `Dispute` | `category` | `noShow`, `cutShort`, `poorQuality`, `unprepared`, `misrepresentation`, `termsNotFollowed`, `communicationBreakdown`, `other` |
| `Dispute` | `status` | `opened`, `underReview`, `resolved`, `appealed`, `closed` |
| `DisputeMessage` | `senderRole` | `user`, `admin`, `other` |
| `Report` | `category` | `inappropriateBehavior`, `harassment`, `fakeProfile`, `spam`, `offensiveContent`, `sessionNoShow`, `agreementViolation`, `other` |
| `Report` | `status` | `pending`, `reviewed`, `dismissed` |

### Key Relationships

| FK Field | References | Type |
|----------|------------|------|
| `dispute.initiatorId` | `users/{uid}` | N:1 |
| `dispute.respondentId` | `users/{uid}` | N:1 |
| `dispute.sessionId` | `sessions/{pushId}` | N:1 |
| `disputeMessage.disputeId` | `disputes/{pushId}` | N:1 |
| `report.reportedUserId` | `users/{uid}` | N:1 |

### Usage Notes

- Disputes have a timeline of messages (including admin responses) stored as a sub-collection
- `desiredOutcome` is a free-text string from the user, not an enum (more flexible for edge cases)
- `adminId` is set when a moderator claims the dispute; null means unassigned
- `report.status` lifecycle: `pending` → `reviewed` | `dismissed`
- Blocked users are stored under a `blockerId` partition so the blocked list query is efficient: `blockedUsers/{blockerId}` ordered by child

---

## Progress Domain

**RTDB Paths**: `learningGoals/{pushId}`, `achievementUnlocks/{pushId}`, `activityEvents/{pushId}`

**Status**: ❌ Not yet implemented

```mermaid
erDiagram
    LEARNING_GOAL {
        string pushId PK "user-created"
        string userId FK "who set the goal"
        string title "goal description"
        string skillId FK "associated skill"
        int progressPercent "0-100"
        date targetDate "deadline"
        enum status "inProgress | completed"
        datetime createdAt "ISO 8601"
        datetime completedAt "ISO 8601"
    }

    ACHIEVEMENT {
        string id PK "static definition"
        string name "badge name"
        string icon "emoji / asset path"
        string description "how to unlock"
        string unlockCriteria "e.g. 'complete 10 sessions'"
        enum rarity "common | rare | epic | legendary"
        string category "sessions | skills | trust | social"
        int sortOrder "display priority"
    }

    ACHIEVEMENT_UNLOCK {
        string pushId PK "earned badge"
        string userId FK "who earned it"
        string achievementId FK "which badge"
        datetime unlockedAt "when earned"
    }

    ACTIVITY_EVENT {
        string pushId PK "feed item"
        string userId FK "who performed"
        enum type "sessionCompleted | ratingGiven | notesAdded | achievementEarned"
        string description "human-readable"
        string relatedEntityId "link to source"
        datetime createdAt "ISO 8601"
    }

    USER ||--o{ LEARNING_GOAL : "userId"
    SKILL ||--o{ LEARNING_GOAL : "skillId"
    USER ||--o{ ACHIEVEMENT_UNLOCK : "userId"
    ACHIEVEMENT ||--o{ ACHIEVEMENT_UNLOCK : "achievementId"
    USER ||--o{ ACTIVITY_EVENT : "userId"
```

### Enums

| Field | Values |
|-------|--------|
| `goal.status` | `inProgress`, `completed` |
| `achievement.rarity` | `common`, `rare`, `epic`, `legendary` |
| `activityEvent.type` | `sessionCompleted`, `ratingGiven`, `notesAdded`, `achievementEarned` |

### Key Relationships

| FK Field | References | Type |
|----------|------------|------|
| `goal.userId` | `users/{uid}` | N:1 |
| `goal.skillId` | `skills/{pushId}` | N:1 |
| `unlock.userId` | `users/{uid}` | N:1 |
| `unlock.achievementId` | static definition | N:1 |
| `event.userId` | `users/{uid}` | N:1 |

### Usage Notes

- `Achievement` is a **static definition** — seeded at app init, not user-specific
- `AchievementUnlock` is the per-user record of which badges they've earned
- `ActivityEvent` powers the recent-activity feed on the progress dashboard
- `LearningGoal` progress is updated when sessions against the related skill are completed
- Goals turn from green (on track) → yellow (at risk) → red (overdue) based on `targetDate`

---

## Platform Rules Domain

**RTDB Paths**: `platformRules/{ruleId}`, `userAcknowledgment/{pushId}`

**Status**: ❌ Not yet implemented

```mermaid
erDiagram
    PLATFORM_RULE {
        string id PK "static key, e.g. 'v1'"
        int version "monotonic"
        string content "markdown body"
        bool requiresAcknowledgment "must accept to proceed"
        datetime publishedAt "ISO 8601"
    }

    USER_ACKNOWLEDGMENT {
        string pushId PK "acceptance record"
        string userId FK "who accepted"
        string ruleId FK "which version"
        int ruleVersion "snapshot of version"
        datetime acknowledgedAt "ISO 8601"
    }

    USER ||--o{ USER_ACKNOWLEDGMENT : "userId"
    PLATFORM_RULE ||--o{ USER_ACKNOWLEDGMENT : "ruleId"
```

### Key Relationships

| FK Field | References | Type |
|----------|------------|------|
| `acknowledgment.userId` | `users/{uid}` | N:1 |
| `acknowledgment.ruleId` | `platformRules/{id}` | N:1 |

### Usage Notes

- When rules are updated, existing users must re-acknowledge before using the app
- `ruleVersion` is snapshotted on the acknowledgment so we know which version they agreed to

---

## Admin Domain — Additions

**Status**: ❌ Not yet implemented

```mermaid
erDiagram
    SUPPORT_TICKET {
        string pushId PK "user support request"
        string userId FK "who needs help"
        string subject "short summary"
        string body "detailed description"
        enum priority "low | medium | high | urgent"
        enum status "open | assigned | inProgress | resolved | closed"
        string assignedAdminId "moderator FK"
        datetime createdAt "ISO 8601"
        datetime resolvedAt "ISO 8601"
    }

    USER ||--o{ SUPPORT_TICKET : "userId"
```

### Enums

| Field | Values |
|-------|--------|
| `priority` | `low`, `medium`, `high`, `urgent` |
| `status` | `open`, `assigned`, `inProgress`, `resolved`, `closed` |

### Key Relationships

| FK Field | References | Type |
|----------|------------|------|
| `supportTicket.userId` | `users/{uid}` | N:1 |

---

## Admin Domain — Existing (Mock Only)

**Storage**: Currently served from `AdminRemoteDataSourceMock`. Ready for future RTDB persistence.

```mermaid
erDiagram
    ADMIN_USER {
        string id PK
        string firstName
        string lastName
        string email
        string role
        string status
        string joined
        int sessions
        double rating
        int reportsCount
        bool twoFactorEnabled
    }

    FLAGGED_CONTENT {
        string id PK
        string priority "HIGH | MED | LOW"
        string reason
        string preview
        string reportedBy
        string fromUser
        string timestamp
        string type "Message | Review | Profile | Skills"
        string status "Pending | Dismissed | Removed"
        string contentId "optional reference"
    }

    PENALTY {
        string id PK
        string severity "Low | Medium | High"
        string type "Permanent Ban | Suspension | Warning | Trust Score Reduction | Content Removal"
        string user "denormalized name *"
        string userId FK
        string reason
        string date
        string duration
        int strikes
        bool isActive
    }

    ANALYTICS_DATA {
        int newUsers
        int totalMatches
        int sessionsCompleted
        double avgRating
        double avgTrustScore
        double disputeRate
        array userGrowth "28 data points"
        map matchSuccessByCategory "category -> rate"
        double sessionCompletionRate
        double sessionCancelRate
        double sessionNoShowRate
        double sessionRescheduleRate
    }

    SYSTEM_CONFIG {
        map featureFlags "name -> bool"
        map matchParams "name -> double"
        map trustThresholds "name -> int"
        map generalSettings "name -> int"
    }

    SKILL_CATEGORY {
        string id PK
        string name
        string emoji
        int skillCount
        bool active
        int displayOrder
        array subcategories
    }

    BROADCAST {
        string id PK
        string title
        string message
        string audience
        int recipientCount
        string sentDate
        double openRate
        bool isScheduled
        datetime scheduledAt
        string status
    }

    AUDIT_LOG {
        string id PK
        string time
        string admin
        string action
        string detail
        string severity "critical | warning | info"
        string ip
        string device
        string changes
        datetime timestamp
    }

    ADMIN_ROLE {
        string id PK
        string name
        int members
        int permissionCount
        int totalPermissions
        bool isProtected
        map permissions "category -> permission list"
    }

    DATABASE_STATS {
        int totalDocuments
        int totalCollections
        string storageUsed
        string lastBackup
        array collections
    }

    COLLECTION_INFO {
        string name PK
        int documents
        string size
        string status
    }

    ADMIN_DASHBOARD {
        int totalUsers
        int activeMatches
        int sessionsThisWeek
        double averageRating
    }

    USER ||--o{ PENALTY : "userId"
```

### Admin Enums

| Entity | Field | Values |
|--------|-------|--------|
| `FlaggedContent` | `priority` | `HIGH`, `MED`, `LOW` |
| `FlaggedContent` | `type` | `Message`, `Review`, `Profile`, `Skills` |
| `FlaggedContent` | `status` | `Pending`, `Dismissed`, `Removed` |
| `Penalty` | `severity` | `Low`, `Medium`, `High` |
| `AuditLog` | `severity` | `critical`, `warning`, `info` |

---

## Cross-Domain Reference Map

| Entity | RTDB Path | Domain | Status |
|--------|-----------|--------|--------|
| `User` | `users/{uid}` | Auth | ✅ Implemented |
| `Skill` | `skills/{pushId}` | Skills | ✅ Implemented |
| `SavedSearch` | `savedSearches/{pushId}` | Skills | ✅ Implemented |
| `Match` | `matches/{compositeId}` | Matchmaking | ✅ Implemented |
| `ChatThread` | `chats/{pushId}` | Communication | ❌ Missing |
| `Message` | `chats/{pushId}/messages/{pushId}` | Communication | ❌ Missing |
| `Agreement` | `agreements/{pushId}` | Agreement | ❌ Missing |
| `Session` | `sessions/{pushId}` | Session | ❌ Missing |
| `CheckIn` | `sessions/{pushId}/checkIns/{pushId}` | Session | ❌ Missing |
| `SessionMaterial` | `sessions/{pushId}/materials/{pushId}` | Session | ❌ Missing |
| `SessionNote` | `sessions/{pushId}/notes/{pushId}` | Session | ❌ Missing |
| `Review` | `reviews/{pushId}` | Trust | ❌ Missing |
| `TrustAppeal` | `trustAppeals/{pushId}` | Trust | ❌ Missing |
| `Notification` | `notifications/{userId}/{pushId}` | Notification | ❌ Missing |
| `NotificationPreference` | `notificationPreferences/{userId}` | Notification | ❌ Missing |
| `Dispute` | `disputes/{pushId}` | Dispute | ❌ Missing |
| `DisputeMessage` | `disputes/{pushId}/messages/{pushId}` | Dispute | ❌ Missing |
| `Report` | `reports/{pushId}` | Safety | ❌ Missing |
| `BlockedUser` | `blockedUsers/{pushId}` | Safety | ❌ Missing |
| `LearningGoal` | `learningGoals/{pushId}` | Progress | ❌ Missing |
| `Achievement` | static definition | Progress | ❌ Missing |
| `AchievementUnlock` | `achievementUnlocks/{pushId}` | Progress | ❌ Missing |
| `ActivityEvent` | `activityEvents/{pushId}` | Progress | ❌ Missing |
| `SkillProgress` | `skillProgress/{pushId}` | Progress | ❌ Missing |
| `PlatformRule` | `platformRules/{id}` | Platform Rules | ❌ Missing |
| `UserAcknowledgment` | `userAcknowledgment/{pushId}` | Platform Rules | ❌ Missing |
| `SupportTicket` | `supportTickets/{pushId}` | Admin | ❌ Missing |
| `AdminUser` | — | Admin | ⚠️ Mock only |
| `FlaggedContent` | — | Admin | ⚠️ Mock only |
| `Penalty` | — | Admin | ⚠️ Mock only |
| `AnalyticsData` | — | Admin | ⚠️ Mock only |
| `SystemConfig` | — | Admin | ⚠️ Mock only |
| `SkillCategory` | — | Admin | ⚠️ Mock only |
| `Broadcast` | — | Admin | ⚠️ Mock only |
| `AuditLog` | — | Admin | ⚠️ Mock only |
| `AdminRole` | — | Admin | ⚠️ Mock only |
| `DatabaseStats` | — | Admin | ⚠️ Mock only |

---

## Implementation Priority Matrix

| Priority | Domain | Entities | Depends On | Use Cases |
|----------|--------|----------|------------|-----------|
| P0 | Auth | `User`, `Location` | — | F01-F16 |
| P1 | Skills | `Skill`, `SavedSearch` | User | S01-S14 |
| P2 | Matchmaking | `Match` | User, Skill | M01-M14 |
| **P3** | **Communication** | `ChatThread`, `Message` | Match | C01-C08 |
| **P3** | **Agreement** | `Agreement` | User, Skill, Match | C09-C13 |
| **P4** | **Session** | `Session`, `CheckIn`, `Material`, `Note`, `SkillProgress` | Agreement | E01-E15 |
| **P5** | **Trust** | `Review`, `TrustAppeal` | Session | T01-T10 |
| **P5** | **Notification** | `Notification`, `Preference` | All | X01-X04 |
| **P5** | **Dispute** | `Dispute`, `DisputeMessage`, `Report` | Session, Agreement | X05-X08 |
| **P5** | **Progress** | `LearningGoal`, `Achievement`, `ActivityEvent` | Session, Skill | X09-X12 |
| **P5** | **Safety** | `BlockedUser` | User | X15-X16 |
| **P5** | **Platform Rules** | `PlatformRule`, `UserAcknowledgment` | User | X13-X14 |
| Admin | Admin | All admin entities | User | A01-A26 |

---

## Data Flow Patterns

### Read Path (Login Example)
```
Firebase Auth (signIn) 
  → AuthRemoteDataSourceFirebase.login()
  → _getUserFromDatabase(uid)
  → RTDB: users/{uid}
  → Map<String, dynamic>.from(snapshot.value as Map)
  → UserModel.fromJson()
  → UserEntity
```

### Write Path (Seed Example)
```
SeederService.run()
  → Firebase Auth: createUserWithEmailAndPassword()
  → RTDB: users/{uid}.set(profileJson)
  → RTDB: skills/{pushId}.set(skillJson)
  → RTDB: matches/{id}.set(matchJson)
```

### Denormalization Strategy
- Match records copy user/skill display fields at creation time — avoids N+1 reads on match listings
- Chat threads store `lastMessagePreview`/`timestamp` for zero-query list rendering
- Sessions store `skillName` so the calendar and history screens don't need a join
- Trade-off: stale data if source profile changes after denormalization; acceptable because these are immutable snapshots
