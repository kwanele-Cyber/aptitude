# Report User Page
**Status**: Pending
**Route**: `/report/:userId`
**Priority**: P5
**Use Cases Covered**: X05

## Purpose
Allow users to report another user for violating platform rules. Supports selecting a reason category, providing detailed description, and optionally attaching evidence screenshots.

## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [<] Report User                           |
+------------------------------------------+
|                                           |
|  Reporting: Kwanele Mhlongo              |
|  [Avatar]  @kwanele_m                    |
|                                           |
|  Reason for Report *                      |
|  +--------------------------------------+ |
|  | ○ Inappropriate behavior             | |
|  | ○ Harassment or bullying             | |
|  | ○ Fake profile or identity           | |
|  | ○ Spam or advertising                | |
|  | ○ Offensive content                  | |
|  | ○ Session no-show                    | |
|  | ○ Agreement violation                | |
|  | ○ Other                              | |
|  +--------------------------------------+ |
|                                           |
|  Description *                            |
|  +--------------------------------------+ |
|  | Describe what happened...            | |
|  |                                      | |
|  |                                      | |
|  |                                      | |
|  | (Max 1000 characters)                | |
|  +--------------------------------------+ |
|                                           |
|  Attachments (Optional)                   |
|  +--------------------------------------+ |
|  | [📎 Add Screenshots] [📎 Add Files]  | |
|  |                                      | |
|  |  preview1.png   preview2.png         | |
|  |  [✕]            [✕]                  | |
|  +--------------------------------------+ |
|                                           |
|  ⚠️ False reports may result in          |
|  action against your account.            |
|                                           |
|  [Cancel]          [Submit Report]        |
+------------------------------------------+
```

## Component Breakdown
1. **Reported User Header**: Avatar, name, and username of the user being reported.
2. **Reason Selection**: Radio button list of predefined report reasons/categories.
3. **Description Field**: Multi-line text area for detailed explanation (required if "Other" is selected).
4. **Attachment Section**: Optional file picker for screenshots or evidence (max 5 files, max 5MB each).
5. **Warning Notice**: Legal disclaimer about false reporting.
6. **Submit Button**: Submits the report to admin queue. Disabled until reason is selected and description is provided.

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton form with placeholder radio buttons and text area.
- **Error**: "Could not submit report. Please try again." with [Retry] button.
- **Success**: "Report submitted successfully. Our team will review it within 24-48 hours." with [Done] button, redirects to previous page.
- **Validation Errors**: Inline validation — "Please select a reason", "Please provide a description", "Files must be under 5MB each."

## Navigation Connections
- **Incoming**: From user profile page menu, from chat message context menu, from match card.
- **Outgoing**: Submit -> loading -> success -> redirects to previous page. Cancel -> confirmation dialog -> pop.

## Future Considerations
- Anonymous reporting option
- Report status tracking (user can check resolution)
- Automatic chat message evidence capture
- In-app review of platform guidelines before report
- Report history for the user
- Block user during report flow
