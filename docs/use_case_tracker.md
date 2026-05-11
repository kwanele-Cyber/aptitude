---
description: 
---

# Aptitude Platform - Complete Use Cases List

## MASTER INDEX
**Total Use Cases: 98** (72 User + 26 Admin)

---

# USER USE CASES (72)

## P0 — FOUNDATIONAL SYSTEM (10 use cases)

### Authentication & Identity
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| F01 | ✅ Done | Initialize Authentication System | Setup Firebase Auth, token lifecycle, session persistence |
| F02 | ✅ Done | User Registration | Email/phone/social signup with verification |
| F03 | ✅ Done | User Login | Secure authentication with email/password or social providers |
| F04 | ✅ Done | Session Persistence | Auto-login & token refresh across app restarts |
| F05 | ✅ Done | Logout | Clear session securely with remote invalidation |
| F06 | ✅ Done | Auth State Sync | Global auth state management across app |
| F07 | ✅ Done | Email Verification | Verify email before allowing matchmaking |
| F08 | ✅ Done | Password Reset | Secure password recovery via email |
| F09 | ✅ Done | Account Recovery | Recovery codes for account restoration |
| F10 | ✅ Done | Two-Factor Authentication | Optional 2FA for high-trust accounts |


### User Core System
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| F11 | ✅ Done | Create User Profile | Initial profile creation with required fields |
| F12 | ✅ Done | Update User Profile | Edit skills, availability, location, bio |
| F13 | ✅ Done | Fetch User Profile | Retrieve own user data |
| F14 | ✅ Done | View Other User Profile | Public profile access with privacy controls |
| F15 | ✅ Done | Delete Account | Permanent account removal with cooldown period |
| F16 | ✅ Done | Export User Data | GDPR-compliant data export (JSON/CSV) |

### Shared Infrastructure
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| F17 | ✅ Done | Core Models Initialization | UserModel, SkillModel, MatchModel, etc. |
| F18 | ✅ Done | Firebase Database Service Layer | Abstract DB access with repository pattern |
| F19 | ✅ Done | Exception Framework Setup | CustomException hierarchy with error codes |
| F20 | ✅ Done | State Management Setup | Riverpod/Bloc global configuration |
| F21 | ✅ Done | Common Utilities Setup | Validators, constants, logging, formatters |

---

## P1 — SKILL ECOSYSTEM (12 use cases)

### Skill Creation & Management
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| S01 | ✅ Done | Create Skill Offer | Create teachable skill listing with description, level, format |
| S02 | ✅ Done | Create Skill Request | Create learning request with preferences |
| S03 | ✅ Done | Edit Skill | Modify existing skill offer or request |
| S04 | ✅ Done | Delete Skill | Remove skill listing permanently |
| S05 | ✅ Done | Fetch User Skills | Retrieve all skills for a user |
| S06 | ✅ Done | Clone Skill | Duplicate skill listing for quick posting |
| S07 | ✅ Done | Archive Skill | Soft-delete skill with restore option |

### Discovery System
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| S08 | ✅ Done | Search Skills | Keyword-based search with autocomplete |
| S09 | ✅ Done | Filter Skills | Filter by location, level, format, availability |
| S10 | ✅ Done | Browse Skills Feed | Personalized recommendation feed |
| S11 | ✅ Done | View Skill Details | Full skill info with user context |
| S12 | ✅ Done | Save Search | Save search queries with alerts |

### Skill Validation
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| S13 | ✅ Done | Suggest Skill Category | AI suggests categories for new skills |
| S14 | ✅ Done | Verify Skill Expertise | Optional verification via portfolio/credentials |

---

## P2 — MATCHMAKING SYSTEM (12 use cases)

### Matching Engine
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| M01 | ✅ Done | Generate Matches | AI-powered matching algorithm |
| M02 | ✅ Done | Rank Matches | Score-based prioritization (0-100) |
| M03 | ✅ Done | Fetch Matches | Retrieve daily match suggestions |
| M04 | ✅ Done | Geo-Proximity Scoring | Haversine-based distance ranking |
| M05 | ✅ Done | Availability Matching | Match based on time slot compatibility |
| M06 | ✅ Done | Skill Level Matching | Balance expert/beginner matches with scoring bonus |

