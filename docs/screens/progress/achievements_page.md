# Achievements Page
**Status**: Pending
**Route**: `/achievements`
**Priority**: P5
**Use Cases Covered**: X12
## Purpose
Display all achievements/badges available on the platform, showing which the user has earned (unlocked) and which are still locked. Each badge has a description and unlock criteria. Shareable earned badges for social proof.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Achievements                     |
+------------------------------------------+
|                                           |
|  12 of 24 badges earned                   |
|  [All / Unlocked / Locked]               |
|                                           |
|  +--------------------------------------+ |
|  | [🏆] [🏅] [⭐] [🔒] [🔒]          | |
|  | Early  5Sess  10Sess 25Sess 50Sess  | |
|  | Bird   Streak  Streak Streak Streak  | |
|  | Unlocked                             | |
|  +--------------------------------------+ |
|                                           |
|  +--------------------------------------+ |
|  | [🔒] [🔒] [🔒] [🔒] [🔒]          | |
|  | 100Sess Mentor  Rater  Photo  Profile| |
|  | Streak  Badge  Badge  Upload Completer|
|  | Locked  Locked  Locked Locked Locked  | |
|  +--------------------------------------+ |
|                                           |
|  +--------------------------------------+ |
|  | [🔒] [🔒] [🔒] [🔒] [🔒]          | |
|  | First  5Skills 3Month  Helper  Social | |
|  | Teach  Badge   Streak  Badge   Badge  | |
|  | Locked  Locked  Locked  Locked  Locked| |
|  +--------------------------------------+ |
|                                           |
|  [Share My Badges]                        |
+------------------------------------------+
```

## Component Breakdown
1. **Summary Header**: Total count of earned badges ("12 of 24 badges earned"). Shows overall completion percentage.
2. **Filter Tabs**: Segmented control [All / Unlocked / Locked] to filter the badge grid.
3. **Badge Grid**: Responsive grid of badge cards, each showing:
   - Badge icon/illustration (distinct per badge, color for unlocked, grayscale with lock overlay for locked)
   - Badge name
   - Status label: "Unlocked" with date or "Locked" with unlock criteria
   - Rarity indicator (Common, Rare, Epic, Legendary) with color-coded border
4. **Badge Detail Popup**: Tapping a badge opens a detail view:
   - Large badge illustration with animation
   - Badge name and description
   - Unlock criteria and progress (if locked: "Complete 10 sessions - 7/10 done")
   - Date unlocked (if earned)
   - [Share Badge] button for earned badges
5. **Share Button**: Bottom button or per-badge action to share earned badges to social media or as image.

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton grid of badge placeholders (gray circles/squares with shimmer).
- **Empty (No Badges)**:
  ```
  +----------------------------------+
  |                                  |
  |    [Illustration: trophy]        |
  |                                  |
  |  No achievements yet             |
  |                                  |
  |  Complete sessions, earn ratings,|
  |  and build your streak to unlock |
  |  badges and recognition.         |
  |                                  |
  |  [Explore Available Badges]      |
  |                                  |
  +----------------------------------+
  ```
- **Error**: "Could not load achievements." with [Retry] button.
- **Data**: Full badge grid with filter tabs. Earned badges pop with color and animation. Locked badges show clear unlock path. Pull-to-refresh. Tapping badge shows detail popup.

## Navigation Connections
- **Incoming**: From Progress Dashboard "View All Achievements", from profile "Badges" section.
- **Outgoing**: Share -> System share sheet with badge image. Badge detail -> popup overlay. Filter tab -> updates grid in-place. Explore Badges -> scrolls to show all badges.

## Future Considerations
- Badge leveling (Bronze/Silver/Gold tiers per badge)
- Secret/hidden badges with surprise unlock
- Seasonal or limited-time badges
- Badge notification on unlock
- Badge display on user profile
- Badge comparison with partners
- Badge trading or gifting (social feature)
- Animated badge collection page
- Badge-earned push notification
- Server-wide achievement milestones
- Badge points system for leaderboard
