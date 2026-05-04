# Create Dispute Page
**Status**: Pending
**Route**: `/disputes/create`
**Priority**: P5
**Use Cases Covered**: X06
## Purpose
Allow users to formally raise a dispute regarding a session or agreement (e.g., no-show, incomplete service, misrepresentation). Users select the related session or agreement, describe the issue, and state their desired outcome.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Cancel]  Open a Dispute                 |
+------------------------------------------+
|                                           |
|  +--------------------------------------+ |
|  | ℹ️ A dispute is a formal complaint  | |
|  | about a session or agreement. Our   | |
|  | team will review both sides and     | |
|  | make a fair decision.               | |
|  +--------------------------------------+ |
|                                           |
|  Related To *                              |
|  +--------------------------------------+ |
|  | ● Session                            | |
|  |   [Select a session...          ▼]  | |
|  |                                      | |
|  | ○ Agreement                          | |
|  |   [Select an agreement...       ▼]  | |
|  +--------------------------------------+ |
|  Pre-populated: Python #4 with Kwanele   |
|  (Feb 15, 2026)                          |
|                                           |
|  Issue Category *                         |
|  +--------------------------------------+ |
|  | [Select issue category...       ▼]  | |
|  +--------------------------------------+ |
|  Options:                                 |
|  - Partner did not show up               |
|  - Session was cut short                 |
|  - Skill/teaching quality was poor       |
|  - Partner was unprepared                |
|  - Misrepresentation of skills           |
|  - Agreement terms not followed          |
|  - Communication breakdown               |
|  - Other                                |
|                                           |
|  Describe the Issue *                     |
|  +--------------------------------------+ |
|  | Kwanele did not show up for our     | |
|  | session on Feb 15. I waited 30      | |
|  | minutes and tried messaging but     | |
|  | got no response. This is the second | |
|  | time this has happened.             | |
|  |                                     | |
|  +--------------------------------------+ |
|  345/2000 characters                     |
|                                           |
|  Desired Outcome *                        |
|  +--------------------------------------+ |
|  | [Select desired outcome...       ▼] | |
|  +--------------------------------------+ |
|  Options:                                 |
|  - Reschedule the session                |
|  - Amend the agreement terms             |
|  - Cancel the agreement                  |
|  - Formal warning to partner             |
|  - Trust score adjustment                |
|  - Account suspension review             |
|  - Other                                |
|                                           |
|  [Submit Dispute]                         |
+------------------------------------------+
```

## Component Breakdown
1. **Info Banner**: Explanation of what a dispute is and the review process.
2. **Related Entity Selector**: Toggle between "Session" or "Agreement" with corresponding dropdown selector. Pre-populated if navigated from a specific session/agreement.
3. **Issue Category Dropdown**: Pre-defined categories for the dispute. Required.
4. **Description Field**: Multi-line text area for detailed issue description. Required. Character counter (2000 max). Placeholder with examples.
5. **Desired Outcome Dropdown**: What the user wants as resolution. Required. "Other" option reveals custom text input.
6. **Evidence Attachment** (future, not on initial layout): Same as report page with file upload.
7. **Submit Button**: Primary action. Validates all required fields.

## States (Loading, Empty, Error, Data)
- **Loading**: Full form skeleton with all selectors and fields grayed out.
- **Empty (No Sessions/Agreements)**: "You don't have any completed sessions or active agreements to dispute. [Contact Support]" if user has no disputable items.
- **Error - Duplicate Dispute**: "A dispute for this session/agreement is already in progress." with [View Dispute] button -> `/disputes/:id`.
- **Error - Session Too Old**: "Disputes can only be opened within 30 days of a session date."
- **Error - Agreement Already Resolved**: "This agreement has already been resolved/completed." with info about finality.
- **Error - Submit Failed**: "Failed to open dispute. [Retry]"
- **Data**: Fully interactive form. Submit validates and creates dispute, navigates to dispute detail page.

## Navigation Connections
- **Incoming**: From Session Detail "Report Issue" button, from Agreement Detail "Open Dispute" link, from help/support page.
- **Outgoing**: Submit -> `/disputes/:id` (newly created dispute). Cancel -> Discard confirmation -> back. Session/Agreement selector -> populates context info.

## Future Considerations
- Evidence attachment (screenshots, documents)
- Video evidence upload
- Witness references (other users who can confirm)
- Chat log auto-attachment from the relevant period
- Dispute fee (refundable if user is found correct)
- Mediation option before formal dispute
- Estimated resolution time display
- Step-by-step dispute wizard with progress indicator
