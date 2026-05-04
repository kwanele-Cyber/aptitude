# Admin Appeal Review Page
**Status**: Pending
**Route**: `/admin/appeals`
**Priority**: Admin
**Use Cases Covered**: A14
## Purpose
Provide administrators with a queue of trust score appeals submitted by users. Each appeal includes the user's reason, description, and evidence. Admins can review and make decisions (approve/deny) with optional notes.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [<] Appeal Review                        |
+------------------------------------------+
|                                           |
|  Queue: 3 Pending · 1 Under Review       |
|         5 Resolved · 2 Denied            |
|                                           |
|  Filters: [Status ▼] [Date ▼]            |
|                                           |
|  +--------------------------------------+ |
|  | Kwanele Mhlongo | Feb 16, 2026      | |
|  | Score: 62 (was 78) - Drop: -16      | |
|  | Reason: I attended the session       | |
|  | Status: Pending                      | |
|  | [Review]                             | |
|  +--------------------------------------+ |
|  | Thandi Nkosi | Feb 15, 2026         | |
|  | Score: 45 (was 72) - Drop: -27      | |
|  | Reason: Technical issue prevented   | |
|  |         check-in                     | |
|  | Status: Pending                      | |
|  | [Review]                             | |
|  +--------------------------------------+ |
|                                           |
|  --- Review Panel (Kwanele's Appeal) ---  |
|  +--------------------------------------+ |
|  | Appellant: Kwanele Mhlongo          | |
|  | Current Score: 62 | Previous: 78    | |
|  | Drop Reason: No-show marked          | |
|  |                                      | |
|  | Appeal Reason: "I attended...       | |
|  | the QR code wouldn't scan..."       | |
|  |                                      | |
|  | Evidence:                            | |
|  | [chat_screenshot.png]               | |
|  | [location_history.png]               | |
|  |                                      | |
|  | Related Session: Python #4          | |
|  | Partner: Kwanele Mhlongo            | |
|  | Session Status: No-show (Feb 15)    | |
|  |                                      | |
|  | Admin Notes:                         | |
|  | [______________________________]    | |
|  |                                      | |
|  | Decision:                            | |
|  |  ● Approve appeal (restore score)   | |
|  |  ○ Deny appeal                      | |
|  |  ○ Request more information         | |
|  |                                      | |
|  | [Submit Decision]                    | |
|  +--------------------------------------+ |
+------------------------------------------+
```

## Component Breakdown
1. **Queue Summary Bar**: Count of appeals by status (Pending, Under Review, Resolved, Denied).
2. **Appeal Queue List**: Left panel showing appeal items with:
   - User name and avatar
   - Date filed
   - Score change info (current, previous, drop amount)
   - Appeal reason (truncated)
   - Status badge
   - [Review] button
3. **Review Panel** (right/main area): When an appeal is selected for review:
   - Appellant info header with score details
   - Appeal description (full text)
   - Evidence gallery (images/files with preview)
   - Related session link
   - Partner information
   - Admin notes text area
   - Decision radio buttons: Approve (restore score), Deny, Request More Information
   - Trust score adjustment preview (shows what score will become)
   - [Submit Decision] button
4. **History Section**: Timeline of previous actions on this appeal (status changes, admin comments).

## States (Loading, Empty, Error, Data)
- **Loading**: Queue skeleton and review panel skeleton with shimmer.
- **Empty (No Appeals)**: "No pending appeals. All caught up!" with checkmark illustration.
- **Empty (Filtered)**: "No appeals match your filters."
- **Error**: "Could not load appeals." with [Retry] button.
- **Data**: Full queue list with side-by-side or stacked review panel. Pull-to-refresh for new appeals.

## Navigation Connections
- **Incoming**: From Admin Dashboard "Appeals" link, from admin sidebar, from notification.
- **Outgoing**: Select appeal -> opens in review panel. Submit Decision -> confirmation dialog -> moves to resolved/denied -> next appeal loaded. Request Info -> sends notification to user. View Session -> `/admin/sessions/:id`. View User -> `/admin/users/:id`.

## Future Considerations
- Appeal SLAs (response time targets)
- Automated evidence verification
- Similar case comparison (show precedent)
- Two-admin approval for sensitive decisions
- Appeal response template library
- Partial score restoration option
- Time-bound evidence submission window
- Appeal notes visible to user vs internal-only
- Escalation to senior admin
- Appeal outcome notification automation
- Appeal analytics (approval rates, common reasons)
