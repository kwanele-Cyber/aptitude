# Agreement Detail Page
**Status**: Pending
**Route**: `/agreements/:id`
**Priority**: P3
**Use Cases Covered**: C10, C12, C13
## Purpose
Display the full details of a skill exchange agreement, including current status, terms, and parties involved. Provides contextual action buttons based on the agreement status (pending, active, completed, cancelled, etc.).
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Agreement Details  [⋮ Overflow]  |
+------------------------------------------+
|                                           |
|  +--------------------------------------+ |
|  |  PENDING                             | |
|  |  Awaiting partner response            | |
|  |  [Icon: Clock]                        | |
|  +--------------------------------------+ |
|                                           |
|  Python Programming                       |
|  You are the Learner                      |
|                                           |
|  +--------------------------------------+ |
|  | Partner: Kwanele Mhlongo    [View >] | |
|  | Rating: ★★★★☆  4.8                  | |
|  | Matches: 12 completed                 | |
|  +--------------------------------------+ |
|                                           |
|  📅 Terms                                 |
|  Duration:  8 weeks (Feb 1 - Mar 28)     |
|  Frequency: 2 sessions / week            |
|  Format:    Video Call                    |
|  Location:  meet.google.com/abc-defg-hij |
|                                           |
|  📝 Notes                                 |
|  "Looking forward to learning Python!"    |
|                                           |
|  +--------------------------------------+ |
|  | [Accept]  [Modify]  [Decline]       | |
|  +--------------------------------------+ |
|                                           |
+------------------------------------------+
```

## Component Breakdown
1. **Status Banner**: Color-coded banner at top (blue = pending, green = active, yellow = modified, red = declined/cancelled, gray = completed). Shows status text, description, and relevant icon.
2. **Skill Title**: Large heading with the skill name and role badge ("Teacher" or "Learner").
3. **Partner Info Card**: Avatar, name (tappable -> profile), rating, completed match count. "View Profile" link.
4. **Terms Section**: Structured display of duration (with date range), frequency, format, and location/link. Each field has an icon for visual scanning.
5. **Notes Section**: Partner's notes from agreement creation. Only shown if notes exist.
6. **Action Buttons Area**: Contextual button set based on agreement status:
   - **Pending** (current user is recipient): [Accept] [Modify] [Decline]
   - **Pending** (current user is sender): "Awaiting response..." text, [Cancel Proposal]
   - **Active**: [View Sessions] [Complete Agreement] [Report Issue]
   - **Modified** (received): [Accept Changes] [Decline Changes]
   - **Modified** (sent): "Awaiting response to modifications..."
   - **Completed**: [Review Partner] [View Sessions] [Create New Agreement]
   - **Cancelled/Declined**: Status reason text, [Dismiss]
7. **Overflow Menu**: Options vary by status: View all sessions, Cancel agreement (with reason), Report issue.

## States (Loading, Empty, Error, Data)
- **Loading**: Full-page skeleton with status banner placeholder, info card, terms section, and button area gray blocks with shimmer.
- **Error**: Error state with "Could not load agreement details." message, [Retry] button, and [Go Back] option. Specific error for "Agreement not found" with 404-style illustration.
- **Data**: Fully populated agreement detail with status-appropriate actions. Pull-to-refresh supported. Real-time status updates via WebSocket (if partner responds while viewing).

## Navigation Connections
- **Incoming**: From Agreement List, from notification (agreement proposal, acceptance, modification), from match profile.
- **Outgoing**: Accept -> Confirmation dialog -> redirect to session creation. Modify -> `/agreements/:id/modify`. Decline -> Confirmation with reason dialog -> back to list. View Profile -> `/profile/:uid`. View Sessions -> `/sessions` filtered by agreement.

## Future Considerations
- Countdown timer for pending acceptance (auto-decline after 72 hours)
- Agreement PDF export
- Share agreement summary via link
- Milestone tracking with progress indicators
- Session history directly within agreement view
- Collaborative calendar showing scheduled sessions
- Agreement renegotiation history timeline
- Two-way rating display for matched users
