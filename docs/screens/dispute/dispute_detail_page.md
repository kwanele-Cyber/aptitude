# Dispute Detail Page
**Status**: Pending
**Route**: `/disputes/:id`
**Priority**: P5
**Use Cases Covered**: X07, X08
## Purpose
Display the full status and details of a dispute, including a timeline of events, messages between parties and admin, attached evidence, and current resolution status. Provides an appeal button if the dispute has been resolved unfavorably.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Dispute #D-2026-0042             |
+------------------------------------------+
|                                           |
|  +--------------------------------------+ |
|  | UNDER REVIEW                         | |
|  | Our team is investigating your case  | |
|  | Estimated resolution: 5-7 days       | |
|  | [Icon: Search]                       | |
|  +--------------------------------------+ |
|                                           |
|  Issue: Partner did not show up           |
|  Reported: Feb 16, 2026                   |
|  Against: Kwanele Mhlongo                |
|  Session: Python #4 (Feb 15, 2026)       |
|  Desired Outcome: Reschedule session      |
|                                           |
|  Timeline                                 |
|  +--------------------------------------+ |
|  | 🔵 Feb 15, 2:00 PM - Session        | |
|  |    scheduled                         | |
|  | 🔴 Feb 15, 2:30 PM - No-show        | |
|  |    reported                          | |
|  | 🟡 Feb 16, 10:00 AM - Dispute       | |
|  |    opened                            | |
|  | 🟡 Feb 16, 3:00 PM - Evidence       | |
|  |    submitted                         | |
|  | 🟡 Feb 17, 11:00 AM - Admin         | |
|  |    assigned                          | |
|  +--------------------------------------+ |
|                                           |
|  Messages                                  |
|  +--------------------------------------+ |
|  | Admin (Feb 17):                      | |
|  | "Thank you for your report. We are  | |
|  | reviewing the evidence and will     | |
|  | contact both parties shortly."      | |
|  +--------------------------------------+ |
|  +--------------------------------------+ |
|  | You (Feb 16):                        | |
|  | "I have attached the chat logs      | |
|  | showing I was at the location."     | |
|  +--------------------------------------+ |
|                                           |
|  Evidence                                  |
|  [screenshot_1.png] [screenshot_2.png]    |
|  [chat_log.pdf]                           |
|                                           |
|  [Add Message]  [Add Evidence]            |
|                                           |
|  [Appeal Decision]  [Cancel Dispute]      |
+------------------------------------------+
```

## Component Breakdown
1. **Status Banner**: Color-coded status indicator: red=opened, yellow=under review, green=resolved, blue=appealed, gray=closed. Shows current status text, brief description, and estimated resolution time.
2. **Dispute Info Card**: Dispute ID, issue category, date reported, reported user (tappable), related session/agreement link, desired outcome.
3. **Timeline**: Chronological list of all dispute events. Each entry has:
   - Color-coded dot (status per event)
   - Date and time
   - Event description
   - Auto-scrolls to latest event
4. **Messages Section**: Thread of messages between user, other party, and admin. Styled like a chat. Each message shows sender role badge, timestamp, and content.
5. **Evidence Section**: Thumbnail grid of attached evidence files. Tappable to expand/fullscreen. File name and size labels.
6. **Action Buttons**: Context-sensitive:
   - [Add Message] - Send a message to the dispute thread
   - [Add Evidence] - Upload additional evidence
   - [Appeal Decision] - Only shown when dispute is resolved unfavorably
   - [Cancel Dispute] - Withdraw the dispute (only when status is Opened/Under Review)
7. **Overflow Menu**: Contact support, view related agreement, view related session.

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton layout with status banner, info card, timeline, and message placeholders with shimmer.
- **Error - Not Found**: "Dispute not found" with [Go Back] button.
- **Error - Access Denied**: "You do not have access to this dispute."
- **Data**: Fully detailed dispute view with interactive timeline and message thread. Real-time updates when admin responds (WebSocket). Pull-to-refresh.

## Navigation Connections
- **Incoming**: From Create Dispute (redirect after creation), from notification (dispute update), from support page, from admin panel (admin only).
- **Outgoing**: Appeal -> `/trust-score/appeal` or dedicated appeal flow. View Session -> `/sessions/:id`. View Agreement -> `/agreements/:id`. Cancel Dispute -> Confirmation dialog -> refresh. Contact Support -> support chat/email.

## Future Considerations
- Live chat with admin/moderator within dispute
- Video call mediation option
- Automated resolution suggestions based on evidence
- Dispute outcome summary report download
- Time limits for each party to respond
- Two-party negotiation space within dispute
- Third-party witness participation
- Dispute satisfaction survey after resolution
- Precedent-based resolution suggestions
- Multi-language support for disputes
