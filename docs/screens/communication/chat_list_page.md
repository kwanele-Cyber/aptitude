# Chat List Page
**Status**: Pending
**Route**: `/chats`
**Priority**: P3
**Use Cases Covered**: C01, C02, C03, C04
## Purpose
Display all active conversations for the current user, providing quick access to individual chats. Users can see who they are talking to, the latest message, and any unread messages at a glance.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Chats (2)        [Search icon]    |
+------------------------------------------+
|                                           |
|  +------+---------------------------+--+ |
|  | AVAT | Kwanele Mhlongo          |2 | |
|  |      | "See you at the library" |m | |
|  +------+---------------------------+--+ |
|                                           |
|  +------+---------------------------+--+ |
|  | AVAT | Thandi Nkosi             |  | |
|  |      | "Thanks for the help!"   |2 | |
|  +------+---------------------------+--+ |
|                                           |
|  +------+---------------------------+--+ |
|  | AVAT | Busi Dlamini             |  | |
|  |      | "Are we still on for..." |m | |
|  +------+---------------------------+--+ |
|                                           |
|  +------+---------------------------+--+ |
|  | AVAT | Sipho Zulu               |  | |
|  |      | "Yes, that works for me" |h | |
|  +------+---------------------------+--+ |
|                                           |
|           [ FAB - New Chat ]              |
+------------------------------------------+
```

## Component Breakdown
1. **AppBar**: Displays "Chats" title with unread count badge, back navigation, and search icon.
2. **Chat List Item**: Reusable row component containing:
   - User avatar (circular, shows first letter or profile image fallback)
   - Display name (bold if unread)
   - Last message preview (truncated to one line)
   - Timestamp (formatted: "2m", "1h", "Yesterday", "Mon")
   - Unread badge (red circle with count, hidden when 0)
3. **Floating Action Button (FAB)**: Positioned bottom-right, navigates to new chat creation.
4. **Search Bar** (expandable): Text input to filter conversations by name or message content.

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton placeholders (3-4 gray rectangles mimicking chat rows) with shimmer animation.
- **Empty**:
  ```
  +--------------------------+
  |                          |
  |    [Illustration: chat   |
  |     bubbles with ?]       |
  |                          |
  |  No conversations yet    |
  |                          |
  |  Start helping others    |
  |  and build your network  |
  |                          |
  |  [Find Matches Button]   |
  |                          |
  +--------------------------+
  ```
  Shows an illustration, "No conversations yet" heading, supportive subtitle, and a "Find Matches" CTA button that navigates to the matching screen.
- **Error**: Error illustration with "Could not load conversations" message, "Retry" button, and optional "Pull to refresh" hint.
- **Data**: Scrollable list of chat items. Pull-to-refresh supported. Each item tappable to navigate to Chat Detail.

## Navigation Connections
- **Incoming**: From bottom nav "Chats" tab, from match notification, from profile "Message" button.
- **Outgoing**: Tap item -> `/chats/:id` (Chat Detail). Tap FAB -> `/chats/new` or match selection. Search -> filtered in-place. "Find Matches" -> `/matches` or skill discovery.

## Future Considerations
- Archived conversations section (collapsible)
- Swipe-to-delete or swipe-to-archive gesture
- Pin favorite conversations to top
- Mute notifications per conversation
- Bulk select for batch archive/delete
- Online/offline presence indicators
- Typing indicators on list items
- End-to-end encryption badge
