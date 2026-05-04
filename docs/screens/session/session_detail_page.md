# Session Detail Page
**Status**: Pending
**Route**: `/sessions/:id`
**Priority**: P4
**Use Cases Covered**: E02, E03, E08, E09
## Purpose
Display all details of a specific session including its status timeline, session info, and contextual action buttons. Serves as the hub for starting, completing, or cancelling sessions and accessing related materials and notes.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Session Details    [⋮ Overflow]  |
+------------------------------------------+
|                                           |
|  +--------------------------------------+ |
|  |  UPCOMING                            | |
|  |  Scheduled for Feb 15, 2:00 PM       | |
|  |  [Icon: Calendar]                    | |
|  +--------------------------------------+ |
|                                           |
|  Python Programming - Session #4         |
|  with Kwanele Mhlongo                     |
|                                           |
|  +--------------------------------------+ |
|  | 📅 Thu, Feb 15, 2026                | |
|  | 🕐 2:00 PM - 3:00 PM (1 hour)       | |
|  | 📍 Video: meet.google.com/xxx       | |
|  | 📋 Agreement: Python Tutoring       | |
|  +--------------------------------------+ |
|                                           |
|  Session Progress                         |
|  ●●●○○○○○○○  3 of 10 sessions completed |
|                                           |
|  +--------------------------------------+ |
|  | [Join Session]  [Cancel] [Reschedule]| |
|  +--------------------------------------+ |
|                                           |
|  Quick Links                               |
|  [📄 Materials]  [📝 Session Notes]      |
|  [✅ Check In]                             |
|                                           |
+------------------------------------------+
```

## Component Breakdown
1. **Status Banner**: Color-coded status (blue=upcoming, green=in-progress, gray=completed, red=cancelled, yellow=checked-in). Shows status text and the next relevant date/time.
2. **Session Header**: Skill name with session number, partner name with avatar. Tappable -> partner profile.
3. **Info Card**: Structured display of date, time (with duration), location/link (tappable for video platforms), and parent agreement link.
4. **Progress Bar**: Visual indicator showing completed sessions vs remaining within the agreement (e.g., 3 of 10). Only shown if part of a multi-session agreement.
5. **Action Buttons**: Context-dependent:
   - **Upcoming (within 15 min)**: [Join Session] [Reschedule] [Cancel]
   - **Upcoming (>15 min away)**: [Remind Me] [Reschedule] [Cancel]
   - **Checked In**: [Start Session] [Cancel]
   - **In Progress**: [Complete Session] [Mark Absent]
   - **Completed**: [Review Partner] [View Materials] [View Notes]
   - **Cancelled**: Status reason shown. [Reschedule] [Dismiss]
6. **Quick Links Section**: Icons/cards linking to:
   - Session Materials (uploaded files, resources)
   - Session Notes (collaborative document)
   - Check In (QR/geolocation verification)
7. **Overflow Menu**: Options: View Agreement, Report Issue, View Session History, Share Session Link.

## States (Loading, Empty, Error, Data)
- **Loading**: Full skeleton layout with status banner placeholder, info card, and button area shimmer.
- **Error - Not Found**: "Session not found" with illustration, [Go Back] button.
- **Error - Access Denied**: "You don't have access to this session" with support contact option.
- **Data**: Fully populated session with status-appropriate actions. Pull-to-refresh for status updates. Real-time countdown for upcoming sessions.

## Navigation Connections
- **Incoming**: From Calendar (tap session), from agreement view, from notification (session reminder, session started), from check-in flow.
- **Outgoing**: Join Session -> external video link or in-app video UI. Check In -> `/sessions/:id/checkin`. Materials -> `/sessions/:id/materials`. Notes -> `/sessions/:id/notes`. Review -> `/rate/:sessionId`. Agreement -> `/agreements/:id`. Cancel -> Confirmation dialog with reason -> back.

## Future Considerations
- In-app video call integration
- Session recording links
- Session feedback prompt after completion
- Automatic session extension option
- Emergency contact/share location during session
- Session timeout handling (no-show detection)
- Session attendance confirmation by both parties
