# Home Page

**Status**: Existing
**Route**: `/home`
**Priority**: P0
**Use Cases Covered**: F06, X09

## Purpose
Main dashboard after authentication. Uses an `IndexedStack` with four bottom-nav tabs: Explore, Matches, Messages, Profile. The Explore tab features a gradient `SliverAppBar` with a search field. The Profile tab shows the authenticated user's avatar and stats in a gradient header, plus menu links to settings pages.

## Layout Description
```
+------------------------------------------+
|  Explore Tab (default)                   |
|  =======================                  |
|  +------------------------------------+  |
|  |  [Gradient SliverAppBar - 200px]  |  |
|  |  "Discover Skills"                |  |
|  |  "Learn, teach, and grow together"|  |
|  |  [ Search skills...           🔍 ]|  |
|  +------------------------------------+  |
|                                          |
|  Quick Actions                           |
|  +----------+  +----------+              |
|  | Offer    |  | Learn    |              |
|  | Skill    |  | Skill    |              |
|  +----------+  +----------+              |
|                                          |
|  Browse Feed            [View all]       |
|  [Card][Card][Card][Card] (horizontal)   |
|                                          |
|  More                                    |
|  [Match History >]                       |
|  [Filter Skills >]                       |
|  [Saved Searches >]                      |
|                                          |
+------------------------------------------+
|  [Explore][Matches][Messages][Profile]   |
+------------------------------------------+
```

## Component Breakdown
| Component | Type | Description |
|-----------|------|-------------|
| Scaffold | Structural | Root widget with `IndexedStack` body and `BottomNavigationBar` |
| BottomNavigationBar | Navigation | 4 tabs: Explore, Matches, Messages, Profile; fixed type with shadow; selected/unselected colors |
| IndexedStack | Layout | Switches between 4 tab widgets without rebuilding |
| SliverAppBar (Explore) | Layout | Expanded height 200px, pinned, gradient background (primary to secondary) |
| TextField (Explore search) | Input | Read-only search field; on tap navigates to `/skills/search` |
| _QuickActionCard | Card | Two cards: "Offer Skill" and "Learn Skill", navigates to create forms |
| _FeedPreviewCard | Card | Horizontal scrollable feed preview with category cards |
| _MenuGridTile | ListTile | Menu items with chevron icons for secondary settings |
| _MatchesTab | Scaffold | Embeds `MatchmakingPage` with filter button |
| _MessagesTab | Scaffold | Empty state with "No messages yet" placeholder and "Find Matches" button |
| _ProfileTab | Widget | Profile header with gradient, avatar initials, stats (Skills/Matches/Rating), and menu items |

## States - Loading, Empty, Error, Data Populated
| State | Description |
|-------|-------------|
| Loading | Profile tab shows centered `CircularProgressIndicator` when auth state is not `AuthAuthenticated` |
| Empty | Messages tab shows empty-state illustration with "No messages yet" text |
| Error | Not directly handled on this page (error states are on child tabs/screens) |
| Data Populated | Explore tab shows feed previews and actions; Profile tab shows user data from `AuthAuthenticated.userEntity` |

## Navigation Connections
- **Entry**: `/home` (protected route, after authentication)
- Router initial redirect: if `AuthAuthenticated` and at `/login`, redirects to `/home`
- Explore tab links: `/skills/search`, `/skills/feed`, `/skills/create`, `/skills/create-request`, `/matches/history/:uid`, `/skills/filter`, `/skills/saved-searches/:uid`
- Profile tab links: `/change-password`, `/2fa-setup`, `/matches/history/:uid`, `/export-data`, `/account-recovery`
- AuthBloc event dispatched on logout: `AuthLogoutRequested`
- MatchBloc event dispatched on init: `FetchMatchesRequested(userId)`
