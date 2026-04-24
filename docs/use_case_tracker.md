# 📋 Use Case Progress Tracker

This document tracks the implementation status of the Aptitude platform features as defined in the **Aptitude Use Cases** workflow.

## 👤 User Use Cases

### 🔐 Authentication & Identity (P0)
| ID | Use Case | Status | Notes |
|---|---|---|---|
| F01 | Initialize Authentication System | ✅ Done | Firebase Auth initialized in `main.dart`. |
| F02 | User Registration | ✅ Done | ViewModel, Repo, and 3-step UI implemented. |
| F03 | User Login | ✅ Done | LoginPage implemented with full MVVM wire-up. |
| F04 | Session Persistence | ✅ Done | Managed by Firebase Auth & `onAuthStateChanged`. |
| F05 | Logout | ✅ Done | ViewModel logout logic and UI trigger implemented. |
| F06 | Auth State Sync | ✅ Done | `onAuthStateChanged` implemented in `AuthRepositoryImpl`. |

### 👤 User Core System (P0)
| ID | Use Case | Status | Notes |
|---|---|---|---|
| F07 | Create User Profile | ✅ Done | Initial profile (skills/location) handled in registration flow. |
| F08 | Update User Profile | ✅ Done | ProfilePage implemented with editable fields and Firestore sync. |
| F09 | Fetch User Profile | ✅ Done | `getCurrentUser` in `AuthRepositoryImpl`. |
| F10 | View Other User Profile | ✅ Done | UserRepository and PublicProfilePage implemented. |

### 🧱 Shared Infrastructure (P0)
| ID | Use Case | Status | Notes |
|---|---|---|---|
| F11 | Core Models Initialization | ✅ Done | `UserModel`, `SkillModel`, etc. exist. |
| F12 | Firestore Service Layer Setup | ✅ Done | `BaseFirestoreService` implemented. |
| F13 | Exception Framework Setup | ✅ Done | `CustomException` and `AuthException` exist. |
| F14 | State Management Setup | ✅ Done | `Provider` + `ChangeNotifier` (MVVM) configured. |
| F15 | Common Utilities Setup | 🟡 In Progress | Basic setup done. |

---

## 🟠 P1 — SKILL ECOSYSTEM
| ID | Use Case | Status | Notes |
|---|---|---|---|
| S01 | Create Skill Offer | ✅ Done | SkillRepository and CreateSkillOfferPage implemented. |
| S02 | Create Skill Request | ✅ Done | SkillViewModel updated and CreateSkillRequestPage implemented. |
| S03 | Edit Skill | ✅ Done | SkillRepository.updateSkill and EditSkillPage implemented. |
| S04 | Delete Skill | ✅ Done | SkillRepository.deleteSkill implemented with confirmation UI. |
| S05 | Fetch User Skills | ✅ Done | AuthViewModel.refreshUser implemented and integrated into ProfilePage. |

## 🔍 Discovery System
| ID | Use Case | Status | Notes |
|---|---|---|---|
| S06 | Search Skills | ✅ Done | SkillRepository.searchSkills and SearchPage implemented. |
| S07 | Filter Skills | ✅ Done | DiscoveryViewModel updated with level/type filters and UI chips added. |
| S08 | Browse Skills Feed | ✅ Done | SkillRepository.getRecentSkills implemented and integrated as default SearchPage view. |
| S09 | View Skill Details | ✅ Done | SkillDetailPage implemented with owner info fetching and high-fidelity UI. |

---

## 🟡 P2 — MATCHMAKING SYSTEM
| ID | Use Case | Status | Notes |
|---|---|---|---|
| M01 | Generate Matches | ✅ Done | MatchRepository and MatchViewModel implemented with skill-overlap logic and premium UI. |
| M02 | Rank Matches | ✅ Done | Multi-factor ranking algorithm (Level, Proximity, Completeness) implemented. |
| M03 | Fetch Matches | ✅ Done | Matches are now persisted and retrieved from Firestore. |
| M04 | Geo-Proximity Scoring | ✅ Done | 5-min background GPS updates and Haversine distance ranking implemented. |
| M05 | Accept Match | ✅ Done | Implemented formal acceptance/decline logic with UI feedback. |
| M06 | Reject Match | ✅ Done | Refactored generation logic to preserve user rejections. |
| M07 | Ignore Match | ✅ Done | Added 'ignored' status and UI dismissal functionality. |
| M08 | Match Filtering | ✅ Done | Implemented search and status filtering in ViewModel and UI. |

---

## 🟢 P3 — COMMUNICATION & AGREEMENT
| ID | Use Case | Status | Notes |
|---|---|---|---|
| C01 | Initiate Chat | ✅ Done | Real-time chat initiation and messaging implemented. |
| C02 | Send Message | ✅ Done | Implemented in ChatRepository and ChatViewModel. |
| C03 | Receive Message | ✅ Done | Real-time streaming implemented via Firestore snapshots. |
| C04 | Message History | ✅ Done | Automatic retrieval of past messages on room entry. |
| C05 | Read Receipts | ✅ Done | Real-time status indicators (double-check) implemented. |
| C06 | Create Agreement | ✅ Done | AgreementModel, Repository, and CreateAgreementPage implemented. |
| C07 | Accept Agreement | ✅ Done | Implemented AgreementListPage and accept/decline logic in ViewModel. |
| C08 | Modify Agreement | ✅ Done | Supported via Counter-Offer cloning and negotiation tree. |
| C09 | Cancel Agreement | ✅ Done | Added 'canceled' status and termination UI with confirmation. |

---

## 🔵 P4 — SESSION EXECUTION SYSTEM
| ID | Use Case | Status | Notes |
|---|---|---|---|
| U07 | Session Scheduling | ✅ Done | Implemented SessionModel, Repository, and high-fidelity Scheduling UI. |

---

## 🟣 P5 — TRUST, AI & PLATFORM INTELLIGENCE
*Status: All Todo*

---

## 🛡️ ADMIN SYSTEM
| ID | Use Case | Status | Notes |
|---|---|---|---|
| A01 | Admin Authentication | ✅ Done | Implemented Role-Based Access Control (RBAC) in UserModel and Router. |
| A02 | Admin Dashboard | ✅ Done | Created high-fidelity AdminDashboardPage with metrics and real-time sync. |
| A03 | System Logs | ✅ Done | Integrated 'System Activity' feed with automated audit logs. |
| A04 | User Moderation | ✅ Done | Implemented User Suspension, Promotion, and Deletion features. |
