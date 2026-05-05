# Aptitude Platform — Design Documentation

**Project**: Skill Exchange Platform
**Tech Stack**: Flutter + Firebase + BLoC
**Total Use Cases**: 98 (72 User + 26 Admin)

[ERD Diagram: ](diagrams/data_erd.md)

## UI Flow Diagrams

Navigation flow diagrams showing how screens connect across the app.

| Diagram | Status | Screens | Use Cases |
|---------|--------|---------|-----------|
| [Auth Flow](diagrams/auth_flow.md) | ✅ Complete | 13 | F01-F16 |
| [Dashboard Flow](diagrams/dashboard_flow.md) | ✅ Complete | 1 | F06, X09 |
| [Skills Flow](diagrams/skills_flow.md) | ✅ Complete | 7 | S01-S14 |
| [Matchmaking Flow](diagrams/matchmaking_flow.md) | ✅ Complete | 2 | M01-M14 |
| [Communication Flow](diagrams/communication_flow.md) | 📋 Planned | 2 | C01-C08 |
| [Agreement Flow](diagrams/agreement_flow.md) | 📋 Planned | 3 | C09-C13 |
| [Session Flow](diagrams/session_flow.md) | 📋 Planned | 7 | E01-E15 |
| [Trust & AI Flow](diagrams/trust_flow.md) | 📋 Planned | 5 | T01-T14 |
| [Notification Flow](diagrams/notification_flow.md) | 📋 Planned | 2 | X01-X04 |
| [Dispute Flow](diagrams/dispute_flow.md) | 📋 Planned | 3 | X05-X08 |
| [Progress Flow](diagrams/progress_flow.md) | 📋 Planned | 4 | X09-X14 |
| [Admin Flow](diagrams/admin_flow.md) | 📋 Planned | 12 | A01-A26 |
| [Cross-Cutting Flow](diagrams/cross_cutting_flow.md) | ✅ Reference | All | All |

## Screen Design Mockups

Design documentation for every screen — existing and planned.

### Existing Screens

<details>
<summary><b>Auth (13 screens)</b></summary>

| Screen | Route | Priority | File |
|--------|-------|----------|------|
| Splash Page | `/splash` | P0 | [View](screens/auth/splash_page.md) |
| Login Page | `/login` | P0 | [View](screens/auth/login_page.md) |
| Register Page | `/register` | P0 | [View](screens/auth/register_page.md) |
| Forgot Password | `/forgot-password` | P0 | [View](screens/auth/forgot_password_page.md) |
| Dashboard / Home | `/home` | P0 | [View](screens/auth/home_page.md) |
| Profile Page | `/profile` | P1 | [View](screens/auth/profile_page.md) |
| User Profile | `/profile/:uid` | P1 | [View](screens/auth/user_profile_page.md) |
| Change Password | `/change-password` | P1 | [View](screens/auth/change_password_page.md) |
| 2FA Setup | `/2fa-setup` | P0 | [View](screens/auth/two_factor_setup_page.md) |
| 2FA Verification | `/2fa-verify/:uid` | P0 | [View](screens/auth/two_factor_verification_page.md) |
| Recovery Codes | `/recovery-codes` | P1 | [View](screens/auth/recovery_codes_page.md) |
| Account Recovery | `/account-recovery` | P0 | [View](screens/auth/account_recovery_page.md) |
| Export Data | `/export-data` | P1 | [View](screens/auth/export_data_page.md) |
</details>

<details>
<summary><b>Skills (7 screens)</b></summary>

| Screen | Route | Priority | File |
|--------|-------|----------|------|
| Create Skill Offer/Request | `/skills/create` | P1 | [View](screens/skills/create_skill_offer_page.md) |
| Edit Skill | `/skills/edit` | P1 | [View](screens/skills/edit_skill_page.md) |
| Browse Skills Feed | `/skills/feed` | P1 | [View](screens/skills/browse_skills_feed_page.md) |
| Search Skills | `/skills/search` | P1 | [View](screens/skills/search_skills_page.md) |
| Filter Skills | `/skills/filter` | P1 | [View](screens/skills/filter_skills_page.md) |
| Skill Details | `/skills/details/:id` | P1 | [View](screens/skills/skill_details_page.md) |
| Saved Searches | `/skills/saved-searches/:uid` | P1 | [View](screens/skills/saved_searches_page.md) |
</details>

<details>
<summary><b>Matchmaking (2 screens)</b></summary>

| Screen | Route | Priority | File |
|--------|-------|----------|------|
| Matchmaking / Discover | `/matches` | P2 | [View](screens/matchmaking/matchmaking_page.md) |
| Match History | `/matches/history/:uid` | P2 | [View](screens/matchmaking/match_history_page.md) |
</details>

### Pending Screens

<details>
<summary><b>Communication (2 screens) — P3</b></summary>

| Screen | Route | Use Cases | File |
|--------|-------|-----------|------|
| Chat List | `/chats` | C01-C04 | [View](screens/communication/chat_list_page.md) |
| Chat Detail | `/chats/:id` | C02-C08 | [View](screens/communication/chat_detail_page.md) |
</details>

<details>
<summary><b>Agreement (3 screens) — P3</b></summary>

| Screen | Route | Use Cases | File |
|--------|-------|-----------|------|
| Create Agreement | `/agreements/create` | C09-C11 | [View](screens/agreement/create_agreement_page.md) |
| Agreement Detail | `/agreements/:id` | C10, C12, C13 | [View](screens/agreement/agreement_detail_page.md) |
| Modify Agreement | `/agreements/:id/modify` | C11 | [View](screens/agreement/modify_agreement_page.md) |
</details>