### Match Interaction
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| M07 | ✅ Done | Accept Match | User accepts match suggestion |
| M08 | ✅ Done | Reject Match | User declines with reason (optional) |
| M09 | ✅ Done | Ignore Match | Passive dismissal (no notification) |
| M10 | ✅ Done | Match Filtering | Filter by trust score, location, verified status |
| M11 | ✅ Done | Save Match | Bookmark match for later review |
| M12 | ✅ Done | Match History | View past accepted/rejected matches |

### Match Optimization
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| M13 | ✅ Done | Feedback on Matches | Rate match quality to improve algorithm |
| M14 | ✅ Done | Refresh Matches | Request new match suggestions (RefreshIndicator) |

---

## P3 — COMMUNICATION & AGREEMENT (10 use cases)

### Messaging System
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| C01 | ✅ Done  | Initiate Chat | Open conversation channel post-match |
| C02 | ✅ Done  | Send Message | Text, image, location, file sharing |
| C03 | ✅ Done  | Receive Message | Real-time push notifications (FCM) |
| C04 | ✅ Done  | Message History | Load paginated conversation history |
| C05 | ✅ Done | Read Receipts | Show message seen status (Single/Double Ticks) |
| C06 | ✅ Done | Typing Indicator | Real-time typing status |
| C07 | ✅ Done | Block User | Block communication from specific user |
| C08 | ✅ Done | Report Message | Report inappropriate message content |


### Agreement System
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| C09 | ✅ Done | Create Agreement | Define exchange terms (skills, duration, frequency) |
| C10 | ✅ Done | Accept Agreement | Confirm terms to proceed |
| C11 | ✅ Done | Modify Agreement | Request/approve term adjustments |
| C12 | ✅ Done | Cancel Agreement | Terminate agreement before sessions |
| C13 | ✅ Done | View Agreement | Access active/past agreements |
---

## P4 — SESSION EXECUTION SYSTEM (12 use cases)

### Scheduling
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| E01 | ✅ Done | Create Session | Schedule session with time, location, format |
| E02 | ✅ Done | Update Session | Modify session time/location |
| E03 | ✅ Done | Cancel Session | Cancel with cancellation policy enforcement |
| E04 | ✅ Done | Session Reminders | Push/email reminders (24h, 1h before) |
| E05 | ✅ Done | Calendar Integration | Sync to Google/Apple Calendar |
| E06 | ✅ Done | Recurring Sessions | Set up weekly recurring exchanges |
| E07 | ✅ Done | Session Waitlist | Join waitlist for full sessions |

### Session Lifecycle
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| E08 | ✅ Done | Start Session | Begin session with check-in |
| E09 | ✅ Done | Complete Session | Mark session complete |
| E10 | ✅ Done | Track Attendance | Verify presence (QR code, geolocation) |
| E11 | ✅ Done | Session Verification | Code-based attendance proof |
| E12 | ✅ Done | Session History | View past sessions with details |
| E13 | ✅ Done | Session Rating | Rate session quality immediately after |

### Session Materials
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| E14 | ✅ Done | Share Materials | Upload/download session resources |
| E15 | ✅ Done | Session Notes | Collaborative note-taking during session |

---

## P5 — TRUST, AI & PLATFORM INTELLIGENCE (10 use cases)

### Feedback System
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| T01 | ✅ Done | Submit Rating | Rate user 1-5 stars after session |
| T02 | ✅ Done | Write Review | Detailed written feedback |
| T03 | ✅ Done | View Reviews | Read user reviews (with filtering) |
| T04 | ✅ Done | Edit Review | Modify own review (within 48h) |
| T05 | ✅ Done | Respond to Review | Reply to received feedback |

### Trust System
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| T06 | ✅ Done | Calculate Trust Score | AI-computed reputation (0-100) |
| T07 | ✅ Done | Update Reputation | Dynamic score based on behavior |
| T08 | ✅ Done | Trust-Based Filtering | Filter matches by trust threshold in Discover feed |
| T09 | ✅ Done | View Trust Factors | See what affects your trust score |
| T10 | ✅ Done | Appeal Trust Score | Request review of score adjustment |

### AI Enhancements
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| T11 | ✅ Done | Skill Recommendations | AI suggests skills to learn/teach |
| T12 | ✅ Done | Behavior Analysis | Fraud detection & anomaly alerting |
| T13 | ✅ Done | Smart Match Optimization | Continuous ML model improvement |
| T14 | ✅ Done | Session Quality Prediction | Predict likely positive matches |

---

