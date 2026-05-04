# Notification List Page
**Status**: Pending
**Route**: `/notifications`
**Priority**: P5
**Use Cases Covered**: X04
## Purpose
Display a chronological list of all user notifications (matches, messages, session reminders, agreement updates, system announcements). Read/unread styling helps users prioritize their attention. Tapping a notification navigates to the relevant screen.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Notifications      [Mark All Read]|
+------------------------------------------+
|                                           |
|  Today                                    |
|  +--------------------------------------+ |
|  | ● Kwanele accepted your agreement   | |
|  |   "Python Programming"              | |
|  |   🔷 2m ago                        | |
|  +--------------------------------------+ |
|  | ● Session reminder: Python #4       | |
|  |   Tomorrow at 2:00 PM               | |
|  |   📅 15m ago                        | |
|  +--------------------------------------+ |
|                                           |
|  Yesterday                                |
|  +--------------------------------------+ |
|  | ○ New match: Thandi Nkosi           | |
|  |   Guitar Basics                      | |
|  |   🤝 1d ago                         | |
|  +--------------------------------------+ |
|  | ○ Kwanele sent you a message         | |
|  |   "See you at the library!"          | |
|  |   💬 1d ago                         | |
|  +--------------------------------------+ |
|                                           |
|  This Week                                |
|  +--------------------------------------+ |
|  | ○ Trust score updated: 78 (+2)      | |
|  |   Great session completion rate!     | |
|  |   📊 3d ago                         | |
|  +--------------------------------------+ |
|  | ○ Welcome to Aptitude!               | |
|  |   Complete your profile to get       | |
|  |   started.                           | |
|  |   🎉 5d ago                         | |
|  +--------------------------------------+ |
|                                           |
+------------------------------------------+
```

## Component Breakdown
1. **AppBar**: "Notifications" title with "Mark All Read" action (hidden when no unread).
2. **Date Section Headers**: "Today", "Yesterday", "This Week", "Earlier" grouping for chronological organization.
3. **Notification Item**: Each item shows:
   - Read/unread indicator (blue dot for unread, no dot for read)
   - Notification icon based on type (🔷=agreement, 📅=session, 🤝=match, 💬=message, 📊=trust, 🎉=system)
   - Title text (bold if unread)
   - Body/preview text (secondary, truncated to 1-2 lines)
   - Relative timestamp ("2m ago", "1d ago")
   - Swipe-to-dismiss gesture
   - Tappable -> navigates to relevant screen
4. **Mark All Read Button**: Marks all current notifications as read. Undo option via snackbar.

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton notification list with 5 items (icon, title lines, timestamp with shimmer).
- **Empty**:
  ```
  +----------------------------------+
  |                                  |
  |    [Illustration: bell]          |
  |                                  |
  |  No notifications yet            |
  |                                  |
  |  You'll see updates about        |
  |  matches, messages, and your     |
  |  skill exchange activity here.   |
  |                                  |
  +----------------------------------+
  ```
- **Error**: "Could not load notifications." with [Retry] button. Offline mode shows cached notifications with "Offline" indicator.
- **Data**: Scrollable chronological list. Pull-to-refresh. Swipe to dismiss individual notifications. Tapping navigates to context. Unread count badge updates in real-time.

## Navigation Connections
- **Incoming**: From bottom nav "Notifications" tab (or bell icon in AppBar), from push notification tap.
- **Outgoing**: Tap notification -> navigates to relevant screen (session detail, agreement detail, chat, profile, trust score, etc.). Swipe -> dismiss notification (with undo).

## Future Considerations
- Notification grouping (collapse multiple from same source)
- In-app notification sound/vibration settings
- Notification read receipts for system messages
- Rich notifications with images/buttons
- Notification categories with tab filter
- Snooze notifications for later
- Notification archive (old/dismissed)
- Push notification preference deep link
- Bulk notification management (select and dismiss)