<details>
<summary><b>Session Execution (7 screens) — P4</b></summary>

| Screen | Route | Use Cases | File |
|--------|-------|-----------|------|
| Create Session | `/sessions/create` | E01, E06 | [View](screens/session/create_session_page.md) |
| Session Detail | `/sessions/:id` | E02, E03, E08, E09 | [View](screens/session/session_detail_page.md) |
| Session Calendar | `/sessions/calendar` | E05, E07 | [View](screens/session/session_calendar_page.md) |
| Session Check-In | `/sessions/:id/checkin` | E10, E11 | [View](screens/session/session_check_in_page.md) |
| Session Materials | `/sessions/:id/materials` | E14 | [View](screens/session/session_materials_page.md) |
| Session Notes | `/sessions/:id/notes` | E15 | [View](screens/session/session_notes_page.md) |
| Session History | `/sessions/history` | E12 | [View](screens/session/session_history_page.md) |
</details>

<details>
<summary><b>Trust & AI (5 screens) — P5</b></summary>

| Screen | Route | Use Cases | File |
|--------|-------|-----------|------|
| Rate User | `/rate/:sessionId` | T01, T02 | [View](screens/trust/rate_user_page.md) |
| User Reviews | `/profile/:uid/reviews` | T03 | [View](screens/trust/user_reviews_page.md) |
| Edit Review | `/reviews/:id/edit` | T04 | [View](screens/trust/edit_review_page.md) |
| Trust Score | `/trust-score` | T06-T09 | [View](screens/trust/trust_score_page.md) |
| Appeal Trust Score | `/trust-score/appeal` | T10 | [View](screens/trust/appeal_trust_score_page.md) |
</details>

<details>
<summary><b>Notification (2 screens) — P5</b></summary>

| Screen | Route | Use Cases | File |
|--------|-------|-----------|------|
| Notification List | `/notifications` | X04 | [View](screens/notification/notification_list_page.md) |
| Notification Preferences | `/notifications/preferences` | X03 | [View](screens/notification/notification_preferences_page.md) |
</details>

<details>
<summary><b>Dispute & Safety (4 screens) — P5</b></summary>

| Screen | Route | Use Cases | File |
|--------|-------|-----------|------|
| Report User | `/report/:userId` | X05 | [View](screens/dispute/report_user_page.md) |
| Create Dispute | `/disputes/create` | X06 | [View](screens/dispute/create_dispute_page.md) |
| Dispute Detail | `/disputes/:id` | X07, X08 | [View](screens/dispute/dispute_detail_page.md) |
| Blocked Users | `/blocked` | X16 | [View](screens/safety/blocked_users_page.md) |
</details>

<details>
<summary><b>Progress Tracking (4 screens) — P5</b></summary>

| Screen | Route | Use Cases | File |
|--------|-------|-----------|------|
| Progress Dashboard | `/progress` | X09, X10 | [View](screens/progress/progress_dashboard_page.md) |
| Learning Goals | `/goals` | X11 | [View](screens/progress/learning_goals_page.md) |
| Achievements | `/achievements` | X12 | [View](screens/progress/achievements_page.md) |
| Platform Rules | `/rules` | X13, X14 | [View](screens/progress/platform_rules_page.md) |
</details>

<details>
<summary><b>Admin (12 screens) — Admin</b></summary>

| Screen | Route | Use Cases | File |
|--------|-------|-----------|------|
| Admin Login | `/admin/login` | A01 | [View](screens/admin/admin_login_page.md) |
| Admin Dashboard | `/admin` | A02 | [View](screens/admin/admin_dashboard_page.md) |
| Role Management | `/admin/roles` | A03 | [View](screens/admin/admin_role_management_page.md) |
| Audit Log | `/admin/audit` | A04 | [View](screens/admin/admin_audit_log_page.md) |
| User Management | `/admin/users` | A05 | [View](screens/admin/admin_user_management_page.md) |
| Content Moderation | `/admin/moderation` | A06-A10 | [View](screens/admin/admin_content_moderation_page.md) |
| Analytics | `/admin/analytics` | A16, A17 | [View](screens/admin/admin_analytics_page.md) |
| Dispute Management | `/admin/disputes` | A12 | [View](screens/admin/admin_dispute_management_page.md) |
| Broadcast | `/admin/broadcast` | A20-A22 | [View](screens/admin/admin_broadcast_page.md) |
| Appeal Review | `/admin/appeals` | A14 | [View](screens/admin/admin_appeal_review_page.md) |
| Category Management | `/admin/categories` | A19 | [View](screens/admin/admin_category_management_page.md) |
| System Config | `/admin/config` | A18 | [View](screens/admin/admin_system_config_page.md) |
</details>

## Shared Widgets

| Widget | Location | Status |
|--------|----------|--------|
| [AppLoadingOverlay](widgets/app_loading_overlay.md) | `lib/core/widgets/app_loading_overlay.dart` | ✅ Implemented |

## Templates

- [Screen Mockup Template](templates/screen_mockup_template.md)
- [Diagram Template](templates/diagram_template.md)

## Reference

- [Use Case Tracker](../use_case_tracker.md)
- [Data ERD](diagrams/data_erd.md) — complete entity-relationship diagram
