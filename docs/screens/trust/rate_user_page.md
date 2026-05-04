# Rate User Page
**Status**: Pending
**Route**: `/rate/:sessionId`
**Priority**: P5
**Use Cases Covered**: T01, T02
## Purpose
Allow a user to rate their session partner after a completed session. Provides a 1-5 star rating system with an optional written review. Submitting the rating updates the partner's trust score and overall rating.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [X Close]                                |
+------------------------------------------+
|                                           |
|                                           |
|       How was your session?              |
|                                           |
|       [Avatar: Kwanele Mhlongo]          |
|         Kwanele Mhlongo                  |
|         Python Programming #4            |
|         Feb 15, 2026 · 2:00-3:00 PM     |
|                                           |
|       Rate your experience               |
|                                           |
|          ★  ★  ★  ★  ★                  |
|       (Tap a star to rate)               |
|                                           |
|       "Great session! Very patient        |
|        and explained concepts well."      |
|                                           |
|       [Add a written review (optional)]   |
|       +--------------------------------+ |
|       |                                | |
|       |                                | |
|       +--------------------------------+ |
|                                           |
|       Your rating helps the community     |
|       identify great teachers/learners.   |
|                                           |
|       [Submit Rating]                     |
|                                           |
+------------------------------------------+
```

## Component Breakdown
1. **Close Button**: X icon in top-left to dismiss without rating.
2. **Session Context Card**: Partner avatar and name, skill name, session number, date and time for reference.
3. **Star Rating**: Interactive 5-star component. Stars highlight on hover/tap. Shows label below based on selection: 1=Poor, 2=Fair, 3=Good, 4=Very Good, 5=Excellent. Haptic feedback on tap.
4. **Review Text Field**: Optional multi-line text area for written review. Character counter (max 1000). Placeholder text: "Share details about your experience..."
5. **Community Note**: Subtle text explaining the importance of ratings for trust scores.
6. **Submit Button**: Primary action button. Disabled until a star rating is selected. Shows loading state on submit.

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton with avatar circle, stars placeholder, and text field gray blocks with shimmer.
- **Error - Already Rated**: "You've already rated this session." with [View Your Review] button and [Edit Review] link -> `/reviews/:id/edit`.
- **Error - Session Not Completed**: "You can only rate sessions that have been completed." with [Go Back] button.
- **Error - Self-Rating**: "You cannot rate yourself." (should not normally occur but safety check).
- **Error - Submit Failed**: "Failed to submit rating. [Retry]" with option to save draft locally.
- **Data**: Full interactive form. Stars tappable with visual feedback. Text field expandable. Submit triggers a success animation (confetti/checkmark).

## Navigation Connections
- **Incoming**: From Session Detail "Rate Partner" button (shown after session completion), from session history, from notification prompting review.
- **Outgoing**: Submit -> Success animation -> redirect to session detail or agreements. Close -> Confirm discard -> back to previous screen. View/Edit -> `/reviews/:id/edit`.

## Future Considerations
- Rating criteria breakdown (punctuality, knowledge, communication, attitude) instead of single score
- Photo/video attachment for review evidence
- Review moderation (flagged content review)
- Anonymous reviews (hidden from the rated user)
- Rating streak rewards
- Prompt after every Nth completed session
- Rate both teacher and learner separately
