# Modify Agreement Page
**Status**: Pending
**Route**: `/agreements/:id/modify`
**Priority**: P3
**Use Cases Covered**: C11
## Purpose
Allow either party in an agreement to propose changes to the terms (duration, frequency, format, location). Pre-fills the existing terms and requires a revision notes field explaining the proposed changes.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Cancel]  Modify Agreement               |
+------------------------------------------+
|                                           |
|  Modifying agreement with                |
|  Kwanele Mhlongo                          |
|  Python Programming · Learner            |
|                                           |
|  +--------------------------------------+ |
|  | ⚠️ Changes will be sent as a        | |
|  | proposal for the other party to      | |
|  | accept or decline.                   | |
|  +--------------------------------------+ |
|                                           |
|  Duration                                 |
|  [8 weeks]  [12 weeks]  [Custom: ___]    |
|  Current: 8 weeks                         |
|                                           |
|  Frequency                                |
|  [2x/wk]  [3x/wk]  [Custom: ___]        |
|  Current: 2x/week                         |
|                                           |
|  Format                                   |
|  ○ In-person    ● Video    ○ Hybrid      |
|  Current: Video                           |
|                                           |
|  Location / Meeting Link                  |
|  +--------------------------------------+ |
|  | meet.google.com/abc-defg-hij         | |
|  +--------------------------------------+ |
|  Current: meet.google.com/old-link       |
|                                           |
|  Revision Notes *                         |
|  +--------------------------------------+ |
|  | I'd like to increase frequency to   | |
|  | 3x/week so we can cover more        | |
|  | material before my deadline.         | |
|  +--------------------------------------+ |
|                                           |
|  [Submit Modification Request]            |
+------------------------------------------+
```

## Component Breakdown
1. **Info Header**: Partner name, skill name, and role. Subdued text showing context of modification.
2. **Warning Banner**: Yellow/amber info banner explaining that changes are proposals requiring partner acceptance.
3. **Duration Field**: Same pill selector + custom input as create form, pre-filled with current value. Changed values highlighted.
4. **Frequency Field**: Pre-filled selector for sessions per week. Changed values highlighted with "New:" label.
5. **Format Selector**: Segmented control (In-person / Video / Hybrid). Shows current selection and new selection differently.
6. **Location/Link Input**: Pre-filled text field. Shows current value for reference.
7. **Revision Notes Field (Required)**: Multi-line text area for explaining why changes are needed. Validated as required. Character counter (max 500).
8. **Changed Fields Indicator**: Visual highlight (amber border or "Modified" badge) on fields that differ from original terms.
9. **Submit Button**: Primary action, disabled until at least one field is changed and revision notes are filled.

## States (Loading, Empty, Error, Data)
- **Loading**: Form skeleton with all fields grayed out and shimmer animation.
- **Error - Agreement Not Active**: Redirect or show error: "This agreement cannot be modified in its current state."
- **Error - Validation**: Field-level errors (e.g., "Revision notes are required"). API error: "Failed to submit modification. [Retry]".
- **Data**: Fully pre-filled form with current agreement terms. Changed fields visually highlighted. Submit sends modification request and navigates to agreement detail.

## Navigation Connections
- **Incoming**: From Agreement Detail "Modify" button. Only accessible when agreement is in "pending" or "active" status.
- **Outgoing**: Cancel -> Discard confirmation dialog -> back to `/agreements/:id`. Submit -> Loading spinner -> success -> redirect to `/agreements/:id` with updated status banner.

## Future Considerations
- Side-by-side comparison view (current vs proposed)
- Field-level change diffs highlighted in the summary
- "What changed?" auto-generated summary for the partner
- Multiple modification rounds with version history
- Modification deadline enforcement (no changes within 24h of a scheduled session)
- Inline chat or notes within modification request
- Auto-reject if partner doesn't respond within 72 hours
