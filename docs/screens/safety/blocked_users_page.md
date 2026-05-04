# Blocked Users Page
**Status**: Pending
**Route**: `/blocked`
**Priority**: P5
**Use Cases Covered**: X16
## Purpose
Display a list of users the current user has blocked. Each entry shows the blocked user's avatar and name with an "Unblock" button. Provides an empty state when no users are blocked.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Blocked Users                    |
+------------------------------------------+
|                                           |
|  +--------------------------------------+ |
|  | [Avatar] Thandi Nkosi               | |
|  |  @thandi_nkosi                       | |
|  |  Blocked: Feb 10, 2026              | |
|  |                          [Unblock]   | |
|  +--------------------------------------+ |
|  +--------------------------------------+ |
|  | [Avatar] Busi Dlamini               | |
|  |  @busi_d              -              | |
|  |  Blocked: Jan 25, 2026              | |
|  |                          [Unblock]   | |
|  +--------------------------------------+ |
|                                           |
|  Blocked users will not be able to:       |
|  - Send you messages                      |
|  - View your profile                      |
|  - Match with you                         |
|  - Join any agreements you're in          |
|                                           |
|  [Need help? Contact Support]             |
+------------------------------------------+
```

## Component Breakdown
1. **Blocked User Item**: Each card shows:
   - User avatar (circular, default fallback)
   - Display name
   - Username handle
   - Blocked date ("Blocked: Feb 10, 2026")
   - [Unblock] button (secondary/destructive style)
2. **Info Footer**: Explanation of what blocking entails (cannot message, view profile, match, etc.).
3. **Support Link**: Contact support link at the bottom for help with blocking-related issues.
4. **Unblock Confirmation Dialog**: When tapping "Unblock":
   - Title: "Unblock [username]?"
   - Body: "They will be able to message you and view your profile again."
   - [Cancel] [Unblock] buttons

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton list with 3 placeholder items (avatar circle, name lines, button block with shimmer).
- **Empty**:
  ```
  +----------------------------------+
  |                                  |
  |    [Illustration: shield]        |
  |                                  |
  |  No blocked users                |
  |                                  |
  |  When you block someone, they    |
  |  will appear here. You can       |
  |  always unblock them later.      |
  |                                  |
  +----------------------------------+
  ```
- **Error**: "Could not load blocked users list." with [Retry] button. Unblock error: "Failed to unblock user. [Retry]" shown as toast.
- **Data**: Scrollable list of blocked users. Each item has unblock action. Pull-to-refresh.

## Navigation Connections
- **Incoming**: From Settings "Privacy" or "Blocked Users", from Chat overflow menu "Block User" (redirect after block action).
- **Outgoing**: Unblock -> Confirmation dialog -> on success, remove item from list (with undo snackbar). Tap user item -> could navigate to user profile (in read-only/blocked state). Contact Support -> support channel.

## Future Considerations
- Block reason display (visible only to the blocker)
- Block expiry options (temporary block: 24h, 7d, 30d, permanent)
- Blocked user's perspective (what do they see?)
- Report user directly from blocked list
- Block list search
- Import/export block list
- Block notifications (when blocked user tries to interact)
- Bulk unblock option
- Block appeal for blocked users (handled by admin)