## CROSS-CUTTING SYSTEMS (6 use cases)

### Notification System
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| X01 | ✅ Done | Send Notification | Trigger events (matches, messages, reminders) |
| X02 | ✅ Done | Receive Notification | Multi-channel delivery (push, email, SMS) |
| X03 | ✅ Done | Notification Preferences | Granular user settings by type |
| X04 | ✅ Done | Notification History | View past notifications |

### Dispute & Safety
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| X05 | ✅ Done | Report User | Raise issue with evidence (ReportDialog) |
| X06 | ✅ Done | Create Dispute | Session conflict or agreement violation |
| X07 | ✅ Done | Resolve Dispute | Admin-mediated resolution |
| X08 | ✅ Done | Appeal Decision | Request dispute decision review |

### Progress Tracking
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| X09 | ✅ Done | Track Skill Progress | Learning metrics & milestones |
| X10 | ✅ Done | View Progress Dashboard | Visual insights & achievements |
| X11 | ✅ Done | Set Learning Goals | Personal skill development targets |
| X12 | ✅ Done | Share Achievements | Social sharing of milestones |

### Platform Rules
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| X13 | ✅ Done | View Platform Rules | Access community guidelines |
| X14 | ✅ Done | Acknowledge Policies | Accept updated terms/policies |

---

# ADMIN USE CASES (26)

## Admin Core System (4 use cases)
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| A01 | ✅ Done | Admin Authentication | Secure login with role-based access |
| A02 | ✅ Done | Admin Dashboard | Real-time system overview with KPIs |
| A03 | ✅ Done | Role Management | Assign admin roles (super, mod, support) |
| A04 | ✅ Done | Audit Log | View immutable admin action history |

## User & Content Moderation (6 use cases)
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| A05 | ✅ Done | Manage Users | View, edit, suspend, delete user accounts |
| A06 | ✅ Done | Moderate Content | Remove inappropriate posts/reviews |
| A07 | ✅ Done | Moderate Skills | Validate, edit, or remove skill listings |
| A08 | ✅ Done | Handle Reports | Review and action user complaints |
| A09 | ✅ Done | Bulk Actions | Batch moderation operations |
| A10 | ✅ Done | Content Flagging Queue | Prioritized moderation queue |

|A10.2| ✅ Done | Show Metrics Based on date range | Integrated into Analytics System |

## Enforcement System (5 use cases)
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| A11 | ✅ Done | Apply Penalties | Warnings, suspensions (3-strike rule), permanent bans |
| A12 | ✅ Done | Manage Disputes | Review and resolve session/agreement conflicts |
| A13 | ✅ Done | Enforce Trust Adjustments | Manual trust score overrides |
| A14 | ✅ Done | Appeal Review | Process user appeals for penalties |
| A15 | ✅ Done | Restore Account | Reinstate suspended accounts with conditions |

## Platform Operations (4 use cases)
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| A16 | ✅ Done | View Analytics | User growth, match success, session completion rates |
| A17 | ✅ Done | Export System Data | Operational data export for compliance |
| A18 | ✅ Done | System Configuration | Feature flags, match parameters, thresholds |
| A19 | ✅ Done | Manage Categories | Skill categories and taxonomy |

## Admin Communication (3 use cases)
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| A20 | ✅ Done | Send Broadcast Notifications | System-wide or targeted announcements |
| A21 | ✅ Done | Support Requests | Respond to user support tickets |
| A22 | ✅ Done | Announcement Management | Schedule and track announcements |

## Database Administration (4 use cases)
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| A23 | ✅ Done | Emergency Admin Assignment | Designated successor claims admin via multi-step verification |
| A24 | ✅ Done | Read-Only DB Access | Analytics team access without write permissions |
| A25 | ✅ Done | Temporary Admin Grant | Time-bound admin access for specific tasks |
| A26 | ✅ Done | Admin Recovery Key Management | Secure offline recovery key storage and rotation |

---

# FEATURE REFINEMENTS & SAFETY POLISH
| ID | Status | Use Case | Description |
|----|--------|----------|-------------|
| X15 | ✅ Done | Filtering Integration | Automatically filter out blocked users in Discovery and Chat ViewModels |
| X16 | ✅ Done | Blocked List Management | Add a "Blocked Users" section to Profile settings to review/manage blocks |
| X17 | ❌ Todo | Auto-Block Suggestion | Prompt user to block a peer immediately after filing a safety report |

---
