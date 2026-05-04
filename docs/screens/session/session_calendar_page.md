# Session Calendar Page
**Status**: Pending
**Route**: `/sessions/calendar`
**Priority**: P4
**Use Cases Covered**: E05, E07
## Purpose
Provide a visual calendar view of all scheduled sessions across agreements. Supports monthly and weekly views. Sessions appear as dots/markers on dates, and tapping a date reveals the day's session list.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  My Sessions            [Today]   |
+------------------------------------------+
|  [Monthly ▼]  Feb 2026   [<] [>]        |
+------------------------------------------+
|  Mo  Tu  We  Th  Fr  Sa  Su             |
|                                     1    |
|   2   3   4   5   6   7   8             |
|            ●           ●                 |
|   9  10  11  12  13  14  15             |
|    ●           ●        ●   ●           |
|  16  17  18  19  20  21  22             |
|   ●               ●                     |
|  23  24  25  26  27  28                 |
|       ●                                 |
+------------------------------------------+
|                                           |
|  Selected: Thu, Feb 15, 2026             |
|  +--------------------------------------+ |
|  | 🕐 10:00 AM - 11:00 AM              | |
|  | Python Programming #4               | |
|  | with Kwanele Mhlongo                | |
|  | [Status: Upcoming]   [View >]       | |
|  +--------------------------------------+ |
|  | 🕐 2:00 PM - 3:00 PM               | |
|  | Guitar Basics #2                    | |
|  | with Thandi Nkosi                   | |
|  | [Status: Upcoming]   [View >]       | |
|  +--------------------------------------+ |
|                                           |
|  [Schedule New Session]                   |
+------------------------------------------+
```

## Component Breakdown
1. **AppBar**: "My Sessions" title, [Today] button to jump to current date, optional filter icon.
2. **View Toggle**: Segmented control [Monthly / Weekly] to switch between calendar view modes.
3. **Month/Week Navigation**: Current month/year label with left/right arrow buttons for navigation. Swipeable on mobile.
4. **Calendar Grid**:
   - Day-of-week headers (Mon-Sun or Sun-Sat based on locale).
   - Day cells with number. Current day highlighted with accent border.
   - Session indicator dots below the date number. Color-coded: blue=upcoming, green=completed, red=cancelled. Max 3 dots shown, "+N" overflow.
   - Past dates slightly dimmed. Future dates full opacity.
5. **Selected Date Panel** (bottom): When a date is tapped, expands to show a list of the day's sessions. Each item shows time, skill title, partner name, status badge, and "View" arrow.
6. **Schedule Button**: FAB or bottom button to create a new session from the calendar.
7. **Weekly View Alternative**: Shows 7-day columns with time slots (24h or business hours). Sessions as colored blocks spanning their duration.

## States (Loading, Empty, Error, Data)
- **Loading**: Calendar grid skeleton with gray day cells and shimmer. Bottom panel shows placeholder list items.
- **Empty (No Sessions)**:
  ```
  +----------------------------------+
  |                                  |
  |    [Illustration: calendar with  |
  |     no events]                    |
  |                                  |
  |  No sessions scheduled           |
  |                                  |
  |  Start by creating an agreement  |
  |  and scheduling your first       |
  |  skill exchange session.         |
  |                                  |
  |  [Create Agreement]              |
  |                                  |
  +----------------------------------+
  ```
- **Error**: "Could not load calendar" with [Retry] button. Offline mode shows cached sessions if available.
- **Data**: Interactive calendar with navigation. Tapping a date updates the bottom panel. Pull-to-refresh syncs latest changes. Real-time updates for new/cancelled sessions.

## Navigation Connections
- **Incoming**: From bottom nav "Sessions" tab, from agreement detail "View Calendar", from notification.
- **Outgoing**: Tap session item -> `/sessions/:id`. Tap "Schedule New Session" -> `/sessions/create`. Tap "Create Agreement" -> `/agreements/create`. Tap date -> updates bottom panel (in-page).

## Future Considerations
- Agenda/list view as third view mode
- Color-coded sessions by agreement/skill
- Drag-and-drop to reschedule (long press session)
- Week number display
- Calendar export (.ics file)
- Sync with external calendars (Google Calendar, Outlook)
- Session count badge on each date
- Hide/show specific agreements on calendar
- Mini-calendar in agreement detail page
