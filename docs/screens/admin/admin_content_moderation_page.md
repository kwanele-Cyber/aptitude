# Admin Content Moderation Page
**Status**: Pending
**Route**: `/admin/moderation`
**Priority**: Admin
**Use Cases Covered**: A06, A07, A08, A09, A10
## Purpose
Provide a centralized queue for reviewing and acting on flagged content across the platform (messages, reviews, profile information, session notes). Supports filtering by content type, status, and priority. Bulk selection for efficient moderation.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [<] Content Moderation                   |
+------------------------------------------+
|                                           |
|  Queue Summary: 23 pending · 12 escalated|
|                                           |
|  [Search flagged content...]         [🔍]|
|                                           |
|  Filters: [All Types ▼] [Status ▼] [Priority ▼] |
|                                           |
|  +--------------------------------------+ |
|  | ☐ | HIGH | Inappropriate msg        | |
|  |   |      | "You are so..." in chat  | |
|  |   |      | Reported by: Thandi       | |
|  |   |      | 5m ago · From: Kwanele   | |
|  |   |      | [View] [Dismiss] [Action] | |
|  +--------------------------------------+ |
|  | ☐ | MED  | Spam review              | |
|  |   |      | "Check out my..."  on    | |
|  |   |      | Busi's profile           | |
|  |   |      | 15m ago · Auto-flagged   | |
|  |   |      | [View] [Dismiss] [Action] | |
|  +--------------------------------------+ |
|  | ☐ | LOW  | Offensive avatar         | |
|  |   |      | Profile picture flagged  | |
|  |   |      | 1h ago · Auto-flagged    | |
|  |   |      | [View] [Dismiss] [Action] | |
|  +--------------------------------------+ |
|  | ☐ | HIGH | Harassment report        | |
|  |   |      | Repeated messages in     | |
|  |   |      | direct chat              | |
|  |   |      | 2h ago · Reported: Sipho | |
|  |   |      | [View] [Dismiss] [Action] | |
|  +--------------------------------------+ |
|                                           |
|  Showing 1-10 of 23  < 1 2 3 >          |
|                                           |
|  Bulk: [Dismiss] [Remove Content] [Suspend User]|
+------------------------------------------+
```

## Component Breakdown
1. **Queue Summary**: Stats bar showing total pending and escalated count. Color-coded numbers.
2. **Search Bar**: Search across flagged content text, reporter name, and reported user name.
3. **Filter Row**: Filters for Content Type (Messages, Reviews, Profiles, Notes, Images), Status (Pending, Under Review, Resolved, Dismissed), Priority (High, Medium, Low), and Date range.
4. **Flagged Item Card**: Each item shows:
   - Checkbox for bulk selection
   - Priority badge (HIGH=red, MED=yellow, LOW=gray)
   - Content preview (truncated, sensitive content blurred)
   - Report reason and context
   - Reporter name (if not anonymous)
   - Reported user name
   - Timestamp
   - Action buttons: [View] (opens detail), [Dismiss] (no action needed), [Action] (dropdown: Remove, Warn, Suspend)
5. **Pagination**: Page navigation for the queue.
6. **Bulk Action Bar**: Appears on selection. Options: Dismiss Selected, Remove Content, Warn Users, Suspend Users.
7. **Detail View Modal**: When tapping [View], shows full content context including surrounding conversation or profile details. Side-by-side view of reported content and user info.

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton queue with 5 placeholder cards (priority badge, text lines, action buttons with shimmer).
- **Empty (No Flags)**: "All clear! No flagged content pending review." with illustration (shield/checkmark). Optional: "You're up to date with moderation."
- **Empty (Filtered)**: "No items match your filters." with [Clear Filters] button.
- **Error**: "Could not load moderation queue." with [Retry] button.
- **Data**: Scrollable queue with pull-to-refresh. Real-time updates when new flags come in (notification badge). Action confirmation with undo option for dismissals.

## Navigation Connections
- **Incoming**: From Admin Dashboard "Content Moderation" quick action, from admin sidebar.
- **Outgoing**: View -> Detail modal/sheet. Action (Remove/Warn/Suspend) -> Confirmation dialog -> queue updates. Dismiss -> immediate removal from queue (with undo). Bulk actions -> confirmation -> queue updates.

## Future Considerations
- AI-assisted moderation suggestions (auto-classify priority)
- Auto-moderation rules configuration
- User warning history tracking
- Content evidence preservation for disputes
- Appeal handling for content removal
- Moderation statistics and trends
- Queue assignment to specific moderators
- Escalation workflow to senior admin
- Automated response templates for warnings
- Machine learning model training data export
- Shadow ban option (content visible only to user)
