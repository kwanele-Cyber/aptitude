# Learning Goals Page
**Status**: Pending
**Route**: `/goals`
**Priority**: P5
**Use Cases Covered**: X11
## Purpose
Allow users to set, track, and complete learning goals related to their skill exchanges. Goals can be per-skill or general milestones. Users can add new goals, mark them complete, and track progress over time.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Learning Goals     [+ Add Goal]  |
+------------------------------------------+
|                                           |
|  In Progress (3)                          |
|  +--------------------------------------+ |
|  | [☐] Master Python functions        | |
|  |     Python Programming               | |
|  |     Progress: ██████░░░░  60%       | |
|  |     Target: Feb 28, 2026            | |
|  |     [Update Progress >]              | |
|  +--------------------------------------+ |
|  | [☐] Learn 5 guitar chords           | |
|  |     Guitar Basics                    | |
|  |     Progress: ██░░░░░░░░  20%       | |
|  |     Target: Mar 15, 2026            | |
|  |     [Update Progress >]              | |
|  +--------------------------------------+ |
|  | [☐] Complete photography portfolio  | |
|  |     Photography Basics               | |
|  |     Progress: █░░░░░░░░░  10%       | |
|  |     Target: Apr 1, 2026             | |
|  |     [Update Progress >]              | |
|  +--------------------------------------+ |
|                                           |
|  Completed (2)                            |
|  +--------------------------------------+ |
|  | [☑] Set up Python environment       | |
|  |     ✅ Completed Feb 10, 2026       | |
|  +--------------------------------------+ |
|  | [☑] Learn basic Python syntax       | |
|  |     ✅ Completed Feb 5, 2026        | |
|  +--------------------------------------+ |
|                                           |
|  [Add New Goal]                           |
+------------------------------------------+
```

## Component Breakdown
1. **AppBar**: "Learning Goals" title with [+ Add Goal] button.
2. **Section Headers**: "In Progress (N)" and "Completed (N)" with collapsible sections. Completed section collapsed by default.
3. **Goal Card** (in progress):
   - Checkbox for quick mark-complete (with confirmation)
   - Goal title
   - Associated skill (badge/chip)
   - Progress bar with percentage
   - Target date (with urgency color: green=on track, yellow=approaching, red=overdue)
   - "Update Progress" button -> quick update dialog
4. **Goal Card** (completed):
   - Checked checkbox
   - Goal title (strikethrough optional)
   - Completed date text
   - No progress bar
5. **FAB / Add Button**: "+" button or inline expandable form to add new goal.
6. **Quick Add Dialog**: Bottom sheet or inline form:
   - Goal title (required)
   - Associated skill (optional, dropdown)
   - Target date (optional, date picker)
   - Initial progress (0-100, slider)
   - [Save] [Cancel]

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton goal cards with checkbox, title, progress bar placeholder with shimmer.
- **Empty (No Goals)**:
  ```
  +----------------------------------+
  |                                  |
  |    [Illustration: target/goal]   |
  |                                  |
  |  Set your first learning goal!   |
  |                                  |
  |  Goals help you stay motivated   |
  |  and track your progress in      |
  |  each skill you're learning.     |
  |                                  |
  |  [Add Your First Goal]           |
  |                                  |
  +----------------------------------+
  ```
- **Error**: "Could not load goals." with [Retry] button. Save error: "Failed to save goal. [Retry]".
- **Data**: Full goal list with expandable sections. Drag to reorder in-progress goals? Checkbox mark-complete with optional congratulations animation.

## Navigation Connections
- **Incoming**: From Progress Dashboard "Goals" link, from profile, from settings.
- **Outgoing**: Add Goal -> Inline form or bottom sheet. Update Progress -> Slider/input dialog -> refresh list. Tap goal -> expand details or navigate to progress detail. Skill chip -> `/agreements/:id` filtered by skill.

## Future Considerations
- Goal categories (learning, teaching, networking)
- Goal sharing with partner for accountability
- Goal reminder notifications
- SMART goal template suggestions
- Goal difficulty/effort estimation
- Goal completion streak rewards
- Automated goal progress from session completions
- Public profile goals (optional display)
- Goal collaboration (both parties working toward same goal)
- AI-suggested goals based on skill progress
