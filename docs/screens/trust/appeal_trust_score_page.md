# Appeal Trust Score Page
**Status**: Pending
**Route**: `/trust-score/appeal`
**Priority**: P5
**Use Cases Covered**: T10
## Purpose
Allow users to formally appeal a trust score change they believe was applied incorrectly. Users select a reason category, provide a detailed description, and attach supporting evidence. Submissions are reviewed by admin moderators.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Appeal Trust Score               |
+------------------------------------------+
|                                           |
|  Current Score: 62 (Needs Improvement)   |
|  Previous Score: 78                      |
|  ↓ Dropped by 16 points on Feb 10, 2026 |
|                                           |
|  Reason for score drop:                   |
|  "No-show marked for session #3"         |
|  (Python Programming with Kwanele)       |
|                                           |
|  +--------------------------------------+ |
|  | ⚠️ Appeals are reviewed within 5-7 | |
|  | business days. False appeals may    | |
|  | result in additional score penalties.| |
|  +--------------------------------------+ |
|                                           |
|  Reason for Appeal *                     |
|  +--------------------------------------+ |
|  | [Select a reason...              ▼] | |
|  +--------------------------------------+ |
|  Options:                                 |
|  - I attended the session (wrong no-show)|
|  - Technical issue prevented check-in    |
|  - Rating was unfair / retaliatory       |
|  - Mistaken identity                     |
|  - System error / glitch                 |
|  - Other (please describe)               |
|                                           |
|  Description *                            |
|  +--------------------------------------+ |
|  | I did attend the session on Feb 10  | |
|  | but the QR code wouldn't scan and   | |
|  | the manual code wasn't working. I   | |
|  | have a screenshot of our chat       | |
|  | confirming we met.                  | |
|  |                                     | |
|  +--------------------------------------+ |
|  345/2000 characters                     |
|                                           |
|  Evidence (optional)                      |
|  +--------------------------------------+ |
|  | [📎 Attach Files] [📷 Add Photo]    | |
|  |                                      | |
|  |  Attached:                           | |
|  |  ✅ chat_screenshot.png (245 KB)    | |
|  |  ✅ location_history.png (1.2 MB)    | |
|  |                              [Remove]| |
|  +--------------------------------------+ |
|  Accepted: Images, PDF (max 10MB each)   |
|                                           |
|  [Submit Appeal]                          |
+------------------------------------------+
```

## Component Breakdown
1. **Score Context Banner**: Shows current score, previous score, drop amount, and the stated reason for the drop. Helps user understand what they are appealing.
2. **Warning Notice**: Yellow/amber info banner explaining review timeline and penalties for false appeals.
3. **Reason Dropdown**: Categorized selector for appeal reason. Required field. Pre-filled if navigated from a specific score drop event.
4. **Description Field**: Multi-line text area for detailed explanation. Required. Character counter with limit (2000). Placeholder guidance text.
5. **Evidence Attachment Area**: File/image attachment section with:
   - Add file button (triggers system file picker)
   - Add photo button (triggers camera/gallery)
   - File list showing attached items with name, size, and remove option
   - Accepted file type hints
   - Individual file size limit indicator (10MB)
   - Total attachment limit (e.g., 5 files)
6. **Submit Button**: Primary action, disabled until reason and description are provided. Shows loading state on submit.

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton form with all fields grayed out (reason selector, text area, attachment area with shimmer).
- **Error - No Score Drop**: "Your trust score has not changed recently. Appeals are only accepted for recent score changes." with [Go Back] button.
- **Error - Appeal Pending**: "You already have a pending appeal for this score change. It is being reviewed." with [View Appeal Status] button.
- **Error - Appeal Limit**: "You have reached the maximum number of appeals. Please contact support." with support link.
- **Error - Submit Failed**: "Failed to submit appeal. [Retry]". File upload error: "Failed to upload [filename]. [Retry]".
- **Data**: Fully interactive form. File upload progress indicators. Submit navigates to a confirmation page.

## Navigation Connections
- **Incoming**: From Trust Score page "Appeal" button/link, from trust score drop notification.
- **Outgoing**: Submit -> Success confirmation: "Appeal submitted! We'll review it within 5-7 business days." with reference number and [View Appeal Status] button -> `/disputes/:id`. Cancel -> Discard confirmation -> back to `/trust-score`. View pending appeal -> `/disputes/:id`.

## Future Considerations
- Appeal status tracking with real-time updates
- Two-way communication with reviewer through the appeal
- Appeal history for the user
- AI-assisted evidence review suggestions
- Emergency appeal flag for critical score issues
- Appeal outcome analytics (success rate by reason type)
- Auto-resolution for common appeal types
- Evidence tampering detection
