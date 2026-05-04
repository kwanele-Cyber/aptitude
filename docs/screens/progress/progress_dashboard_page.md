# Progress Dashboard Page
**Status**: Pending
**Route**: `/progress`
**Priority**: P5
**Use Cases Covered**: X09, X10
## Purpose
Provide a comprehensive overview of the user's skill exchange journey. Displays key statistics (sessions completed, skills learned, hours exchanged), progress bars per skill area, achievement badges, and recent activity feed.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  My Progress         [Share]      |
+------------------------------------------+
|                                           |
|  Welcome back, Kwanele!                  |
|  Member since Jan 2026                    |
|                                           |
|  Stats Summary                            |
|  +----------+----------+----------+      |
|  | 📅       | 🎯       | ⏱       |      |
|  | 12       | 3        | 24h     |      |
|  | Sessions | Skills   | Hours   |      |
|  | Completed| Learned  | Exchanged|     |
|  +----------+----------+----------+      |
|                                           |
|  Skill Progress                            |
|  +--------------------------------------+ |
|  | Python Programming     ██████░░ 60% | |
|  |   Session 6/10  ·  Last: Feb 15    | |
|  +--------------------------------------+ |
|  | Guitar Basics          ████░░░░ 40% | |
|  |   Session 2/5  ·  Last: Feb 10    | |
|  +--------------------------------------+ |
|  | Photography            ██░░░░░░ 20% | |
|  |   Session 1/5  ·  Last: Feb 5     | |
|  +--------------------------------------+ |
|                                           |
|  Achievements                              |
|  +--------------------------------------+ |
|  | [🏆] [🏅] [🔒] [🔒] [🔒]         | |
|  | Early  5Sessions 10Sess  25Sess  50Sess|
|  | Bird   Streak    Streak  Streak  Streak |
|  +--------------------------------------+ |
|  [View All Achievements >]                |
|                                           |
|  Recent Activity                           |
|  +--------------------------------------+ |
|  | ✅ Completed Python #4 with Kwanele | |
|  |    Feb 15, 2026 · 1h                | |
|  +--------------------------------------+ |
|  | ⭐ Rated Thandi 5 stars             | |
|  |    Feb 14, 2026                      | |
|  +--------------------------------------+ |
|  | 📝 Added notes to Guitar #2          | |
|  |    Feb 10, 2026                      | |
|  +--------------------------------------+ |
|                                           |
+------------------------------------------+
```

## Component Breakdown
1. **Welcome Header**: User greeting with membership date. Share button for profile progress.
2. **Stats Cards**: Three-card row showing key metrics with icons:
   - Sessions Completed (count)
   - Skills Learned/Teaching (count)
   - Hours Exchanged (total hours)
   Each card has subtle animation on load (count-up effect).
3. **Skill Progress Section**: List of skills with:
   - Horizontal progress bar (color-coded per skill)
   - Percentage label
   - Session progress text ("Session 6/10")
   - Last session date
   - Tappable -> navigate to agreement detail
4. **Achievement Badge Row**: Horizontal scrollable row of earned/locked badges. Shows 5 with "View All" link. Badges: small circular icons with locked overlay for unearned ones.
5. **Recent Activity Feed**: Chronological list of recent actions:
   - Session completed
   - Rating given
   - Notes added
   - Achievement earned
   - Each item: icon, description, date, and relevant metadata.

## States (Loading, Empty, Error, Data)
- **Loading**: Full skeleton layout: stats cards (3 rectangles), progress bars, badge row circles, activity feed items with shimmer.
- **Empty (New User)**:
  ```
  +----------------------------------+
  |                                  |
  |    [Illustration: growth chart]  |
  |                                  |
  |  Start your learning journey!    |
  |                                  |
  |  Complete your first session     |
  |  to see your progress here.      |
  |                                  |
  |  [Find a Skill Exchange]         |
  |                                  |
  +----------------------------------+
  ```
  Stats show 0, no progress bars, no achievements, empty activity.
- **Error**: "Could not load progress data." with [Retry] button. Partial load shows cached data if available.
- **Data**: Full interactive dashboard with animated stats. Pull-to-refresh. Tappable elements for deeper navigation.

## Navigation Connections
- **Incoming**: From bottom nav "Progress" tab, from profile "View Progress" link.
- **Outgoing**: View All Achievements -> `/achievements`. Skill progress bar -> `/agreements/:id`. Activity item -> relevant session/agreement/rating. Share -> Share progress card image. Find Skills -> skill discovery.

## Future Considerations
- Custom date range for stats
- Weekly/monthly progress comparison
- Learning streak calendar (GitHub-style contribution graph)
- Time spent learning vs teaching breakdown
- Skill mastery level (Beginner -> Intermediate -> Advanced -> Expert)
- Goals link to trigger goals setting
- Personalized learning recommendations
- Social sharing of progress milestones
- Mentor/peer progress comparison (opt-in)
- Download progress report (PDF/CSV)
