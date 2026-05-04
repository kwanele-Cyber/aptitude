# Create Agreement Page
**Status**: Pending
**Route**: `/agreements/create?partnerId=:id&skillId=:id`
**Priority**: P3
**Use Cases Covered**: C09, C10, C11
## Purpose
Allow matched users to formalize a skill exchange agreement. Captures which skill will be taught, duration, frequency, session format, and provides a review step before final submission.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Cancel]  New Agreement                  |
+------------------------------------------+
|  Step 1 of 4  [====>--------]  25%        |
|                                           |
|  Which skill are you teaching?            |
|  +--------------------------------------+ |
|  | [Skill Search...]                🔍  | |
|  +--------------------------------------+ |
|                                           |
|  Available Skills:                        |
|  +--------------------------------------+ |
|  | 📘 Python Programming              > | |
|  | 📗 Guitar Lessons                  > | |
|  | 📙 Web Development                 > | |
|  | 📕 Photography Basics              > | |
|  +--------------------------------------+ |
|                                           |
|  Selected: Python Programming             |
|  You are the:  ○ Teacher   ● Learner     |
|                                           |
|  [Continue >]                             |
+------------------------------------------+
```

## Layout Description (Step-by-step form)

**Step 1 - Skill Selection**: Searchable list of skills the partner offers (or user offers, depending on role). Radio selection. Role toggle (Teacher/Learner).

```
+------------------------------------------+
| [Back]  New Agreement           [Preview] |
+------------------------------------------+
|  Step 2 of 4  [=====>-------]  50%        |
|                                           |
|  Duration                                 |
|  How long will this agreement last?       |
|                                           |
|  [4 weeks]  [8 weeks]  [12 weeks]        |
|  [Custom: ___ weeks]                      |
|                                           |
|  Frequency                                |
|  How many sessions per week?              |
|                                           |
|  [1x/wk]  [2x/wk]  [3x/wk]              |
|  [Custom: ___ per week]                   |
|                                           |
|  [< Back]  [Continue >]                   |
+------------------------------------------+
```

**Step 2 - Schedule**: Duration selector (pill buttons + custom input). Frequency selector. Optional preferred days/times.

**Step 3 - Format**: Session format (In-person / Video / Hybrid). Location details (address or video link). Materials needed text area.

**Step 4 - Review & Submit**: Full summary of agreement terms. Editable sections. Notes for partner (optional text area).

```
+------------------------------------------+
| [Back]  Review Agreement                  |
+------------------------------------------+
|  Step 4 of 4  [============]  100%        |
|                                           |
|  📋 Agreement Summary                    |
|                                           |
|  Skill:    Python Programming             |
|  Role:     Learner                        |
|  Partner:  Kwanele Mhlongo               |
|  Duration: 8 weeks                       |
|  Sessions: 2 per week (Tue, Thu)         |
|  Format:   Video Call                    |
|  Link:     meet.google.com/xxx           |
|                                           |
|  Notes to partner:                        |
|  +--------------------------------------+ |
|  | Looking forward to learning Python! | |
|  +--------------------------------------+ |
|                                           |
|  [Submit Agreement Proposal]              |
+------------------------------------------+
```

## Component Breakdown
1. **Stepper Indicator**: Shows progress across 4 steps. Tappable completed steps for editing.
2. **Skill Picker**: Search field + scrollable skill list with icons. Single-select radio buttons.
3. **Role Toggle**: Segmented control (Teacher / Learner) determining the user's role in this agreement.
4. **Duration Selector**: Pill-shaped option buttons for common durations + custom number input.
5. **Frequency Selector**: Similar pill buttons for sessions per week with custom option.
6. **Format Selector**: Card-style radio selection (In-person / Video / Hybrid) with dynamic fields.
7. **Location/Link Input**: Conditional field based on format selection; address autocomplete for in-person, text field for video link.
8. **Notes Field**: Optional multi-line text area for messages to partner.
9. **Summary Card**: Read-only formatted display of all selections before final submission.
10. **Submit Button**: Primary action button. Sends agreement proposal notification to partner.

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton form with gray rectangles matching the step layout. No interaction possible.
- **Empty**: Step 1 with no skills listed shows "No skills available. Your partner hasn't listed any skills yet." with a back button.
- **Error**: Field-level validation errors (red borders + messages). API error banner: "Failed to submit agreement. [Retry]". Network error with offline indicator.
- **Data**: Fully interactive multi-step form with validation. Each step validates before allowing "Continue". Preview step shows complete summary with edit capability per section.

## Navigation Connections
- **Incoming**: From Match detail "Create Agreement" button, from partner profile, from skill discovery flow. Query params carry `partnerId` and optional `skillId`.
- **Outgoing**: Cancel -> Confirmation dialog ("Discard draft?"). Submit -> Success page or redirect to `/agreements/:id`. Preview step -> back to any step for editing.

## Future Considerations
- Agreement templates (reuse previous terms)
- In-app calendar sync for session scheduling
- Auto-save draft as user progresses
- Multiple skill packages in one agreement
- Milestone-based agreements with checkpoints
- Recurring agreement renewal option
- Integration with payment escrow for paid sessions
