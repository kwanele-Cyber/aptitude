# Create Session Page
**Status**: Pending
**Route**: `/sessions/create?agreementId=:id`
**Priority**: P4
**Use Cases Covered**: E01, E06
## Purpose
Allow users to schedule individual skill exchange sessions within an active agreement. Captures date, time, location/format, and optional recurring schedule.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Cancel]  Schedule Session               |
+------------------------------------------+
|                                           |
|  Agreement: Python Programming           |
|  Partner: Kwanele Mhlongo                |
|  Format: Video Call                      |
|                                           |
|  Date & Time                              |
|  +--------------------------------------+ |
|  | [Feb, 2026                     v]    | |
|  |                                      | |
|  |  Mo Tu We Th Fr Sa Su               | |
|  |      1  2  3  4  5  6               | |
|  |   7  8  9 10 11 12 13               | |
|  |  14 15 16 17 18 19 20               | |
|  |  21 22 23 24 25 26 27               | |
|  |  28                                  | |
|  |                                      | |
|  |  Start Time: [10:00 AM ▼]           | |
|  |  End Time:   [11:00 AM ▼]           | |
|  +--------------------------------------+ |
|                                           |
|  Session Format                            |
|  ● Video   ○ In-person   ○ Hybrid        |
|  Link: meet.google.com/abc-defg-hij       |
|                                           |
|  [Recurring Session]                      |
|  +--[Toggle: OFF]------------------------+ |
|  |  Repeat every week                  | |
|  |  End after [8] occurrences          | |
|  +--------------------------------------+ |
|                                           |
|  Notes (optional)                         |
|  +--------------------------------------+ |
|  | Remember to bring code samples!     | |
|  +--------------------------------------+ |
|                                           |
|  [Schedule Session]                       |
+------------------------------------------+
```

## Component Breakdown
1. **Agreement Context Header**: Shows parent agreement title, partner name, and default format (read-only summary from agreement).
2. **Date Picker**: Interactive calendar month view. Left/right arrows to change month. Tapping a date selects it. Dates outside agreement date range are grayed out.
3. **Time Picker**: Start time and end time dropdowns with 30-minute increments. End time validation (must be after start time). Shows timezone.
4. **Format Selector**: Pre-filled from agreement but adjustable per session. Radio cards with icons.
5. **Location/Link Field**: Dynamic based on format selection. Pre-filled from agreement terms.
6. **Recurring Toggle**: Switch to enable recurring sessions. Expands to show repeat frequency (weekly/biweekly/monthly), end condition (after N occurrences or end date).
7. **Notes Field**: Optional text area for session-specific notes or agenda.
8. **Submit Button**: "Schedule Session" primary button. Validates all required fields.

## States (Loading, Empty, Error, Data)
- **Loading**: Calendar and form skeleton with shimmer. Date picker grayed out until loaded.
- **Empty (No Agreement)**: If no `agreementId` provided, redirect to agreement selection or show "Select an agreement first" with list.
- **Error - Validation**: Time conflict error ("You have another session at this time"), past date error, end-before-start error. API error banner.
- **Error - No Active Agreement**: "Cannot create session without an active agreement. [Create Agreement]".
- **Data**: Fully interactive form. Calendar shows existing sessions as marked dots if data available. Submit creates session(s) and navigates to session detail or calendar.

## Navigation Connections
- **Incoming**: From Agreement Detail "Schedule Session", from Calendar "Add" button, from quick action. `agreementId` query param pre-fills context.
- **Outgoing**: Cancel -> Confirm discard -> back. Submit -> `/sessions/:id` (single) or `/sessions/calendar` (recurring success).

## Future Considerations
- Drag-to-select multiple dates for recurring
- Timezone detection and display
- Video platform auto-generation (Meet/Zoom links)
- Calendar integration (Google/Outlook sync)
- Session buffer time (15min gap before/after)
- Conflict detection across all agreements
- Suggested time slots based on past session patterns
