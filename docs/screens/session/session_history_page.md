# Session History Page
**Status**: Pending
**Route**: `/sessions/history`
**Priority**: P4
**Use Cases Covered**: E12
## Purpose
Display a filterable, searchable list of all past sessions across all agreements. Users can review completed, cancelled, or missed sessions with relevant details.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Session History      [Filter ▼]  |
+------------------------------------------+
|                                           |
|  [Search sessions...]               [🔍] |
|                                           |
|  Filters: [All ▼] [Skill ▼] [Date ▼]    |
|                                           |
|  +--------------------------------------+ |
|  | ✅ Completed                         | |
|  | Python Programming #4               | |
|  | with Kwanele Mhlongo                | |
|  | Feb 15, 2026 · 2:00-3:00 PM        | |
|  | Materials: 4 files · Notes: Yes     | |
+--------------------------------------+  |
|  +--------------------------------------+ |
|  | ❌ Cancelled                         | |
|  | Guitar Basics #2                    | |
|  | with Thandi Nkosi                   | |
|  | Feb 14, 2026 · 10:00-11:00 AM      | |
|  | Reason: Partner requested           | |
|  +--------------------------------------+ |
|  | ✅ Completed                         | |
|  | Photography #1                      | |
|  | with Busi Dlamini                   | |
|  | Feb 12, 2026 · 4:00-5:00 PM        | |
|  | Materials: 1 file · Rated ★★★★☆   | |
|  +--------------------------------------+ |
|  | ⏳ No Show                           | |
|  | Python Programming #3               | |
|  | with Kwanele Mhlongo                | |
|  | Feb 10, 2026 · 2:00-3:00 PM        | |
|  | Reported: No show - learner         | |
|  +--------------------------------------+ |
|                                           |
|  Loaded 12 of 45 sessions  [Load More]   |
+------------------------------------------+
```

## Component Breakdown
1. **Search Bar**: Full-text search across session titles, partner names, and skill names.
2. **Filter Row**: Horizontal scrollable filter chips:
   - Status filter: All, Completed, Cancelled, No Show, Missed
   - Skill filter: Dropdown of user's skills
   - Date filter: This week, This month, Last 3 months, Custom range
   - Active filter count badge
3. **Session History Item**: Card for each session showing:
   - Status icon + label (color-coded: green=completed, red=cancelled, orange=no-show, gray=missed)
   - Skill name + session number
   - Partner name
   - Date and time range
   - Contextual info line (materials count, notes availability, rating given)
   - Tappable -> session detail
4. **Pagination / Infinite Scroll**: "Load More" at bottom or auto-load on scroll.
5. **Summary Stats** (optional top section): "Completed: 8 | Cancelled: 3 | No Shows: 1 | Total: 12"

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton list with 5 placeholder cards (status bar, title lines, detail lines with shimmer).
- **Empty (No History)**:
  ```
  +----------------------------------+
  |                                  |
  |    [Illustration: time travel]   |
  |                                  |
  |  No session history yet          |
  |                                  |
  |  Your completed sessions will    |
  |  appear here. Start learning     |
  |  or teaching to build your       |
  |  history!                        |
  |                                  |
  |  [Find a Skill Exchange]         |
  |                                  |
  +----------------------------------+
  ```
- **Empty (Filtered)**: "No sessions match your filters." with [Clear Filters] button.
- **Error**: "Could not load session history." with [Retry] button. Offline mode shows cached history if available.
- **Data**: Scrollable, searchable, filterable session list. Pull-to-refresh. Infinite scroll or "Load More" pagination.

## Navigation Connections
- **Incoming**: From Session Calendar "History" link, from profile stats, from agreement detail.
- **Outgoing**: Tap item -> `/sessions/:id`. Tap filter -> updates list in-place. Search -> filtered results. "Find a Skill Exchange" -> skill discovery screens.

## Future Considerations
- Session history export (CSV/PDF)
- Session replay or recording access from history
- Timeline view (chronological with date headers)
- Monthly/Yearly session summaries
- Session statistics (average duration, completion rate)
- Compare session frequency across agreements
- Archive old sessions (auto-archive after 1 year)
- Session feedback history
- Attendance certificate generation
