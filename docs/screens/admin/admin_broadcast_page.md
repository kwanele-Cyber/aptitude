# Admin Broadcast Page
**Status**: Pending
**Route**: `/admin/broadcast`
**Priority**: Admin
**Use Cases Covered**: A20, A21, A22
## Purpose
Provide administrators with a message composer to send broadcast notifications to platform users. Supports audience selection (all users, specific roles), scheduling, and includes a history of past broadcasts.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [<] Broadcast Center                     |
+------------------------------------------+
|                                           |
|  +--------------------------------------+ |
|  | Compose New Broadcast               | |
|  |                                      | |
|  | Audience *                           | |
|  | [All Users                ▼] [2,847]| |
|  | Options: All Users, All Active,      | |
|  | Specific Role (Users/Admins/Mods),   | |
|  | User Segment (e.g., by skill)         | |
|  |                                      | |
|  | Title *                              | |
|  | [________________________________]  | |
|  |                                      | |
|  | Message *                            | |
|  | +----------------------------------+ | |
|  | | We're excited to announce...     | | |
|  | |                                  | | |
|  | | [B] [I] [U] [Link] [Emoji]      | | |
|  | +----------------------------------+ | |
|  | 345/2000 characters                 | |
|  |                                      | |
|  | Schedule (optional)                  | |
|  | ○ Send now                          | |
|  | ● Schedule for later                | |
|  |   [Feb 20, 2026] at [10:00 AM]    | |
|  |                                      | |
|  | Preview: [Preview as User]          | |
|  |                                      | |
|  | [Send Broadcast]                     | |
|  +--------------------------------------+ |
|                                           |
|  Recent Broadcasts                        |
|  +--------------------------------------+ |
|  | 📨 Platform Update v2.1             | |
|  | Sent: Feb 10, 2026 to 2,847 users   | |
|  | Open rate: 68% | Clicks: 23%       | |
|  | [View Stats] [Resend]               | |
|  +--------------------------------------+ |
|  | 📨 Maintenance Notice                | |
|  | Sent: Feb 5, 2026 to 2,801 users    | |
|  | Open rate: 82% | Clicks: 5%        | |
|  | [View Stats] [Resend]               | |
|  +--------------------------------------+ |
+------------------------------------------+
```

## Component Breakdown
1. **Composer Section**: Form with:
   - Audience selector dropdown with estimated recipient count
   - Title field (required)
   - Rich text message editor with formatting toolbar (bold, italic, underline, link insertion, emoji picker)
   - Character counter with limit
   - Schedule toggle: "Send Now" vs "Schedule for Later" with date/time picker
   - Preview button showing how the broadcast will appear to users
2. **Send Button**: Primary action. Sends immediately or schedules. Shows confirmation with audience size.
3. **Broadcast History**: List of past broadcasts with:
   - Title and preview snippet
   - Sent date and recipient count
   - Engagement stats (open rate, click rate)
   - [View Stats] button (detailed analytics modal)
   - [Resend] button (duplicate to composer pre-filled)
4. **Stats Modal**: Detailed breakdown per broadcast: delivery rate, open rate over time, platform breakdown (mobile vs web), geographic distribution.

## States (Loading, Empty, Error, Data)
- **Loading**: Composer skeleton and history list skeletons with shimmer.
- **Empty (No History)**: "No broadcasts sent yet." with illustration.
- **Error - Send Failed**: "Failed to send broadcast. [Retry]". "Failed to load broadcast history. [Retry]".
- **Validation Errors**: Audience required, title required, message required. Character limit exceeded warning.
- **Data**: Full composer with preview functionality. History list with stats. Pull-to-refresh for history.

## Navigation Connections
- **Incoming**: From Admin Dashboard "Broadcast" quick action, from admin sidebar.
- **Outgoing**: Send -> Confirmation dialog -> success -> history updated. Schedule -> confirmation with scheduled time. Preview -> modal showing user-facing notification appearance. View Stats -> stats modal. Resend -> pre-filled composer.

## Future Considerations
- A/B testing for broadcast messages
- Personalized merge tags ({{username}}, {{skill}})
- Automated trigger-based broadcasts (welcome, milestone)
- Multi-language broadcast support
- Push notification vs email vs in-app selection
- Recurring broadcast schedule
- Broadcast approval workflow (draft -> review -> send)
- Unsubscribe tracking
- Delivery failure reports
- Cost tracking for SMS/email channels
- Broadcast template library
- Quiet hours enforcement
