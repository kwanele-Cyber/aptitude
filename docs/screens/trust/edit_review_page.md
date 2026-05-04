# Edit Review Page
**Status**: Pending
**Route**: `/reviews/:id/edit`
**Priority**: P5
**Use Cases Covered**: T04
## Purpose
Allow a user to edit a review they previously submitted. Pre-fills the rating and text fields with the original values. Enforces a 48-hour edit window after the original submission.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Cancel]  Edit Review                    |
+------------------------------------------+
|                                           |
|       Editing your review for            |
|       [Avatar] Kwanele Mhlongo           |
|       Python Programming #4              |
|       Reviewed: Feb 15, 2026             |
|                                           |
|  ⏰  Edit window closes in 12 hours      |
|      (Original submission: Feb 15, 2026  |
|       6:00 PM. Deadline: Feb 17, 6:00 PM)|
|                                           |
|       Your Rating                         |
|          ★  ★  ★  ★  ☆                  |
|       Currently: 4 stars                 |
|       Originally: 4 stars                |
|                                           |
|       Your Review                         |
|       +--------------------------------+ |
|       | Great session! Very patient    | |
|       | and explained concepts well.   | |
|       | But we ran out of time for     | |
|       | the last topic.               | |
|       |                                | |
|       |                                | |
|       +--------------------------------+ |
|       120/1000 characters                |
|                                           |
|  [Update Review]                          |
|                                           |
|  [Delete Review]                          |
+------------------------------------------+
```

## Component Breakdown
1. **Header Info**: Partner avatar and name, skill/session reference, original review date.
2. **Edit Window Timer**: Orange/yellow banner showing time remaining to edit. Countdown clock. Turns red when less than 1 hour remains. Shows deadline date/time.
3. **Star Rating**: Interactive stars pre-filled to current rating. Shows "Currently: X stars" and "Originally: X stars" if unchanged vs changed.
4. **Review Text Field**: Pre-filled with existing text. Character counter. Expandable.
5. **Update Button**: Primary action, enabled only if changes were made.
6. **Delete Review Button**: Destructive action (red text/link) at bottom. Triggers confirmation dialog.

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton form with star placeholders and text area block with shimmer.
- **Error - Edit Window Expired**:
  ```
  +----------------------------------+
  |                                  |
  |  ⏰ Edit window closed           |
  |                                  |
  |  Reviews can only be edited      |
  |  within 48 hours of submission.  |
  |  Your review was submitted on    |
  |  Feb 15, 2026. The deadline was  |
  |  Feb 17, 2026.                   |
  |                                  |
  |  If you need to change your      |
  |  review, please contact support. |
  |                                  |
  |  [Contact Support]  [Go Back]    |
  |                                  |
  +----------------------------------+
  ```
  This is the most likely error state and must be handled gracefully.
- **Error - Review Not Found**: "Review not found" with [Go Back] button.
- **Error - Not Your Review**: "You can only edit your own reviews."
- **Error - Submit Failed**: "Failed to update review. [Retry]"
- **Data**: Pre-filled form with original values. Changes tracked. Submit updates and navigates back to reviews list.

## Navigation Connections
- **Incoming**: From User Reviews page "Edit" button, from rate success confirmation "Edit" link, from notification.
- **Outgoing**: Cancel -> Confirm discard changes -> back. Update -> Success animation -> redirect to `/profile/:uid/reviews`. Delete -> Confirmation dialog "Are you sure? This cannot be undone." -> redirect. Contact Support -> support chat/email.

## Future Considerations
- Review edit history (show previous versions to moderators)
- Expanded edit window for premium users
- Review reply editing (if reviewee responded)
- Edit notifications to the reviewed user
- Automatic flagging of drastic rating changes
- One-time edit extension request
- Undo delete within 24 hours
